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

import "../core"
import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

/**
 * 分时图
 */
BaseChart {
    id: minChart

    // 是否是大盘指数（大盘指数分时展示领先指标和多空线）
    property bool index: false

    property bool mini: false

    showYAxis: true

    cache: ({})

    property var topComponentModel: [
        {text: '分时走势', color: theme.textColor},
        {text: '分时', color: '#3e6ac5'},
        {text: minChart.index ? '领先指标' : '均线', color: '#ff8800'},
    ]

    property var tickCount: {
        var count = Math.floor(yAxis.height / yAxis.minHeightPerTick);
        count -= (count % 2 === 1 ? 1 : 0);
        return count;
    }

    z: 100
    onCacheChanged: {
        computeRange();
    }
    onTickCountChanged: {
        computeRange();
    }

    function computeRange() {
        // 计算最大和最小值
        var lastClose = cache.lastClose;
        var MAX_VALUE = Number.MAX_VALUE;
        var MIN_VALUE = Number.MIN_VALUE;
        var min = MAX_VALUE;
        var max = 0;
        var eachData;
        var key

        if (lastClose) {

            // 昨收价存在,取距离昨收价最大偏移量作为最大绝对值
            var maxOffset = 0;
            for (key in cache) {
                eachData = cache[key];
                if (eachData && eachData.ChengJiaoJia) {
                    maxOffset = Math.max(maxOffset, Math.abs(eachData.ChengJiaoJia - lastClose));

                    if (minChart.index && eachData.LingXianZhiBiao) {
                        maxOffset = Math.max(maxOffset, Math.abs(eachData.LingXianZhiBiao - lastClose));
                    }
                }
            }

            // 最大差值需要保证每格的最小刻度
            // 非基金控制涨跌幅最小保证1%
            maxOffset = Math.max(maxOffset, tickCount / 2 / Math.pow(10, stock.precision), stock.isFund ? Number.MIN_VALUE : lastClose * 0.01);

            max = lastClose + maxOffset;
            min = lastClose - maxOffset;
        } else {

            // 昨收价不存在时
            for (key in cache) {
                eachData = cache[key];
                if (eachData && eachData.ChengJiaoJia) {
                    max = Math.max(max, eachData.ChengJiaoJia || MIN_VALUE);
                    min = Math.min(min, eachData.ChengJiaoJia || MAX_VALUE);
                }
            }
        }

        // 根据tickCount上下各扩大 tickCount / 2
        var diffPerCount = (max - (max - min) / 2 - min) * 2 / tickCount;
        var halfDiff = diffPerCount / 2;
        yMax = max + halfDiff;
        yMin = min - halfDiff;


//        // 最大值和最小值范围增加5%
//        yMax = max > min ? max + (max - min) * 0.05 : max * 1.1;
//        yMin = max > min ? min - (max - min) * 0.05 : max * 0.9;
    }

    // 计算分时图右侧栏涨跌幅的精度（默认2位，当显示数据精度小于2返回3位小数精度）
    property int rightRatioPrecision: {
        if (cache && cache.lastClose) {
            var ratioPer = (yMax - yMin) / yAxis.ticks.length / cache.lastClose;
            if (ratioPer > 0 && ratioPer < 0.0001) {
                return 3;
            }
        }
        return 2;
    }

    Connections {
        target: minChart.dataProvider
        onSuccess: {
            cache = data;
            canvas.requestPaint();
        }
    }

    tooltipComponent: ChartTooltip {
        property var tooltipData: cache[xAxis.mouseXData] || {}
        model: [
            {
                label: '时间',
                defaultText: getXTickLabel(xAxis.mouseXData),
                color: '#3e6ac5'
            },
            {
                label: '价格',
                value: tooltipData.ChengJiaoJia,
                isAutoFormat: true,
                baseValue: cache.lastClose,
                precision: stock.precision
            },
            {
                label: index ? '领先' : '均价',
                value: index ? tooltipData.LingXianZhiBiao : tooltipData.JunJia,
                isAutoFormat: true,
                baseValue: cache.lastClose,
                precision: stock.precision
            },
            {
                label: '涨跌',
                value: tooltipData.ChengJiaoJia ? (tooltipData.ChengJiaoJia - cache.lastClose) : 0,
                isAutoFormat: true,
                baseValue: 0,
                precision: stock.precision
            },
            {
                label: '涨幅',
                value: tooltipData.ChengJiaoJia ? (tooltipData.ChengJiaoJia - cache.lastClose) / cache.lastClose : 0,
                isAutoFormat: true,
                baseValue: 0,
                unit: '%'
            },
            {
                label: '成交量',
                value: tooltipData.ChengJiaoLiang / volumeUnit,
                color: '#3e6ac5',
                isAutoPrec: true,
                unit: '万/亿'
            },
            {
                label: '成交额',
                value: tooltipData.ChengJiaoE,
                color: '#3e6ac5',
                unit: '万/亿'
            },
            {
                label: '委卖量',
                value: tooltipData.WeiTuoMaiChuZongLiang / volumeUnit,
                color: '#1ca049',
                isAutoPrec: true,
                unit: '万/亿',

                // 除股票外还有上证和深成指数需要显示委卖量委买量
                visible: stock.type === 1 || ['SH000001', 'SZ399001'].indexOf(stock.obj) >= 0
            },
            {
                label: '委买量',
                value: tooltipData.WeiTuoMaiRuZongLiang / volumeUnit,
                color: '#ee2c2c',
                isAutoPrec: true,
                unit: '万/亿',
                visible: stock.type === 1 || ['SH000001', 'SZ399001'].indexOf(stock.obj) >= 0
            }
        ]
    }

    function initChart() {
        // TODO do nothing
    }

    function drawBackground() {

        // 画出集合竞价背景
        if (cache._minTimes) {
            var auctionEndTime = cache._minTimes[cache._auctionIndex];
            var auctionEndX = xAxis.getCenterX(auctionEndTime);
            if (auctionEndX !== NaN) {
                var auctionStartX = xAxis.getLeftX(cache._minTimes[0]);
                drawRect(auctionStartX, 0 + topSpace, auctionEndX - auctionStartX, chartHeight - bottomSpace, 'transparent', '#f2f5ff');
            }
        }

        xAxis.ticks.forEach(function(tick) {
            drawXAxisGridLine(tick.position);
        });
        var length = yAxis.ticks.length;
        yAxis.ticks.forEach(function(tick, index) {
            if (index === Math.floor(length / 2)) {
                drawYAxisGridLine(tick.position, gridLineWidth, '#AEC1DA');
                return;
            }

            drawYAxisGridLine(tick.position);
        });
    }

    function drawChart() {
        var minTimes = cache.minTimes;
        var pricePoints = [];
        var avgPricePoints = [];
        var leadPricePoints = [];
        var lastClose = cache.lastClose;
        var lastPrice = lastClose;
        var range = yAxis.range;
        var max = range[0];
        var min = range[1];

        if (minTimes) {
            var middleY = topSpace + (chartHeight - topSpace - bottomSpace) / 2;
            minTimes.forEach(function (time, index) {
                var minData = cache[time];
                if (minData) {
                    var isUp = minData.isUp = minData.ChengJiaoJia >= lastPrice;
                    var x = xAxis.getCenterX(time);
                    if (minData.ChengJiaoJia) pricePoints.push([x, yAxis.getY(minData.ChengJiaoJia)]);
                    lastPrice = minData.ChengJiaoJia;

                    if (minChart.index) {
                        if (minData.LingXianZhiBiao) leadPricePoints.push([x, yAxis.getY(minData.LingXianZhiBiao)]);

                        // 多空线
                        if (minData.DuoKongXian && !mini) {
//                            var upDown = max - (max - min) * (1.2 - minData.DuoKongXian) / 2.4;
                            var upDown = max - (max - min) * (1 - minData.DuoKongXian) / 2;//lastClose * (1 + minData.DuoKongXian);

                            // 使用画矩形模拟画线，避免2像数的线发虚
                            var color = minData.DuoKongXian > 0 ? '#f36c6c' : '#61bd80';
                            drawRect(x, middleY, 1, yAxis.getY(upDown) - middleY, color, color);
                            //                            drawLine(x, middleY, x, yAxis.getY(upDown), 2, minData.DuoKongXian > 0 ? '#f36c6c' : '#61bd80');
                        }
                    } else {
                        if (minData.JunJia) avgPricePoints.push([x, yAxis.getY(minData.JunJia)]);
                    }
                }
            });
        }
//        fillPath(pricePoints, topSpace + chartHeight, '#0095D9', 'rgba(0, 149, 217, 0.2)');
        drawPath(pricePoints, '#3e6ac5');

        if (minChart.index) {

            // 领先指标
            drawPath(leadPricePoints, '#ff8800');
        } else {

            // 均价
            drawPath(avgPricePoints, '#ff8800');
        }
    }

    function drawYAxisTicks() {
        var length = yAxis.ticks.length;
        var color = upColor;
        var lastClose = cache.lastClose;
        yAxis.ticks.forEach(function(tick, index) {
            if (index === (length - 1) / 2) {
                color = tickColor;
            } else if (index > length / 2) {
                color = downColor;
            }

            var text = Util.formatStockText(tick.value, stock.precision, null, false);
            if (leftSpace !== 0) {
                drawTextAlignRight(text, leftSpace - 10, tick.position + fontSize / 2, fontSize, color);
            }
            if (rightSpace !== 0) {
                var rightText = Util.formatStockText((tick.value - lastClose) / lastClose, rightRatioPrecision, '%', false);
                drawText(rightText, chartWidth - rightSpace + 10, tick.position + fontSize / 2, fontSize, color);
            }
        });
    }

    function getXTicks(pixelPer) {
        // 满足条件时画出时间轴
        // 不连续时间段的之前时间点
        var _ticks = [];
        var tickIndex;
        var minTimes = cache.minTimes;

        if (minTimes) {
            // 如果数据量大于300个数据则按60分间隔否则按30分间隔
            var length = minTimes.length;
            var interval = length > 300 ? 60 : 30;
            var lastTickIndex = -100;
            minTimes.forEach(function(time, index) {
                if (index > 0 && (time - minTimes[index - 1]) > 1 * 60 && lastTickIndex !== (index - 1)) {
                  tickIndex = index - 1;
                } else if (DateUtil.moment.unix(time).minute() % interval === 0) {
                  tickIndex = index;
                }
                time = minTimes[tickIndex];
                if ((tickIndex - lastTickIndex) * pixelPer > 50) {
                    _ticks.push({
                                    time: time,
                                    xAxisLabel: getXTickLabel(time),
                                    position: leftSpace + ((index + (index === 0 ? 0 : index < length - 1 ? 0.5 : 1)) * pixelPer)
                                });
                  lastTickIndex = tickIndex;
                }
            });
        }
        return _ticks;
    }

    function getXTickLabel(time, detail) {
        return DateUtil.moment.unix(time).format('HH:mm');
    }

    function getYTicks(max, min, height, minHeightPerTick) {
//        if (_max !== _min) {
//            height = height * (_max - _min) / (max - min);
//            var count = Math.floor(height / minHeightPerTick);
//            count -= (count % 2 === 1 ? 1 : 0);
//            var diff = _max - _min;
//            var diffPerTick = diff / (count);
//            var heightPerTick = height / (count);

//            var _ticks = [];
//            var middleValue = max - (max - min) / 2;
//            var middleY = yAxis.getY(middleValue);
//            _ticks.push({
//                            position: middleY,
//                            value: middleValue
//                        });
//            for (var i = 1; i <= count / 2; i++) {
//                _ticks.push({
//                                position: middleY - heightPerTick * i,
//                                value: middleValue - diffPerTick * i
//                            });
//                _ticks.unshift({
//                                   position: middleY + heightPerTick * i,
//                                   value: middleValue + diffPerTick * i
//                               })
//            }
//            return _ticks;
//        } else {

            var count = Math.floor(height / minHeightPerTick);
            count -= (count % 2 === 1 ? 1 : 0);
            var diff = max - min;
            var diffPerTick = diff / (count + 1);
            var heightPerTick = height / (count + 1);

            var _ticks = [];
            for (var i = 0; i <= count; i++) {
                _ticks.push({
                                position: topSpace + heightPerTick * (i + 0.5),
                                value: max - (diffPerTick * (i + 0.5))
                            });
            }

            return _ticks;
//        }
    }

    function drawCrossLineYAxisTick(ctx, value, y) {

        var yLabel = Util.formatStockText(value, stock.precision, null, false);
        var textY = Math.max(Math.min(y + fontSize / 2, chartHeight - fontSize / 2 + 4), topSpace + fontSize + 2);

        // 左边
        if (leftSpace) {
            _drawRect(ctx, 0, textY + 2, leftSpace, -(fontSize + 4), '#3e6ac5', '#3e6ac5');
            _drawText(ctx, yLabel, leftSpace - 10, textY - 2, fontSize, '#ffffff' ,null, 'right');
        }
        if (rightSpace) {
            var rightText = Util.formatStockText((value - cache.lastClose) / cache.lastClose, 2, '%', false);
            _drawRect(ctx, chartWidth, textY + 2, -rightSpace, -(fontSize + 4), '#3e6ac5', '#3e6ac5');
            _drawText(ctx, rightText, chartWidth - rightSpace + 10, textY - 2, fontSize, '#ffffff' ,null, 'left');
        }
    }
}
