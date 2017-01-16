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

IndicatorChart {
    id: root

    tabTitle: 'MACD'

    property color deaColor: theme.macdChartDEAColor
    property color diffColor: theme.macdChartDIFFColor

    name: 'MACD'
    parameter: 'SHORT=12,LONG=26,M=9'

    rangeJieGuoField: [0, 1, 2]

    topComponentModel: {
        var macdData = root.indexData ? root.indexData.JieGuo : [];
        var diff = macdData[0];
        var dea = macdData[1];
        var macd = macdData[2];

        return [['MACD(12，26，9)', NaN, textColor], ['MACD：', macd, macd > 0 ? upColor : downColor], ['DIFF：', diff, diffColor], ['DEA：', dea, deaColor]].map(function(eachData) {
            return {
                text: [eachData[0], Util.formatStockText(eachData[1], 3, null, '')].join(''),
                color: eachData[2]
            }
        });
    }

    function _redraw() {

        var figureData = root.figureData = [];
        var canvas = root.canvas;

        var diffPoints = [];
        var deaPoints = [];
        var middleY = yAxis.getY(0);

        // TODO 省略部分点的算法需仔细考虑
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var defaultLineWidth = root.defaultLineWidth;

        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;
        var upColor = root.upColor;
        var downColor = root.downColor;

        chartData.forEach(function(eachData, index) {
            if (index % interval !== 0) {
                return;
            }

            var x = getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                var macdValue = eachData.JieGuo[2];
                var lineFigure = {
                    name: 'Line',
                    x1: x,
                    y1: middleY,
                    x2: x,
                    y2: getY(macdValue),
                    lineWidth: defaultLineWidth,
                    style: macdValue > 0 ? upColor : downColor
                }
                figureData.push(lineFigure);
                canvas.draw(lineFigure);

                diffPoints.push([x, getY(eachData.JieGuo[0])]);
                deaPoints.push([x, getY(eachData.JieGuo[1])]);
            }
        });

        drawPath(diffPoints, diffColor);
        drawPath(deaPoints, deaColor);
    }

    function getYTicks(max, min, yOffset, height, minHeightPerTick) {
        return getYTicksAbsMax(max, min, yOffset, height, minHeightPerTick);
    }

    function getRange() {
        return getRangeAbsMax();
    }
}
