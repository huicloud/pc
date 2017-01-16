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

    tabTitle: 'KDJ'

    property color kColor: theme.kdjChartKColor
    property color dColor: theme.kdjChartDColor
    property color jColor: theme.kdjChartJColor

    name: 'KDJ'
    parameter: 'N=9,M1=3,M2=3'

    rangeJieGuoField: [0, 1, 2]

    topComponentModel: {
        var kdjData = root.indexData ? root.indexData.JieGuo : [];
        var k = kdjData[0];
        var d = kdjData[1];
        var j = kdjData[2];

        return [['KDJ(9，3，3)', NaN, textColor], ['K：', k, kColor], ['D：', d, dColor], ['J：', j, jColor]].map(function(eachData) {
            return {
                text: [eachData[0], Util.formatStockText(eachData[1], 3, null, '')].join(''),
                color: eachData[2]
            }
        });
    }

    function _redraw() {
        figureData = [];
        var kPoints = [];
        var dPoints = [];
        var jPoints = [];

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
                kPoints.push([x, getY(eachData.JieGuo[0])]);
                dPoints.push([x, getY(eachData.JieGuo[1])]);
                jPoints.push([x, getY(eachData.JieGuo[2])]);
            }
        });

        drawPath(kPoints, kColor);
        drawPath(dPoints, dColor);
        drawPath(jPoints, jColor);
    }
}
