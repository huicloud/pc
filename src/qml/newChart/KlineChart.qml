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

import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

BaseChart {
    id: root

    property string obj: canvas.obj
    property string period: canvas.period
    property int split: canvas.split
    property var stock: canvas.stock

    property real klineLineMaxWidth: 1
    property real klineLineMinWidth: 1 / canvas.devicePixelRatio

    property real maxPrice
    property real minPrice
    property bool maxMarked
    property bool minMarked

    chartType: chart_type_main

    flex: 2

    xAxis: XAxis {

        // 主图
        chart: root

        canvas: root.canvas

        count: dataProvider.count

        lastOffset: dataProvider.lastOffset
    }

    dataProvider: KlineChartDataProvider {
        parent: root
        serviceUrl: '/quote/kline'
        params: ({
                     obj: root.obj,
                     period: root.period,
                     split: root.split
                 })
        chart: root

        requestOffsetPosition: xAxis.requestOffsetPosition
    }

    property var tooltipData: chartData[xAxis.mouseIndex]
    onTooltipDataChanged: {
        var tooltipData = root.tooltipData;
        if (tooltipData) {
            var lastClose = tooltipData.lastClose || (chartData[xAxis.mouseIndex - 1] ? chartData[xAxis.mouseIndex - 1].ShouPanJia : 0);
            var precision = stock.precision;
            var volumeUnit = stock.volumeUnit;
            var share = stock.share;
            root.tooltipComponentModel = [
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
                            baseValue: lastClose,
                            precision: precision
                        },
                        {
                            label: '最高价',
                            value: tooltipData.ZuiGaoJia,
                            isAutoFormat: true,
                            baseValue: lastClose,
                            precision: precision
                        },
                        {
                            label: '最低价',
                            value: tooltipData.ZuiDiJia,
                            isAutoFormat: true,
                            baseValue: lastClose,
                            precision: precision
                        },
                        {
                            label: '收盘价',
                            value: tooltipData.ShouPanJia,
                            isAutoFormat: true,
                            baseValue: lastClose,
                            precision: precision
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
                            value: (tooltipData.ShouPanJia || 0) - (lastClose || 0),
                            isAutoFormat: true,
                            baseValue: 0,
                            defaultText: '0.00',
                            precision: precision
                        },
                        {
                            label: '涨跌幅',
                            value: ((tooltipData.ShouPanJia || 0) - (lastClose || 0)) / (lastClose || 1),
                            isAutoFormat: true,
                            baseValue: 0,
                            unit: '%',
                            defaultText: '0.00%',
                            visible: !!lastClose
                        },
                        {
                            label: '振幅',
                            value: ((tooltipData.ZuiGaoJia || 0) - (tooltipData.ZuiDiJia || 0)) / (lastClose || 1),
                            color: '#3e6ac5',
                            unit: '%',
                            defaultText: '0.00%',
                            visible: !!lastClose
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
        } else {
            root.tooltipComponentModel = [];
        }
    }

    topComponentModel: [
        {
            text: {'1min': '1分钟K线', '5min': '5分钟K线', '15min': '15分钟K线', '30min': '30分钟K线', '60min': '60分钟K线',
                '1day': '日K线', 'week': '周K线', 'month': '月K线', 'season': '季K线', 'halfyear': '半年K线', 'year': '年K线'}[root.period],
            color: textColor
        }
    ]

    function _redraw() {
        figureData = [];

        maxMarked = false;
        minMarked = false;

        // 当宽度小于一定宽度时，考虑画出的线间距过小，实际是会互相覆盖，因此这种情况实际没有必要每个数据都画出图形
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;
        var lineWidth = Math.max(klineLineMinWidth, Math.min(klineLineMaxWidth, width));

        var chartData = root.chartData;
        var nextChartData;
        var drawCandle = root.drawCandle;
        var isUpFunction = root.isUp;

        // 将interval按条件分开处理，避免循环中做重复判断
        if (interval === 1) {
            chartData.forEach(function(eachData, index) {
                var lastClose = eachData.lastClose;

                // 添加数据附加属性
                if (!lastClose) {
                    lastClose = eachData.lastClose = index > 0 ? chartData[index - 1].ShouPanJia : 0;
                    eachData.isUp = isUpFunction(eachData.KaiPanJia, eachData.ShouPanJia, lastClose);
                }
                drawCandle(eachData.ShiJian, eachData.KaiPanJia, eachData.ShouPanJia, eachData.ZuiGaoJia, eachData.ZuiDiJia, eachData.isUp, width, lineWidth);
            });
        } else {
            chartData.forEach(function(eachData, index) {
                var lastClose = eachData.lastClose;

                // 添加数据附加属性
                if (!lastClose) {
                    lastClose = eachData.lastClose = index > 0 ? chartData[index - 1].ShouPanJia : 0;
                    eachData.isUp = isUpFunction(eachData.KaiPanJia, eachData.ShouPanJia, lastClose);
                }

                if (index % interval === 0 && nextChartData) {
                    var isUp = isUpFunction(nextChartData[1], nextChartData[2], nextChartData[5]);
                    drawCandle(nextChartData[0], nextChartData[1], nextChartData[2], nextChartData[3], nextChartData[4], isUp, width, lineWidth);
                    nextChartData = null;
                }
                if (nextChartData) {
                    nextChartData[2] = eachData.ShouPanJia;
                    nextChartData[3] = nextChartData[3] > eachData.ZuiGaoJia ? nextChartData[3] : eachData.ZuiGaoJia;
                    nextChartData[4] = nextChartData[4] < eachData.ZuiDiJia ? nextChartData[4] : eachData.ZuiDiJia;
                } else {
                    nextChartData = [eachData.ShiJian, eachData.KaiPanJia, eachData.ShouPanJia, eachData.ZuiGaoJia, eachData.ZuiDiJia, lastClose];
                }
            });

            // 画出最后一个数据
            if (nextChartData) {
                var isUp = isUpFunction(nextChartData[1], nextChartData[2], nextChartData[5]);
                drawCandle(nextChartData[0], nextChartData[1], nextChartData[2], nextChartData[3], nextChartData[4], isUp, width, lineWidth);
            }
        }
    }

    function drawCandle(time, open, close, top, low, isUp, width, lineWidth) {
        var xAxis = root.xAxis;
        var getY = root.yAxis.getY;
        var centerX = xAxis.getCenterX(time);
        var color = isUp ? upColor : downColor;

        // 上下影线
        var x1 = centerX;
        var y1 = getY(top);
        var y2 = getY(low);

        var lineFigure = {
            name: 'Line',
            x1: x1,
            y1: y1,
            x2: x1,
            y2: y2,
            lineWidth: lineWidth,
            style: color
        }
        figureData.push(lineFigure);
        canvas.draw(lineFigure);

        if (width > 1) {
//            var leftX = xAxis.getLeftX(time);
            var leftX = centerX - width / 2;
            if (x1 % 1 < 0.5) {
                width += 0.5;
            }
            var openY = getY(open);
            var closeY = getY(close);
            var height = (open === close ? 1 : (closeY - openY));

            var rectFigure = {
                name: 'Rect',
                x: leftX,
                y: openY,
                width: width,
                height: height,
                strokeStyle: color,
                fillStyle: isUp ? '#ffffff' : color,
                lineWidth: root.defaultLineWidth
            }
            figureData.push(rectFigure);
            canvas.draw(rectFigure);
        }

        // 最大值和最小值显示
        if (!maxMarked && maxPrice === top) {
            markPrice(maxPrice, x1, y1 + fontSize / 2 - 2);
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

    function markPrice(price, x, y) {
        var text = Util.formatStockText(price, stock.precision, null, false);

        // x大于宽度一半时画向右的箭头，否则画向左的箭头
        var align;
        if (x > (xAxis.width / 2 + canvas.leftYAxisWidth)) {
            text += '→';
            align = 'right';
        } else {
            text = '←' + text;
            align = 'left';
        }

        var textFigure = {
            name: 'Text',
            x: x,
            y: y,
            text: text,
            fontStyle: fontStyle,
            fillStyle: textColor,
            align: align,
        }
        figureData.push(textFigure);
        canvas.draw(textFigure);
    }

    function isUp(open, close, lastClose) {
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

    function getYTicks(max, min, yOffset, height, minHeightPerTick) {

        // 初始状态，显示空白网格
        if (max === Number.MIN_VALUE) {
            var count = Math.floor(height / minHeightPerTick);
            var heightPerTick = height / count;
            var ticks = [];

            for (var i = 0; i < count; i++) {
                ticks.push({
                    position: yOffset + heightPerTick * i,
                    value: 0,
                    label: getYTickLabel(0)
                });
            }
            return ticks;
        }

        // 尽量取整(5,10)
        var count = Math.floor(height / minHeightPerTick);
        var diff = max - min;
        var diffPerTick = 0;

        var ratio = 1;
        if (diff > 10000) {
            ratio = 1000;
        } else if (diff > 1000) {
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
        var ticks = [];
        var bottomY = yOffset + height;

        for (var i = 0; i < count; i++) {
            var position = maxPosition + heightPerTick * i;

            // 避免超出图的高度
            if (position > bottomY) {
                break;
            }

            var value = maxTick - (diffPerTick * i * ratio);
            ticks.push({
                position: position,
                value: value,
                label: getYTickLabel(value)
            });
        }
        return ticks;
    }

    function getYTickLabel(value) {
        return Util.formatStockText(value, stock.precision, null, false);
    }

    function getRange() {
        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        var maxFun = Math.max;
        var minFun = Math.min;
        chartData.forEach(function(eachData) {
            max = maxFun(max, eachData.ZuiGaoJia);
            min = minFun(min, eachData.ZuiDiJia);
        });

        root.maxPrice = max;
        root.minPrice = min;

        // 范围上下扩大5%
        var yMax = max > min ? max + (max - min) * 0.05 : max * 1.05;
        var yMin = max > min ? min - (max - min) * 0.05 : max * 0.95;
        return [yMax, yMin];
    }
}
