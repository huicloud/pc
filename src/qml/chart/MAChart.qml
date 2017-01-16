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

BaseChart {
    id: maChart

    name: 'MA'
    topSpace: 22

    property string period: '1day'
    property int maxCount: Number.MAX_VALUE
    property int minCount: 10
    property var colors: ['#222222', '#ff8802', '#d3141a', '#4ca92a', '#3e6ac5', '#e66de6']

    onCacheChanged: {

        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        cache.forEach(function(eachData) {
            max = Math.max(max, eachData.JieGuo[0], eachData.JieGuo[1], eachData.JieGuo[2], eachData.JieGuo[3], eachData.JieGuo[4], eachData.JieGuo[5]);
            min = Math.min(min, eachData.JieGuo[0], eachData.JieGuo[1], eachData.JieGuo[2], eachData.JieGuo[3], eachData.JieGuo[4], eachData.JieGuo[5]);
        });

        yMin = min;
        yMax = max;
    }

    Connections {
        target: maChart.dataProvider
        onSuccess: {
            cache = data;
            canvas.requestPaint();
        }
    }

    Component {
        id: topComponent
        RectangleWithBorder {
            anchors.top: parent.top
            width: parent.width
            height: topSpace
            bottomBorder: 1
            border.color: '#aec1da'
            color: '#f0f0f5'
            visible: maChart.visible
            transformOrigin: Item.TopLeft
            scale: devicePixelRatio
            RowLayout {
                anchors.fill: parent
                Repeater {
                    property var maData: {
                        var index = xAxis._mouseIndex >= 0 ? xAxis._mouseIndex : cache.length - 1;
                        return cache[index];
                    }
                    model: {
                        if (maData) {
                            return [maData.JieGuo[0], maData.JieGuo[1], maData.JieGuo[2], maData.JieGuo[3], maData.JieGuo[4], maData.JieGuo[5]]
                        }
                        return [];
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        color: colors[index]
                        text: 'MA' + [5,10,20,30,60,120][index] + ': ' + Util.formatStockText(modelData, stock.precision, '', false);
                    }
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
                        maChart.visible = false;
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

        // XXX 会重复画
//        xAxis.ticks.forEach(function(tick) {
//            drawXAxisGridLine(tick.position);
//        });
//        yAxis.ticks.forEach(function(tick) {
//            drawYAxisGridLine(tick.position);
//        });
    }

    function drawChart() {
        var maPoints = [[], [], [], [], [], []];
        cache.forEach(function(eachData, index) {
            var x = xAxis.getCenterX(eachData.ShiJian);
            if (!isNaN(x)) {
                maPoints[0].push([x, yAxis.getY(eachData.JieGuo[0])]);
                maPoints[1].push([x, yAxis.getY(eachData.JieGuo[1])]);
                maPoints[2].push([x, yAxis.getY(eachData.JieGuo[2])]);
                maPoints[3].push([x, yAxis.getY(eachData.JieGuo[3])]);
                maPoints[4].push([x, yAxis.getY(eachData.JieGuo[4])]);
                maPoints[5].push([x, yAxis.getY(eachData.JieGuo[5])]);
            }
        });
        maPoints.forEach(function(eachPoints, index) {
            drawPath(eachPoints, colors[index]);
        });
    }
}
