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

    property color rsi1Color: theme.rsiChart1Color
    property color rsi2Color: theme.rsiChart2Color
    property color rsi3Color: theme.rsiChart3Color

    tabTitle: 'RSI'
    name: 'RSI'
    parameter: 'N1=6,N2=12,N3=24'

    rangeJieGuoField: [0, 1, 2]

    topComponentModel: {
        var rsiData = root.indexData ? root.indexData.JieGuo : [];
        var rsi1 = rsiData[0];
        var rsi2 = rsiData[1];
        var rsi3 = rsiData[2];

        return [['RSI(6, 12, 24)', NaN, textColor], ['RSI1：', rsi1, rsi1Color], ['RSI2：', rsi2, rsi2Color], ['RSI3：', rsi3, rsi3Color]].map(function(eachData) {
            return {
                text: [eachData[0], Util.formatStockText(eachData[1], 3, null, '')].join(''),
                color: eachData[2]
            }
        });
    }

    function _redraw() {
        figureData = [];
        var rsi1Points = [];
        var rsi2Points = [];
        var rsi3Points = [];

        // TODO 省略部分点的算法需仔细考虑
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;

        chartData.forEach(function(eachData, index) {
            if (index % interval !== 0) {
                return;
            }

            var x = getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                rsi1Points.push([x, getY(eachData.JieGuo[0])]);
                rsi2Points.push([x, getY(eachData.JieGuo[1])]);
                rsi3Points.push([x, getY(eachData.JieGuo[2])]);
            }
        });

        drawPath(rsi1Points, rsi1Color);
        drawPath(rsi2Points, rsi2Color);
        drawPath(rsi3Points, rsi3Color);
    }
}
