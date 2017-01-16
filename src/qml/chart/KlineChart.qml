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

BaseChart {
    id: klineChart

    property string period: '1day'
    property int maxCount: Number.MAX_VALUE
    property int minCount: 10
    property real pixelPer: (width - 60) / (cache.length || 1)

    property real klineLineMaxWidth: 1
    property real klineLineMinWidth: 0.5

    // 流通股本
    property real share: stock.share

    name: 'kline'
    showYAxis: true

    property real maxPrice: Number.MAX_VALUE
    property real minPrice: Number.MIN_VALUE

    onCacheChanged: {

        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        cache.forEach(function(eachData) {
            max = Math.max(max, eachData.ZuiGaoJia);
            min = Math.min(min, eachData.ZuiDiJia);
        });

        maxPrice = max;
        minPrice = min;

        // 范围上下扩大10%
        yMax = max > min ? max + (max - min) * 0.1 : max * 1.1;
        yMin = max > min ? min - (max - min) * 0.1 : max * 0.9;
    }

    Connections {
        target: klineChart.dataProvider
        onSuccess: {
//            console.log(JSON.stringify(data));
            cache = data;
            canvas.requestPaint();
//            console.log(xAxis.data);
//            console.log(yAxis.range);
//            console.log(xAxis.ticks);
//            console.log(yAxis.ticks);
        }
    }

    tooltipComponent: ChartTooltip {
        id: chartTooltip
        property var tooltipData: cache[xAxis._mouseIndex] || {}
        property var lastClose: tooltipData.lastClose || (cache[xAxis._mouseIndex - 1] ? cache[xAxis._mouseIndex - 1].ShouPanJia : 0)

        model: [
            {
                label: '时间',
                defaultText: _getXTickLabel(tooltipData.ShiJian, 2),
                color: '#3e6ac5',
                height: 30
            },
            {
                label: '开盘价',
                value: tooltipData.KaiPanJia,
                isAutoFormat: true,
                baseValue: chartTooltip.lastClose,
                precision: stock.precision
            },
            {
                label: '最高价',
                value: tooltipData.ZuiGaoJia,
                isAutoFormat: true,
                baseValue: chartTooltip.lastClose,
                precision: stock.precision
            },
            {
                label: '最低价',
                value: tooltipData.ZuiDiJia,
                isAutoFormat: true,
                baseValue: chartTooltip.lastClose,
                precision: stock.precision
            },
            {
                label: '收盘价',
                value: tooltipData.ShouPanJia,
                isAutoFormat: true,
                baseValue: chartTooltip.lastClose,
                precision: stock.precision
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
                label: '涨跌',
                value: (tooltipData.ShouPanJia || 0) - (chartTooltip.lastClose || 0),
                isAutoFormat: true,
                baseValue: 0,
                defaultText: '0.00',
                precision: stock.precision
            },
            {
                label: '涨跌幅',
                value: ((tooltipData.ShouPanJia || 0) - (chartTooltip.lastClose || 0)) / (chartTooltip.lastClose || 1),
                isAutoFormat: true,
                baseValue: 0,
                unit: '%',
                defaultText: '0.00%',
                visible: !!chartTooltip.lastClose
            },
            {
                label: '振幅',
                value: ((tooltipData.ZuiGaoJia || 0) - (tooltipData.ZuiDiJia || 0)) / (chartTooltip.lastClose || 1),
                color: '#3e6ac5',
                unit: '%',
                defaultText: '0.00%',
                visible: !!chartTooltip.lastClose
            },
            {
                label: '换手率',

                // 股本数据没有时，换手率数据无法计算
                value: share ? tooltipData.ChengJiaoLiang / share : NaN,
                color: '#3e6ac5',
                unit: '%',
                visible: stock.type === 1,
                defaultText: share ? '0.00%' : '--'
            }
        ]
    }

    property bool maxMarked: false
    property bool minMarked: false

    function initChart() {
        maxMarked = false;
        minMarked = false;
    }

    function drawBackground() {
        xAxis.ticks.forEach(function(tick) {
            drawXAxisGridLine(tick.position);
        });
        yAxis.ticks.forEach(function(tick) {
            drawYAxisGridLine(tick.position);
        });
    }

    function drawChart() {
        cache.forEach(function(eachData, index) {
            var lastClose = eachData.lastClose;

            // 添加数据附加属性
            if (!lastClose) {
                lastClose = eachData.lastClose = index > 0 ? cache[index - 1].ShouPanJia : 0;
//                eachData.time = eachData.ShiJian * 1000;
                eachData.isUp = isUp(eachData.KaiPanJia, eachData.ShouPanJia, lastClose);
//                eachData.xAxisLabel = getXTickLabel(eachData.time);
            }

            drawCandle(eachData.ShiJian, eachData.KaiPanJia, eachData.ShouPanJia, eachData.ZuiGaoJia, eachData.ZuiDiJia, eachData.isUp);
        });
    }

    function drawCandle(time, open, close, top, low, isUp) {
        var leftX = xAxis.getLeftX(time);
        var centerX = xAxis.getCenterX(time);
        var width = xAxis.getWidth();
        var color = isUp ? upColor : downColor;

        // 上下影线
        var x1 = centerX;
        var y1 = yAxis.getY(top);
        var y2 = yAxis.getY(low);

        drawLine(x1, y1, x1, y2, Math.max(klineLineMinWidth, Math.min(klineLineMaxWidth, width)), color);

        if (width > 1) {
            if (x1 % 1 < 0.5) {
                width += 0.5;
            }
            var openY = yAxis.getY(open);
            var closeY = yAxis.getY(close);
            var height = (open === close ? 1 : (closeY - openY));

            // 画矩形
            drawRect(leftX, openY, width, height, color, isUp ? '#ffffff' : color);
        }

        // 最大值和最小值显示
        if (!maxMarked && maxPrice === top) {
            markPrice(maxPrice, x1, y1);
            maxMarked = true;

            // 如果最大值小于最小值同时设置最小值已标记
            if (maxPrice === minPrice) {
                minMarked = true;
            }
        }
        if (!minMarked && minPrice === low) {
            markPrice(minPrice, x1, y2 + fontSize / 2);
            minMarked = true;
        }
    }

    function markPrice(price, x, y, color) {
        price = Util.formatStockText(price, stock.precision, null, false);

        // x大于宽度一半时画向右的箭头，否则画向左的箭头
        if (x > ((chartWidth - leftSpace - rightSpace) / 2 + leftSpace)) {
            price += '→';
            x -= ctx.measureText(price).width;
        } else {
            price = '←' + price;
        }

        drawText(price, x, y, fontSize, '#555');
    }

    function isUp(open, close, lastClose) {

      // FIXME 还需要考虑当天收盘和昨收相同的情况
      return open !== close ? close > open : close > lastClose;
    }

    function getXTickLabel(time, detail) {
        return _getXTickLabel(time, detail ? 1 : 0);
    }

    // type === 1用于显示光标对应的时间，type === 2用于显示在提示框中的时间
    function _getXTickLabel(time, type) {
        type = type || 0;
        var format = 'MM/DD';
        switch (period) {
            case '1min':;
            case '5min':;
            case '15min':;
            case '30min':;
            case '60min': format = ['MM/DD', 'HH:mm', 'MM/DD HH:mm'][type]; break;
            case '1day':;
            case 'week':;
            case 'month':;
            case 'season':;
            case 'halfyear':;
            case 'year': format = ['YYYY/MM', 'YYYY/MM/DD', 'YYYY MM/DD'][type]; break;
        }
        return DateUtil.moment.unix(time).format(format);
    }

    function getXTicks(pixelPer) {

        // x轴按照时间规则分ticks
        var _ticks = [], lastLabel, currentLabel, lastIndex = 0;
        cache.forEach(function(eachData, index) {
            currentLabel = eachData.xAxisLabel;
            if (!currentLabel) {
                currentLabel = eachData.xAxisLabel = getXTickLabel(eachData.ShiJian);
            }

            if (currentLabel !== lastLabel) {
                lastLabel = currentLabel;
                if ((index - lastIndex) * pixelPer > 80) {
                    _ticks.push({
                                   time: eachData.ShiJian,
                                   xAxisLabel: currentLabel,
                                   position: leftSpace + (index * pixelPer) + pixelPer / 2
                               });
                    lastIndex = index;
                }
            }
        });
        return _ticks;
    }

    function getYTicks(max, min, height, minHeightPerTick) {

        // 尽量取整(5,10)
        var count = Math.floor((height - topSpace - bottomSpace) / minHeightPerTick);
        var diff = max - min;
        var diffPerTick = 0;

        var ratio = 1;
        if (diff > 1000) {
            ratio = 100;
        } else if (diff > 100) {
            ratio = 10;
        } else if (diff < 10) {
            ratio = 0.1
        }

        diff = diff / ratio;

        diffPerTick = (diff / count) || 0;
        if (diffPerTick <= 1) {
            diffPerTick = 1;
        } else if (diffPerTick <= 2) {
            diffPerTick = 2;
        } else if (diffPerTick <= 5) {
            diffPerTick = 5;
        } else {
            diffPerTick = 10;
        }

        count = Math.ceil(diff / diffPerTick);
        var maxTick = Math.floor(max / ratio) * ratio;
        var maxPosition = yAxis.getY(maxTick);

        var minTick = maxTick - count * diffPerTick * ratio;
        var minPosition = yAxis.getY(minTick);

        var heightPerTick = Math.abs(minPosition - maxPosition) / count;
        var _tick = [];

        for (var i = 0; i < count; i++) {
            _tick.push({
                position: maxPosition + heightPerTick * i,
                value: maxTick - (diffPerTick * i * ratio)
            });
        }
        return _tick;
    }

    function getYTickLabel(value) {
        return Util.formatStockText(value, stock.precision, null, false);
    }
}
