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
    property int count: 80
    property int minCount: 10
    property var charts: []
    property bool stop: !root.charts.some(function(eachChart) {return eachChart.visible})

    signal success(var data)

    DataProvider {
        id: queryDataProvider
        serviceUrl: root.serviceUrl
        autoQuery: false
        cacheLevel: 0
        onSuccess: {
            root.updateCache(data);
        }
        function adapt(nextData) {
            return root.adapt(nextData);
        }
    }

    DataProvider {
        id: subscribeDataProvider
        serviceUrl: root.serviceUrl
        autoQuery: false
        cacheLevel: 0
        sub: 1

        onSuccess: {
            root.updateCache(data, true);
        }
        function adapt(nextData) {
            return root.adapt(nextData);
        }
    }

    function adapt(nextData) {
        return nextData[0].Data;
    }

    onStopChanged: {
        if (stop) {
            clear();
        } else {
            query();
        }
    }

    function query() {
        var cache = internal.cache;
        if (!cache) {

            // 从本地存储中取出缓存数据
            var storage = ChartLocalStorage.getItem(internal.getStorageKey()) || {};
            cache = storage.cache;
            root.hasMoreData = storage.hasMoreData === false ? false : true;
            if (cache) {
                internal.cache = cache;
            }
        }

        var params = Util.assign({}, root.params);
        if (cache && cache.length > 0) {

            // 取cache数据中最后一条数据的时间作为开始时间订阅最新的数据
            var lastData = cache[cache.length - 1];
            params.begin_time = DateUtil.moment.unix(lastData.ShiJian).format('YYYYMMDD-HHmmss');

        } else if (count > 0) {
            params.start = -1;
        }

        // 初始订阅请求
        subscribeDataProvider.params = params;
        subscribeDataProvider.query();

        // 请求不足的历史数据
        root.countChanged();
    }

    function cancel() {
        subscribeDataProvider.cancel();
        queryDataProvider.cancel();
    }

    // 清理缓存
    function clear() {
        root.cancel();
        root.hasMoreData = true;
        internal.cache = null;
    }

    // 查询参数变了则，清除缓存后重新查询
    onParamsChanged: {
        root.clear();
        if (!root.stop) {
            root.query();
        }
    }

    // 个数变了，请求更多的数据
    onCountChanged: {
        if (count < 0) {
            return;
        }

        if (count < minCount) {
            count = minCount;
        }

        if (!root.stop) {
            // 判断现在缓存中的数据个数是否足够，否则去请求更多数据
            var cacheLength = internal.cache ? internal.cache.length : 0;
            if (cacheLength < root.count) {
                if (root.hasMoreData && !queryDataProvider.isRequested) {
                    var params = Util.assign({}, root.params);
                    var requestCount = root.count - cacheLength;
                    //            if (internal.cache.length > 0) {
                    //                params.end_time = DateUtil.moment.unix(internal.cache[0].ShiJian).format('YYYYMMDD-HHmmss');
                    //            } else {
                    params.start = -(cacheLength + requestCount);
                    //            }
                    params.count = requestCount;
                    queryDataProvider.params = params;

                    // 取消上次请求后再请求
                    queryDataProvider.cancel();
                    queryDataProvider.query();
                    //                return;
                    //            } else {

                    //                // 修改个数
                    //                root.count = internal.cache.length;
                }
            }
            root.emitData();
        }
    }

    function updateCache(data, subscribe) {

        // 更新缓存数据后触发success信号
        var cache = internal.cache;
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
                var eachData;
                for (i = data.length; i > 0; i--) {
                  eachData = data[i - 1];
                  if (eachData.ShiJian < startTime) {
                    cache.unshift(eachData);
                  } else {
                    root.hasMoreData = false;
                    break;
                  }
                }
            }
        }
        internal.cache = cache;

//        if (cache.length < count) {
//            root.hasMoreData = false;
//        }

        root.emitData();
    }

    function emitData() {
        if (internal.cache) {
            var data = internal.cache.slice(-root.count);
            root.success(data);
        }
    }

    function addChart(chart) {
        if (charts.indexOf(chart) === -1) {
            charts = charts.concat([chart]);
        }
    }

    QtObject {
        id: internal
        property var cache

        function getStorageKey() {
            return root.serviceUrl + '_' + JSON.stringify(root.params);
        }

        onCacheChanged: {
            if (cache) {

                // cache变化直接存储到本地缓存
                ChartLocalStorage.setItem(internal.getStorageKey(), {cache: cache, hasMoreData: hasMoreData});
            }
        }
    }
}
