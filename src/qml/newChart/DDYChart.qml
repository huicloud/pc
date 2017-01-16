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

    property color ddy1Color: theme.ddyChart1Color
    property color ddy2Color: theme.ddyChart2Color
    property color ddy3Color: theme.ddyChart3Color

    tabTitle: 'DDY'
    name: 'DDY'

    rangeJieGuoField: [0, 1, 2, 3]

    topComponentModel: {
        var ddyData = root.indexData ? root.indexData.JieGuo : [];
        var ddy = ddyData[0];
        var ddy1 = ddyData[1];
        var ddy2 = ddyData[2];
        var ddy3 = ddyData[3];

        return [['DDY(60, 5, 10)', NaN, textColor], ['DDY：', ddy, ddy > 0 ? upColor : downColor], ['DDY1：', ddy1, ddy1Color], ['DDY2：', ddy2, ddy2Color], ['DDY3：', ddy3, ddy3Color]].map(function(eachData) {
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
        text: '涨跌动因'
    }

    function _redraw() {
        var figureData = root.figureData = [];
        var canvas = root.canvas;

        var ddy1 = [];
        var ddy2 = [];
        var ddy3 = [];
        var zeroY = yAxis.getY(0);

        // TODO 省略部分点的算法需仔细考虑
        var width = xAxis.getWidth();
        var interval = parseInt(1 / (width * devicePixelRatio * 2)) + 1;

        var defaultLineWidth = root.defaultLineWidth;

        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;
        var upColor = root.upColor;
        var downColor = root.downColor;
        var getDDYFigure = width > 4 ? root.getRectFigure : root.getLineFigure;
        var leftXDistance = width > 4 ? width / 2 : 0;

        chartData.forEach(function(eachData, index) {
            if (index % interval !== 0) {
                return;
            }

            var x = getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                var x1 = x - leftXDistance;
                var ddyValue = eachData.JieGuo[0];
                var isUp = ddyValue > 0
                var color = isUp ? upColor : downColor;
                var ddyFigure = getDDYFigure(x1, zeroY, width, getY(ddyValue), defaultLineWidth, color, isUp ? '#ffffff' : color);
                figureData.push(ddyFigure);
                canvas.draw(ddyFigure);

                ddy1.push([x, getY(eachData.JieGuo[1])]);
                ddy2.push([x, getY(eachData.JieGuo[2])]);
                ddy3.push([x, getY(eachData.JieGuo[3])]);
            }
        });

        drawPath(ddy1, ddy1Color);
        drawPath(ddy2, ddy2Color);
        drawPath(ddy3, ddy3Color);
    }
}
