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

import "../controls"
import "../js/Util.js" as Util

IndicatorChart {
    id: root

    property bool close: false

    tabTitle: 'DDZ'
    name: 'DDZ'

    topComponentModel: {
        var ddzData = root.indexData ? root.indexData.JieGuo : [];
        var ddz = ddzData[0];

        return [['DDZ', NaN, textColor], ['DDZ：', ddz, ddz > 0 ? upColor : downColor]].map(function(eachData) {
            return {
                text: [eachData[0], Util.formatStockText(eachData[1], 3, null, '')].join(''),
                color: eachData[2]
            }
        });
    }

    topComponent: TopComponent {
        chart: root
        backgroundColor: 'transparent'
        borderColor: 'transparent'
        model: topComponentModel
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: canvas.leftYAxisWidth
        anchors.top: topComponentLoader.bottom
        text: '大单差分'
    }

    function _redraw() {
        var figureData = root.figureData = [];
        var canvas = root.canvas;

        var width = xAxis.getWidth();

        // TODO 省略部分点的算法需仔细考虑
        // 考虑ddz数据不多，不考虑省略
//        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var defaultLineWidth = root.defaultLineWidth;

        var getCenterX = xAxis.getCenterX;
        var pixelPer = xAxis.pixelPer;
        var getY = yAxis.getY;
        var getDDZFigure = root.getDDZFigure;
        var upColor = root.upColor;
        var downColor = root.downColor;

        var leftXDistance = pixelPer / 2;

        var lastData;
        chartData.forEach(function(eachData, index) {
//            if (index % interval !== 0) {
//                return;
//            }

            // 判断是否当前值是否和上次值的方向相同（正负），相同则可以只画一个相同颜色的图形，不同则需要计算出中点，分别画出上一个点到中点，中点到当前点两个图形
            var currentX = getCenterX(eachData.ShiJian);
            var data = eachData.JieGuo;
            var currentValue = data[0];
            var currentDistance = data[1];
            var currentY1 = getY(currentValue);
            var currentY2 = getY(currentValue + currentDistance);
            var lastValue, lastX, lastY1, lastY2, middleX, middleY1, middleY2, ddzFigure;

            if (!lastData) {
                lastX = currentX - leftXDistance;
                ddzFigure = getDDZFigure([[lastX, currentY1], [lastX, currentY2], [currentX, currentY2], [currentX, currentY1]], currentValue > 0 ? upColor : downColor);
                figureData.push(ddzFigure);
                canvas.draw(ddzFigure);
            } else {
                lastValue = lastData[0];
                lastX = lastData[1];
                lastY1 = lastData[2];
                lastY2 = lastData[3];

                // 方向相同
                if (lastValue * currentValue >= 0) {
                    ddzFigure = getDDZFigure([[lastX, lastY1], [lastX, lastY2], [currentX, currentY2], [currentX, currentY1]], currentValue > 0 ? upColor : downColor);
                    figureData.push(ddzFigure);
                    canvas.draw(ddzFigure);
                } else {

                    // 方向不同
                    middleX = currentX - leftXDistance;
                    middleY1 = lastY1 + (currentY1 - lastY1) / 2;
                    middleY2 = lastY2 + (currentY2 - lastY2) / 2;

                    ddzFigure = getDDZFigure([[lastX, lastY1], [lastX, lastY2], [middleX, middleY2], [middleX, middleY1]], lastValue > 0 ? upColor : downColor);
                    figureData.push(ddzFigure);
                    canvas.draw(ddzFigure);

                    ddzFigure = getDDZFigure([[middleX, middleY1], [middleX, middleY2], [currentX, currentY2], [currentX, currentY1]], currentValue > 0 ? upColor : downColor);
                    figureData.push(ddzFigure);
                    canvas.draw(ddzFigure);
                }
            }
            lastData = [currentValue, currentX, currentY1, currentY2];
        });

        // 画出剩余的图形
        if (lastData) {
            var lastValue = lastData[0];
            var lastX = lastData[1];
            var lastY1 = lastData[2];
            var lastY2 = lastData[3];
            var currentX = lastX + leftXDistance;

            var ddzFigure = getDDZFigure([[lastX, lastY1], [lastX, lastY2], [currentX, lastY2], [currentX, lastY1]], lastValue > 0 ? upColor : downColor);
            figureData.push(ddzFigure);
            canvas.draw(ddzFigure);
        }
    }

    function getDDZFigure(points, color) {
        return {
            name: 'Path',
            points: points,
            lineWidth: 0,
            strokeStyle: color,
            fillStyle: color
        };
    }

    function getYTicks() {
        return [{
                    position: yAxis.getY(0),
                    label: '0.00'
                }];
    }

    function getRange() {
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        var lastTime = root.xAxis.lastTime;
        var timeMap = [];
        var maxFun = Math.max;
        var minFun = Math.min;
        root.chartData = dataProvider.chartData.filter(function(eachData) {
            if (eachData.ShiJian <= lastTime) {
                timeMap[eachData.ShiJian] = eachData;
                var value1 = eachData.JieGuo[0];
                var value2 = eachData.JieGuo[0] + eachData.JieGuo[1];
                max = maxFun(max, value1, value2);
                min = minFun(min, value1, value2);
                return true;
            }
        });
        root.timeMap = timeMap;
        return [max, min];
    }
}
