/**************************************************************************
**
** Copyright (C) 2016 The DZH Company Ltd.
** Contact: http://www.gw.com.cn
**
** This file is part of the DZH Open Source Client.
**
** $DZH_BEGIN_LICENSE:LGPL21$
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 2.1 or version 3 as published by the Free
** Software Foundation and appearing in the file LICENSE.LGPLv21 and
** LICENSE.LGPLv3 included in the packaging of this file. Please review the
** following information to ensure the GNU Lesser General Public License
** requirements will be met: https://www.gnu.org/licenses/lgpl.html and
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
**
** $DZH_END_LICENSE$
**
**************************************************************************/

import QtQuick 2.0
import "./"
import "../core/data"
import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

/**
 * K线图用数据提供商，包含两个数据提供商，支持查询历史数据和订阅最新数据的功能
 */
Item {
    id: root
    property string serviceUrl
    property var params
    property bool hasMoreData: true

    property int count: 100

//    // 位置表示显示数据在缓存中开始位置
//    property int position: 0

    // 离最后一条数据的偏移位置
    property int lastOffset: 0

    // 最大预加载数据条数,预加载数据条数取当前显示条数和最大预加载数据条数中较小的一个值
    property int maxPreLoadCount: 200

//    // 限制单次最大请求个数，避免冗余请求多余数据，并且提高单次响应速度
//    property int maxRequestCount: 1000

    property var chart
    property bool stop: !visible

    // 全部数据的缓存（得考虑缓加载数据）
    property var cache: []

    // 需要展示的数据的数组
    property var chartData: []

    // chartData的最大值和最小值范围, 实现到具体图上决定
    property var range: [Number.MIN_VALUE, Number.MAX_VALUE]

    property var requestOffsetPosition

    DataProvider {
        id: queryDataProvider
        serviceUrl: root.serviceUrl
        autoQuery: false
        cacheLevel: 0

        property var callback
        onSuccess: {
            root.updateCache(data);
            callback && callback(data);
        }
        function adapt(nextData) {
            return root.adapt(nextData);
        }
    }

    // 避免和parent同时变化visible，导致错误设置成暂停请求
    property DataProvider subscribeDataProvider: DataProvider {
        //id: subscribeDataProvider
        serviceUrl: root.serviceUrl
        autoQuery: false
        cacheLevel: 0
        sub: 1

        onSuccess: {
            root.updateCache(data, true);

            // 当展示的数据个数达到一定数量时，推送到的k线数据反映到图上几乎是看不到变化效果的，这时避免频繁重画图形照成的UI阻塞不再更新展示数据
            if (root.count < 500) {
                updateChartData(true);
            }
        }
        function adapt(nextData) {
            return root.adapt(nextData);
        }
    }

    onCacheChanged: {
        if (cache) {

            // cache变化直接存储到本地缓存
            ChartLocalStorage.setItem(getStorageKey(), {cache: cache, hasMoreData: hasMoreData});
        }
    }

    onStopChanged: {
        if (stop) {
            clear();
        } else {
            query();
        }
    }

    // 查询参数变了则，清除缓存后重新查询
    onParamsChanged: {
        root.clear();
        if (!root.stop) {
            root.query();
        }
    }

    onRequestOffsetPositionChanged: {
        if (!root.stop) {
            updateChartData();
        }
    }

    function adapt(nextData) {
        return nextData[0].Data;
    }

    function query() {
        var cache = root.cache;
        if (!cache) {

            // 从本地存储中取出缓存数据
            var storage = ChartLocalStorage.getItem(getStorageKey()) || {};
            cache = storage.cache;
            root.hasMoreData = storage.hasMoreData === false ? false : true;
            if (cache) {
                root.cache = cache;
            }
        }

        var params = Util.assign({}, root.params);
        if (cache && cache.length > 0) {

            // 取cache数据中最后一条数据的时间作为开始时间订阅最新的数据
            var lastData = cache[cache.length - 1];
            params.begin_time = DateUtil.moment.unix(lastData.ShiJian).format('YYYYMMDD-HHmmss');
        } else {
            params.start = -1;
        }

        subscribeDataProvider.params = params;

        // 初始请求现在个数的数据
        root.updateChartData(function() {

            // 初始订阅请求
            subscribeDataProvider.query();
        });
    }

    function cancel() {
        subscribeDataProvider.cancel();
        queryDataProvider.cancel();
    }

    // 清理缓存
    function clear() {
        root.cancel();
        root.hasMoreData = true;
        root.cache = null;
        root.chartData = [];
        root.lastOffset = 0;
    }

    function updateChartData(callback) {

        if (!requestOffsetPosition || chart.skip) {
            return;
        }

        var count = requestOffsetPosition[0];
        var lastOffset = requestOffsetPosition[1];
        var totalCount = count + lastOffset;

        var currentCount = chartData.length;
        var cacheCount = cache ? cache.length : 0;

        if (hasMoreData && cacheCount < totalCount) {
            var requestCount = totalCount - cacheCount;

            // 计算请求数据的start和count,count需要加上预加载个数(默认等于当前显示的数据个数,但不能超过限制的最大值)
            // 初始currentCount为0时,请求个数为初始显示个数的2倍
            requestCount += Math.min(currentCount || requestCount, maxPreLoadCount);

//            // 限制最多单次请求个数
//            requestCount = Math.min(requestCount, maxRequestCount);
//            totalCount = requestCount + cacheCount;

//            requestOffsetPosition[0] = totalCount - lastOffset;

            var params = Util.assign({
                                         start: -(requestCount + cacheCount),
                                         count: requestCount
                                     }, root.params);

            // 取消上次请求后再请求
            queryDataProvider.cancel();
            queryDataProvider.params = params;

            // 得到数据后重新计算
            queryDataProvider.callback = function() {

                // 如果当前缓存数据个数还是小于请求个数时则表示没有更多数据了
                if (cache && cache.length < totalCount) {
                    hasMoreData = false;
                }
                updateChartData(callback);
            }
            queryDataProvider.query();
            return;
        }

        var start = Math.max(0, cacheCount - lastOffset - count);
        var end = Math.min(cacheCount, start + count);

        var nextCount = end - start;
        var nextLastOffset = cacheCount - end;

        // 判断是否有变化
        if (!!callback || nextCount !== root.count || nextLastOffset !== root.lastOffset || currentCount !== nextCount) {
            chartData = cache.slice(start, end);

            // 再重新确定count和lastOffset
            root.count = nextCount;
            root.lastOffset = nextLastOffset;

            if (typeof callback === 'function') {
                callback();
            }
        }
    }

    function updateCache(data, subscribe) {
        var cache = root.cache;
        if (!cache) {
            cache = data || [];
        } else if (data) {
            var startTime;
            var i;
            if (subscribe) {
                startTime = data[0].ShiJian;
                for (i = cache.length - 1; i >= 0; i--) {
                    if (cache[i].ShiJian === startTime) {
                        break;
                    }
                }
                cache.splice.apply(cache, [i, cache.length - i].concat(data));
            } else {
                startTime = cache[0].ShiJian;
                var eachData, index, length = data.length;
                for (i = length; i > 0; i--) {
                    eachData = data[i - 1];
                    if (eachData.ShiJian < startTime) {
                        index = i;
                        break;
                    }
                }
                if (index) {
                    var newData = data.slice(0, index);
                    cache = newData.concat(cache);
                    if (index < length) {
                        root.hasMoreData = false;
                    }
                } else {
                    root.hasMoreData = false;
                }
            }
        }
        root.cache = cache;
    }

    function getStorageKey() {
        return root.serviceUrl + '_' + JSON.stringify(root.params);
    }
}
