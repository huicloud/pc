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

DataProvider {
    id: root
    serviceUrl: '/quote/min'
    autoQuery: false
    cacheLevel: 0
    sub: 1
    property var charts: []
    property bool stop: !root.charts.some(function(eachChart) {return eachChart.visible})

    property bool _auction: true
    property bool auction: root._auction

    onAuctionChanged: {

        // 重新设置分时时间
        var cache = internal.cache;
        if (cache) {
            cache.minTimes = internal.getMinTimes(cache._minTimes, cache._auctionIndex);

            // 重画chart
            charts.forEach(function(chart) {
                chart.cache = cache;
                chart.canvas.requestPaint();
            });
        }
    }

    function _query() {

        // 如果缓存存在则请求指定时间后的数据
        var cache = internal.cache;
        if (!cache) {

            // 从本地存储中取出缓存数据
            cache = ChartLocalStorage.getItem(internal.getStorageKey());
            if (cache) {
                internal.cache = cache;

                // 取到缓存数据后判断缓存数据中是否包括集合竞价后数据
                if (cache.hasOwnProperty(cache._minTimes[cache._auctionIndex])) {
                    root._auction = false;
                }
                cache.minTimes = internal.getMinTimes(cache._minTimes, cache._auctionIndex);
            }
        }
        if (cache && cache.lastTime) {

            // 取cache数据中最后一条数据的时间作为开始时间订阅最新的数据
            root.params.begin_time = DateUtil.moment.unix(cache.lastTime).format('YYYYMMDD-HHmmss');
        }

        // 初始请求
        root.query();
    }

    function adapt(data) {
        var cache = internal.cache;
        data = data[0];

        // 得到清盘标志或者缓存中的日期变化，清除缓存
        if (data.QingPan === 1 || (cache && data.RiQi && cache.date !== data.RiQi)) {
            cache = null;
        }

        // 初始缓存数据(交易时间段)
        if (!cache) {
            cache = internal.getMinInitData(data);
        }

        // 更新数据
        data = data.Data;
        if (data && data.length > 0) {
            data.forEach(function(eachData) {
                var time = eachData.ShiJian;
                internal.updateMinData(cache, time, eachData);
            });
        }

        internal.cache = cache;
        return cache;
    }

    function addChart(chart) {
        if (charts.indexOf(chart) === -1) {
            charts = charts.concat([chart]);
        }
    }

    // 清理缓存
    function clear() {
        root.cancel();
        internal.cache = null;
    }

    onStopChanged: {
        if (stop) {
            clear();
        } else {
            _query();
        }
    }

    // 查询参数变了则，清除缓存后重新查询
    onParamsChanged: {
        root.clear();
        if (!root.stop) {
            root._query();
        }
    }

    QtObject {
        id: internal
        property var cache;

        onCacheChanged: {
            if (cache) {

                // cache变化直接存储到本地缓存
                ChartLocalStorage.setItem(internal.getStorageKey(), cache);
            }
        }

        readonly property var defaultTimeInfo: {
            var now = new Date();
            var year = now.getFullYear();
            var month = ('0' + (now.getMonth() + 1)).slice(-2);
            var day = ('0' + now.getDate()).slice(-2);
            var date = [year, month, day].join('');
            return {
                RiQi: date,
                JiaoYiShiJianDuan: [
                    {
                        KaiShiShiJian: '0930',
                        JieShuShiJian: '1130',
                        KaiShiRiQi: date,
                        JieShuRiQi: date
                    },
                    {
                        KaiShiShiJian: '1300',
                        JieShuShiJian: '1500',
                        KaiShiRiQi: date,
                        JieShuRiQi: date
                    }
                ],
                JiHeJingJiaDianShu: 15,
                ShiQu: 8,
                ZuoShou: 0
            };
        }
        readonly property int oneMinute: 1 * 60;
        readonly property int oneDay: 1 * 24 * 60 * oneMinute;

        function getStorageKey() {
            return root.serviceUrl + '_' + root.params.obj;
        }

        function getTime(date, hourMinute, timeZone) {
          date = date + '';
          var year = parseInt(date.substr(0, 4));
          var month = parseInt(date.substr(4, 2)) - 1;
          var day = parseInt(date.substr(6, 2));
          var hour = parseInt(hourMinute / 100) - timeZone;
          var minute = hourMinute % 100;
          return Date.UTC(year, month, day, hour, minute) / 1000;
        }

        function getMinInitData(timeInfo) {
            if (!timeInfo || !timeInfo.JiaoYiShiJianDuan) {
                timeInfo = defaultTimeInfo;
            }
            var times = timeInfo.JiaoYiShiJianDuan;
            var timeZone = timeInfo.ShiQu;
            var result = {
                lastClose: timeInfo.ZuoShou,
                date: timeInfo.RiQi
            };
            var minTimes = result._minTimes = [];

            if (times && times.length > 0) {
                var lastTime = 0;
                var startTime;
                var endTime;
                times.forEach(function (eachTime, index) {
                    startTime = getTime(eachTime.KaiShiRiQi, eachTime.KaiShiShiJian, timeZone);
                    endTime = getTime(eachTime.JieShuRiQi, eachTime.JieShuShiJian, timeZone);

                    // 跨天
                    if (endTime < startTime) {
                        endTime += oneDay;
                    }
                    if (startTime < lastTime) {
                        startTime += oneDay;
                        endTime += oneDay;
                    }

                    // 跳过除第一段时间的开始时间
                    if (index > 0) {
                        startTime += oneMinute;
                    }
                    while(startTime <= endTime) {
                        minTimes.push(startTime);
                        startTime += oneMinute;
                    }
                    lastTime = endTime;
                });

                // 集合进价的数据
                var prefixMinute = timeInfo.JiHeJingJiaDianShu || 0;
                startTime = minTimes[0];

                result._auctionIndex = prefixMinute;

                for(var i = 1; i <= prefixMinute; i++) {
                    minTimes.unshift(startTime - (i * oneMinute));
                }
            }

            result.minTimes = getMinTimes(minTimes, result._auctionIndex);
            return result;
        }

        // 根据是否包含集合竞价得到对应的分时时间
        function getMinTimes(minTimes, auctionIndex) {
            var auction = root.auction;
            return minTimes.filter(function(eachTime, index) {
                return auction || index >= auctionIndex;
            });
        }

        function updateMinData(minCache, time, data) {
            var minTimes = minCache._minTimes || [];
            var auctionIndex = minCache._auctionIndex;
            var index = minTimes.indexOf(time);
            if (index >= 0) {
                minCache[time] = data;

                // 如果更新数据为集合竞价后第一个数据时，将集合竞价auction设置为false
                if (index === auctionIndex) {
                    root._auction = false;
                    if (!internal.cache) {
                        minCache.minTimes = getMinTimes(minTimes, auctionIndex);
                    }
                }
            } else {

                // 没有对应时间时，认为交易日期有跨越，对应修正交易时间数据
                var firstTime = minTimes[0];
                var overDays = parseInt((time - firstTime) / oneDay);
                var overTime = overDays * oneDay;
                index = minTimes.indexOf(time - overTime);

                // 找到跨越时间点将之后的数据统一修改日期到数据对应的日期
                if (index >= 0) {
                    while(index < minTimes.length) {
                        var oldTime = minTimes[index];
                        oldTime += overTime;
                        minTimes[index] = oldTime;
                        index++;
                    }
                    minCache[time] = data;
                }
            }
            minCache.lastTime = time;
        }
    }
}
