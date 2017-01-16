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

//    property bool close: false

    property color ddx1Color: theme.ddxChart1Color
    property color ddx2Color: theme.ddxChart2Color
    property color ddx3Color: theme.ddxChart3Color

    tabTitle: 'DDX'
    name: 'DDX'

    rangeJieGuoField: [0, 1, 2, 3]

    topComponentModel: {
        var ddxData = root.indexData ? root.indexData.JieGuo : [];
        var ddx = ddxData[0];
        var ddx1 = ddxData[1];
        var ddx2 = ddxData[2];
        var ddx3 = ddxData[3];

        return [['DDX(60, 5, 10)', NaN, textColor], ['DDX：', ddx, ddx > 0 ? upColor : downColor], ['DDX1：', ddx1, ddx1Color], ['DDX2：', ddx2, ddx2Color], ['DDX3：', ddx3, ddx3Color]].map(function(eachData) {
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
        text: '大单动向'
    }

    function _redraw() {
        var figureData = root.figureData = [];
        var canvas = root.canvas;

        var ddx1 = [];
        var ddx2 = [];
        var ddx3 = [];
        var zeroY = yAxis.getY(0);

        // TODO 省略部分点的算法需仔细考虑
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var defaultLineWidth = root.defaultLineWidth;

        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;
        var upColor = root.upColor;
        var downColor = root.downColor;

        var getDDXFigure = width > 4 ? root.getRectFigure : root.getLineFigure;
        var leftXDistance = width > 4 ? width / 2 : 0;

        chartData.forEach(function(eachData, index) {
            if (index % interval !== 0) {
                return;
            }

            var x = getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                var x1 = x - leftXDistance;
                var ddxValue = eachData.JieGuo[0];
                var isUp = ddxValue > 0
                var color = isUp ? upColor : downColor;

                var ddxFigure = getDDXFigure(x1, zeroY, width, getY(ddxValue), defaultLineWidth, color, isUp ? '#ffffff' : color);
                figureData.push(ddxFigure);
                canvas.draw(ddxFigure);

                ddx1.push([x, getY(eachData.JieGuo[1])]);
                ddx2.push([x, getY(eachData.JieGuo[2])]);
                ddx3.push([x, getY(eachData.JieGuo[3])]);
            }
        });

        drawPath(ddx1, ddx1Color);
        drawPath(ddx2, ddx2Color);
        drawPath(ddx3, ddx3Color);
    }
}
