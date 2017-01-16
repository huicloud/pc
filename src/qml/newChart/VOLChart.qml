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

import "../js/Util.js" as Util

BaseChart {
    id: root

    property real bottomY: yAxis.getY(0)

    topComponent: null

    function _redraw() {
        figureData = [];

        // 当宽度小于一定宽度时，考虑画出的线间距过小，实际是会互相覆盖，因此这种情况实际没有必要每个数据都画出图形
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var nextChartData;

        var drawVOL = width > 4 ? root.drawVOL : root.drawVOLLine;

        var chartData = root.chartData;

        var isUp = root.isUp;

        // 将interval按条件分开处理，避免循环中做重复判断
        if (interval === 1) {
            chartData.forEach(function(eachData, index) {
                var lastClose = eachData.lastClose;

                // 添加数据附加属性
                if (!lastClose) {
                    lastClose = eachData.lastClose = index > 0 ? chartData[index - 1].ShouPanJia : 0;
                    eachData.isUp = isUp(eachData.KaiPanJia, eachData.ShouPanJia, lastClose);
                }
                drawVOL(eachData.ShiJian, eachData.ChengJiaoLiang, eachData.isUp, width);
            });
        } else {
            chartData.forEach(function(eachData, index) {
                var lastClose = eachData.lastClose;

                // 添加数据附加属性
                if (!lastClose) {
                    lastClose = eachData.lastClose = index > 0 ? chartData[index - 1].ShouPanJia : 0;
                    eachData.isUp = isUp(eachData.KaiPanJia, eachData.ShouPanJia, lastClose);
                }

                if (index % interval === 0 && nextChartData) {
                    drawVOL(nextChartData.ShiJian, nextChartData.ChengJiaoLiang, nextChartData.isUp);
                    nextChartData = null;
                }
                if (nextChartData) {
                    if (eachData.ChengJiaoLiang > nextChartData.ChengJiaoLiang) {
                        nextChartData = eachData;
                    }
                } else {
                    nextChartData = eachData;
                }
            });

            // 画出最后一个数据
            if (nextChartData) {
                drawVOL(nextChartData.ShiJian, nextChartData.ChengJiaoLiang, nextChartData.isUp);
            }
        }
    }

    function drawVOL(time, volume, isUp, width) {
        var y = yAxis.getY(volume);
        var height = bottomY - y;
        if (y % 1 >= 0.5 && height % 1 >= 0.5) {
            height++;
        }

        if (height > 0) {
            var color = isUp ? upColor : downColor;
            var x = xAxis.getLeftX(time);

            var rectFigure = {
                name: 'Rect',
                x: x,
                y: bottomY,
                width: width,
                height: -height,
                strokeStyle: color,
                fillStyle: isUp ? '#ffffff' : color,
                lineWidth: defaultLineWidth
            }
            figureData.push(rectFigure);
            canvas.draw(rectFigure);
        }
    }

    function drawVOLLine(time, volume, isUp) {
        var y = yAxis.getY(volume);
        var height = bottomY - y;
        if (y % 1 >= 0.5 && height % 1 >= 0.5) {
            height++;
        }

        if (height > 0) {
            var color = isUp ? upColor : downColor;
            var x = xAxis.getCenterX(time);
            var lineFigure = {
                name: 'Line',
                x1: x,
                y1: y,
                x2: x,
                y2: bottomY,
                lineWidth: defaultLineWidth,
                style: color
            }
            figureData.push(lineFigure);
            canvas.draw(lineFigure);
        }
    }

    function isUp(open, close, lastClose) {
      return open !== close ? close > open : close > lastClose;
    }

    function getYTickLabel(value) {
        return Util.formatStockText(value / stock.volumeUnit, 2, '万/亿', false);
    }

    function getRange() {
        var max = Number.MIN_VALUE;
        var maxFun = Math.max;
        chartData.forEach(function(eachData) {
            max = maxFun(max, eachData.ChengJiaoLiang);
        });
        return [max + (max) * 0.1, 0];
    }
}
