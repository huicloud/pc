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
import QtQuick.Layouts 1.1

import "../core"
import "../controls"
import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

/**
 * RSI图
 */
BaseChart {
    id: root

    name: 'RSI'

    property color rsi1Color: '#222222'
    property color rsi2Color: '#ff8802'
    property color rsi3Color: '#e66de6'

    showYAxis: true
    topSpace: 22

    signal close

    onCacheChanged: {

        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        cache.forEach(function(eachData) {
            max = Math.max(max, Math.abs(eachData.JieGuo[0]), Math.abs(eachData.JieGuo[1]), Math.abs(eachData.JieGuo[2]));
            min = Math.min(min, Math.abs(eachData.JieGuo[0]), Math.abs(eachData.JieGuo[1]), Math.abs(eachData.JieGuo[2]));
        });

        yMax = max;
        yMin = min;
    }

    Connections {
        target: root.dataProvider
        onSuccess: {
            cache = data;
            canvas.requestPaint();
        }
    }

    Component {
        id: topComponent
        RectangleWithBorder {
            width: parent.width
            anchors.top: parent.top
            height: topSpace
            topBorder: 1
            bottomBorder: 1
            border.color: '#aec1da'
            color: '#f0f0f5'
            transformOrigin: Item.TopLeft
            scale: devicePixelRatio
            RowLayout {
                anchors.fill: parent
                property var rsiData: {
                    var index = xAxis._mouseIndex >= 0 ? xAxis._mouseIndex : cache.length - 1;
                    return cache[index] || {JieGuo: []};
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    text: 'RSI(6, 12, 24)'
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    color: rsi1Color
                    text: 'RSI1: ' + Util.formatStockText(parent.rsiData.JieGuo[0], 3, '', false);
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    color: rsi2Color
                    text: 'RSI2: ' + Util.formatStockText(parent.rsiData.JieGuo[1], 3, '', false);
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    color: rsi3Color
                    text: 'RSI3: ' + Util.formatStockText(parent.rsiData.JieGuo[2], 3, '', false);
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                ImageButton {
                    id: button
                    Layout.fillHeight: true
                    Layout.preferredWidth: 24
                    Layout.alignment: Qt.AlignRight
                    imageRes: theme.iconIndicatorClose
                    imageSize: Qt.size(16, 16)

                    onClickTriggered: {
                        root.close();
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        topComponent.createObject(canvas);
    }

    function initChart() {
        // TODO do nothing
    }

    function drawBackground() {
        xAxis.ticks.forEach(function(tick) {
            drawXAxisGridLine(tick.position);
        });
        yAxis.ticks.forEach(function(tick) {
            drawYAxisGridLine(tick.position);
        });
    }

    function drawChart() {
        var rsi1Points = [];
        var rsi2Points = [];
        var rsi3Points = [];
        cache.forEach(function(eachData, index) {
            var x = xAxis.getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                rsi1Points.push([x, yAxis.getY(eachData.JieGuo[0])]);
                rsi2Points.push([x, yAxis.getY(eachData.JieGuo[1])]);
                rsi3Points.push([x, yAxis.getY(eachData.JieGuo[2])]);
            }
        });

        drawPath(rsi1Points, rsi1Color);
        drawPath(rsi2Points, rsi2Color);
        drawPath(rsi3Points, rsi3Color);
    }
}
