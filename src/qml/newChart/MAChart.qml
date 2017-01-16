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

    property var colors: [
        theme.maChartMA5Color,
        theme.maChartMA10Color,
        theme.maChartMA20Color,
        theme.maChartMA30Color,
        theme.maChartMA60Color,
        theme.maChartMA120Color
    ]

    name: 'MA'
    parameter: 'P1=5,P2=10,P3=20,P4=30,P5=60,P6=120'
    tabTitle: 'MA'

    chartType: chart_type_attach
    indicatorChart: true

    rangeJieGuoField: [0, 1, 2, 3, 4, 5]

    topComponentModel: {
        var maData = root.indexData ? root.indexData.JieGuo : [];

        return [5,10,20,30,60,120].map(function(days, index) {
            var value = maData[index];
            var label = Util.formatStockText(value, stock.precision, null, '')
            return {
                text: ['MA', days, '：', label].join(''),
                color: colors[index]
            }
        });
    }

    function _redraw() {
        var figureData = root.figureData = [];
        var canvas = root.canvas;
        var maPoints = [[], [], [], [], [], []];
        var pathFigure;

        // TODO 省略部分点的算法需仔细考虑
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;
        var lineWidth = root.defaultLineWidth;
        var colors = root.colors;
        var drawPath = root.drawPath;
        chartData.forEach(function(eachData, index) {
            if (index % interval !== 0) {
                return;
            }

            var x = getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                maPoints[0].push([x, getY(eachData.JieGuo[0])]);
                maPoints[1].push([x, getY(eachData.JieGuo[1])]);
                maPoints[2].push([x, getY(eachData.JieGuo[2])]);
                maPoints[3].push([x, getY(eachData.JieGuo[3])]);
                maPoints[4].push([x, getY(eachData.JieGuo[4])]);
                maPoints[5].push([x, getY(eachData.JieGuo[5])]);
            }
        });
        maPoints.forEach(function(eachPoints, index) {
            drawPath(eachPoints, colors[index]);
        });
    }

//    onClose: {
//        root.visible = false;
//    }
}
