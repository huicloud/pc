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
 * MACD图
 */
BaseChart {
    id: root

    name: 'MACD'

    property color upColor: '#ee2c2c'
    property color downColor: '#1ca049'
    property color deaColor: '#ff8802'
    property color diffColor: '#3e6ac5'

    showYAxis: true
    topSpace: 22

    signal close

    onCacheChanged: {

        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        cache.forEach(function(eachData) {
            max = Math.max(max, Math.abs(eachData.JieGuo[0]), Math.abs(eachData.JieGuo[1]), Math.abs(eachData.JieGuo[2]));
        });

        yMax = max;
        yMin = -max;
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
                property var macdData: {
                    var index = xAxis._mouseIndex >= 0 ? xAxis._mouseIndex : cache.length - 1;
                    return cache[index] || {JieGuo: []};
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    text: 'MACD(12, 26, 9)'
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    color: parent.macdData.JieGuo[2] >= 0 ? upColor : downColor
                    text: 'MACD: ' + Util.formatStockText(parent.macdData.JieGuo[2], 3, '', false);
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    color: diffColor
                    text: 'DIFF: ' + Util.formatStockText(parent.macdData.JieGuo[0], 3, '', false);
                }
                Text {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignLeft
                    Layout.preferredWidth: 100
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    color: deaColor
                    text: 'DEA: ' + Util.formatStockText(parent.macdData.JieGuo[1], 3, '', false);
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

        var diffPoints = [];
        var deaPoints = [];
        var middleY = yAxis.getY(0);
        cache.forEach(function(eachData, index) {
            var x = xAxis.getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                var macdValue = eachData.JieGuo[2];
                drawLine(x, middleY, x, yAxis.getY(macdValue), 1, macdValue > 0 ? upColor : downColor);
                diffPoints.push([x, yAxis.getY(eachData.JieGuo[0])]);
                deaPoints.push([x, yAxis.getY(eachData.JieGuo[1])]);
            }
        });

        drawPath(diffPoints, diffColor);
        drawPath(deaPoints, deaColor);
    }

    function getYTicks(max, min, height, minHeightPerTick) {
        var count = Math.floor(height / minHeightPerTick);
        count -= (count % 2 === 1 ? 1 : 0);
        var diff = max - min;
        var diffPerTick = diff / (count + 1);
        var heightPerTick = height / (count + 1);
        var middleY = yAxis.getY(0);
        var _ticks = [];
        _ticks.unshift({
                        position: middleY,
                        value: 0
                    });
        for (var i = 1; i <= count / 2; i++) {
            var value = i * diffPerTick;
            var offsetPosition = i * heightPerTick;
            _ticks.unshift({
                            position: middleY - offsetPosition,
                            value: value
                        });
            _ticks.push({
                            position: middleY + offsetPosition,
                            value: -value
                        });
        }

        return _ticks;
    }
}
