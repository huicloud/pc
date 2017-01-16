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

import "../controls"
import "../js/Util.js" as Util

BaseChart {
    id: root

    property var mainMinChart

    property var timeMap

    showYAxis: true

    signal close

    topSpace: 22

    // 显示在指标栏上的标题
    property string tabTitle: '分时DDX'

    property real tabWidth: 100

    // 限制沪深A股
    property bool tabVisible: obj.match(/^[SH|SZ]/) && stock.type === 1

    Connections {
        target: root.dataProvider
        onSuccess: {
            root.cache = data;
            canvas.requestPaint();
        }
    }

    onCacheChanged: {
        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        var maxFun = Math.max;
        var minFun = Math.min;
        var timeMap = root.timeMap = {};
        cache.forEach(function(eachData) {
            timeMap[eachData.ShiJian] = eachData;
            var data = eachData.JieGuo;
            max = maxFun(max, data[0], data[1], data[2], data[3]);
            min = minFun(min, data[0], data[1], data[2], data[3]);
        });

        yMax = max;
        yMin = min;
    }

    Component {
        id: topComponent
        Item {
            anchors.top: parent.top
            width: parent.width
            scale: devicePixelRatio
            transformOrigin: Item.TopLeft
            RectangleWithBorder {
                id: topRectangle
                width: parent.width
                anchors.top: parent.top
                height: topSpace
                topBorder: 1
                bottomBorder: 1
                border.color: '#aec1da'
                color: '#f0f0f5'
                RowLayout {
                    anchors.fill: parent
                    property var ddxData: {
                        var result;
                        var time = xAxis.mouseXData;
                        if (time) {
                            result = timeMap[time];
                        } else {
                            result = cache[cache.length - 1];
                        }

                        return result || {JieGuo: []};

    //                    var index = xAxis._mouseIndex >= 0 ? xAxis._mouseIndex : cache.length - 1;
    //                    return cache[index] || {JieGuo: []};
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        text: 'DDX(60, 5, 10)'
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        color: parent.ddxData.JieGuo[0] >= 0 ? upColor : downColor
                        text: 'DDX: ' + Util.formatStockText(parent.ddxData.JieGuo[0], 3, null, '', false);
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        color: theme.ddxChart1Color
                        text: 'DDX1: ' + Util.formatStockText(parent.ddxData.JieGuo[1], 3, null, '', false);
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        color: theme.ddxChart2Color
                        text: 'DDX2: ' + Util.formatStockText(parent.ddxData.JieGuo[2], 3, null, '', false);
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 100
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        color: theme.ddxChart3Color
                        text: 'DDX3: ' + Util.formatStockText(parent.ddxData.JieGuo[3], 3, null, '', false);
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
            Text {
                anchors.top: topRectangle.bottom
                anchors.left: topRectangle.left
                anchors.leftMargin: leftSpace
                text: '大单动向'
            }
        }
    }

    Component.onCompleted: {
        topComponent.createObject(canvas);
    }

    function initChart(){}

    function drawBackground() {

        // 画出集合竞价背景
        var cache = mainMinChart ? mainMinChart.cache : {};
        if (cache._minTimes) {
            var auctionEndTime = cache._minTimes[cache._auctionIndex];
            var auctionEndX = xAxis.getCenterX(auctionEndTime);
            if (auctionEndX !== NaN) {
                var auctionStartX = xAxis.getLeftX(cache._minTimes[0]);
                drawRect(auctionStartX, 0 + topSpace, auctionEndX - auctionStartX, chartHeight - bottomSpace, 'transparent', '#f2f5ff');
            }
        }

        var drawXAxisGridLine = root.drawXAxisGridLine;
        var drawYAxisGridLine = root.drawYAxisGridLine;
        xAxis.ticks.forEach(function(tick) {
            drawXAxisGridLine(tick.position);
        });
        yAxis.ticks.forEach(function(tick, index) {
            drawYAxisGridLine(tick.position);
        });
        drawYAxisGridLine(chartHeight - bottomSpace);
    }

    function drawChart() {
        var ddx1 = [];
        var ddx2 = [];
        var ddx3 = [];
        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;
        var width = xAxis.getWidth();
        var leftDistance = width / 2;
        var zeroY = getY(0);
        var drawRect = root.drawRect;
        var drawPath = root.drawPath;
        cache.forEach(function(eachData, index) {
            var centerX = getCenterX(eachData.ShiJian);
            var data = eachData.JieGuo;
            if (!isNaN(centerX)) {
                var ddx = data[0];
                drawRect(centerX - leftDistance, zeroY, width, getY(ddx) - zeroY, ddx > 0 ? upColor : downColor, ddx > 0 ? '#ffffff' : downColor);
                ddx1.push([centerX, yAxis.getY(data[1])]);
                ddx2.push([centerX, yAxis.getY(data[2])]);
                ddx3.push([centerX, yAxis.getY(data[3])]);
            }
        });

        drawPath(ddx1, theme.ddxChart1Color);
        drawPath(ddx2, theme.ddxChart2Color);
        drawPath(ddx3, theme.ddxChart3Color);
    }
}
