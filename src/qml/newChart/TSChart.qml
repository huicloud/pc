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

import "../components"
import "../js/Util.js" as Util

IndicatorChart {
    id: root

    property color upNumberColor: theme.tsChartUpNumberColor
    property color downNumberColor: theme.tsChartDownNumberColor
    property color upLineColor: theme.tsChartUpLineColor
    property color downLineColor: theme.tsChartDownLineColor
    property color buySignalColor: theme.tsChartBuySignalColor
    property color sellSignalColor: theme.tsChartSellSignalColor

    tabTitle: '九转指标'

    name: 'TS'

    chartType: chart_type_attach

    // 限制沪深A股、基金、指数
    availability: obj.match(/^[SH|SZ]/)

    // 限制日K
    skip: period !== '1day'

    // 保证提前加载选股窗口
    property bool stockSelectionWindowInited: SingletonStockSelectionWindow.inited

    property var customButtons: [
        {
            text: '红九选股',
            triggered: function() {
                SingletonStockSelectionWindow.openWindow(appConfig.webUrlMap['hongjiu']);
            }
        }, {
            text: '绿九选股',
            triggered: function() {
                SingletonStockSelectionWindow.openWindow(appConfig.webUrlMap['lvjiu']);
            }
        }
    ]

    topComponentModel: {
        if (skip) {
            return [{ text: '本指标仅适用于日K线周期', color: theme.textColor }];
        } else {
            var tsData = root.indexData ? root.indexData.JieGuo : [];
            var upLinePrice = tsData[2] || NaN;
            var downLinePrice = tsData[3] || NaN;

            return [['上升压力位：', upLinePrice, upLineColor], ['下降阻力位：', downLinePrice, downLineColor]].map(function(eachData) {
                return {
                    text: [eachData[0], Util.formatStockText(eachData[1], stock.precision, null)].join(''),
                    color: eachData[2]
                }
            });
        }
    }

    function _redraw() {
        var figureData = root.figureData = [];
        var canvas = root.canvas;
        var klineChartData = canvas.mainChart.chartData;

        var upLineData, downLineData;
        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getValidY;
        var getTextFigure = root.getTextFigure;
        var drawDotLine = root.drawDotLine;
        var drawBuySignal = root.drawBuySignal;
        var drawSellSignal = root.drawSellSignal;
        var upNumberColor = root.upNumberColor;
        var downNumberColor = root.downNumberColor;
        var upLineColor = root.upLineColor;
        var downLineColor = root.downLineColor;
        var fontSize = root.fontSize;


        var klineMap = {};
        klineChartData.forEach(function(eachData) {
            klineMap[eachData.ShiJian] = eachData;
        });

        var timeMap = {};
        chartData.forEach(function(eachData, index) {
            var time = eachData.ShiJian;
            var x = getCenterX(time);
            timeMap[eachData.ShiJian] = eachData;

//            // FIXME 需要考虑数据下标不一致的情况
//            var klineData = klineChartData[index];
            var klineData = klineMap[time];

            var numberFigure;
            if (!isNaN(x) && klineData) {
                var data = eachData.JieGuo;
                var number = data[1];
                var upLineValue = data[2];
                var downLineValue = data[3];
                var buySellSignal = data[4];

                var y, color;

                if (number) {
                    if (number > 0) {

                        // 上涨序列
                        y = getY(klineData.ZuiGaoJia) - 2;
                        color = upNumberColor;
                    } else {

                        // 下跌序列
                        y = getY(klineData.ZuiDiJia) + fontSize + 2;
                        color = downNumberColor;
                    }

                    numberFigure = getTextFigure(Math.abs(number), x, y, color);
                    figureData.push(numberFigure);
                    canvas.draw(numberFigure);
                }
                if (upLineData) {
                    if (upLineData[0] === upLineValue) {
                        upLineData[2] = x;
                    } else {
                        drawDotLine(upLineData[1], upLineData[2], getY(upLineData[0]), upLineColor);
                        upLineData = null;
                    }
                } else if (upLineValue) {
                    upLineData = [upLineValue, x, x];
                }

                if (downLineData) {
                    if (downLineData[0] === downLineValue) {
                        downLineData[2] = x;
                    } else {
                        drawDotLine(downLineData[1], downLineData[2], getY(downLineData[0]), downLineColor);
                        downLineData = null;
                    }
                } else if (downLineValue) {
                    downLineData = [downLineValue, x, x];
                }

                if (buySellSignal === -1) {
                    y = getY(klineData.ZuiDiJia) + 2;
                    if (number < 0) {
                        y += fontSize;
                    }

                    drawBuySignal(x, y);
                } else if (buySellSignal === 1) {
                    y = getY(klineData.ZuiGaoJia) - 2;
                    if (number > 0) {
                        y -= fontSize;
                    }
                    drawSellSignal(x, y);
                }
            }
        });
        if (upLineData) {
            drawDotLine(upLineData[1], upLineData[2], getY(upLineData[0]), upLineColor);
        }
        if (downLineData) {
            drawDotLine(downLineData[1], downLineData[2], getY(downLineData[0]), downLineColor);
        }
        root.timeMap = timeMap;
    }

    function getTextFigure(text, x, y, color) {
        return {
            name: 'Text',
            text: text,
            x: x,
            y: y,
            fontStyle: fontStyle,
            fillStyle: color,
            align: 'center',
        };
    }

    function drawDotLine(x1, x2, y, color) {
        if (isNaN(y)) {
            return;
        }

        var figureData = root.figureData;
        var canvas = root.canvas;
        var lineWidth = defaultLineWidth;
        var count = Math.floor((x2 - x1) / 8);

        // 两个端点
        [x1, x2].forEach(function(x) {
            var circleFigure = {
                name: 'Circle',
                x: x,
                y: y,
                radius: 2,
                fillStyle: color,
                strokeStyle: color,
                lineWidth: 0
            };
            figureData.push(circleFigure);
            canvas.draw(circleFigure);
        });
        if (count < 2) {

            // 直接画出实线
            var lineFigure = {
                name: 'Line',
                x1: x1,
                y1: y,
                x2: x2,
                y2: y,
                lineWidth: lineWidth,
                style: color
            };
            figureData.push(lineFigure);
            canvas.draw(lineFigure);
        } else {
            var perLength = (x2 - x1) / ((count * 2) - 1)
            for (var i = 0; i < count; i++) {
                var dotineFigure = {
                    name: 'Line',
                    x1: x1 + i * 2 * perLength,
                    y1: y,
                    x2: x1 + (i * 2 + 1) * perLength,
                    y2: y,
                    lineWidth: lineWidth,
                    style: color
                };
                figureData.push(dotineFigure);
                canvas.draw(dotineFigure);
            }
        }
    }

    function drawBuySignal(x, y) {
        var pathFigure = {
            name: 'Path',
            points: [[x, y], [x + 4, y + 4], [x + 2, y + 4], [x + 2, y + 10], [x - 2, y + 10], [x - 2, y + 4], [x - 4, y + 4]],
            lineWidth: 0,
            strokeStyle: buySignalColor,
            fillStyle: buySignalColor
        };
        figureData.push(pathFigure);
        canvas.draw(pathFigure);
    }
    function drawSellSignal(x, y) {
        var pathFigure = {
            name: 'Path',
            points: [[x, y], [x + 4, y - 4], [x + 2, y - 4], [x + 2, y - 10], [x - 2, y - 10], [x - 2, y - 4], [x - 4, y - 4]],
            lineWidth: 0,
            strokeStyle: sellSignalColor,
            fillStyle: sellSignalColor
        };
        figureData.push(pathFigure);
        canvas.draw(pathFigure);
    }

    function getRange() {
        return [Number.MIN_VALUE, Number.MAX_VALUE];
    }
}
