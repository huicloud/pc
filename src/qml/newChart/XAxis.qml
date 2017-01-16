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

Drawable {
    id: root

    objectName: 'xAxis'
    property BaseChart chart

    property int minCount: 10

    property int count: 100

    // 离最后一条数据的偏移位置(正数)
    property int lastOffset: 0

    // 每次操作请求的偏移位置（每个图中根据这个位置更新去更新数据，然后在更新数据后的绑定到数据提供商的位置作为实际显示位置）
    property var requestOffsetPosition

    // 最后一条数据的时间（用作保证除主图外其它图形数据截取，有效数据不能大于该时间）
    property int lastTime: lastData ? lastData.ShiJian : Number.MAX_VALUE

    property var lastData: chartData[chartData.length - 1]

    readonly property real mouseX: canvas.mouseX

    readonly property real _mouseX: mouseX - canvas.leftYAxisWidth

    readonly property real mouseIndex: _mouseX < 0 || _mouseX > width ? -1 : parseInt(_mouseX / pixelPer)

    // 从最后计算的index位置
    readonly property real lastIndex: mouseIndex > 0 ? chartData.length - mouseIndex : -1

    readonly property var mouseXData: (mouseIndex >= 0 && times[mouseIndex]) ? times[mouseIndex] : null

    property var times: []

    property var timeMap: ({})

    property real pixelPer: 0

    property var chartData: chart.chartData
    onChartDataChanged: { isDirty = true }
    property string canvasProperty: [canvas.width, canvas.height, canvas.x, canvas.y].join('|')
    onCanvasPropertyChanged: { isDirty = true }

    onMouseXDataChanged: { canvas.crossLineCanvas.requestPaint() }

    Component.onCompleted: {

        // 初始值
        requestOffsetPosition = [count, lastOffset];
    }

    MouseArea {
        id: mouseArea
        parent: canvas
        width: parent.width
        height: canvas.xAxisHeight
        y: canvas.chartContainer.height
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor

        property real pressedX: -1
        property int lastOffset: -1

        // 按下时记录当前x位置
        onPressed: {
            mouseArea.pressedX = mouse.x;
            mouseArea.lastOffset = root.lastOffset;
        }

        onReleased: {
            mouseArea.pressedX = -1;
            mouseArea.lastOffset = -1;
        }

        onPositionChanged: {
            if (pressedX > 0) {

                // 计算请求更新的位置
                var currentX = mouse.x;
                var distance = currentX - pressedX;
                var moveCount = parseInt(distance / pixelPer);
                var nextLastOffset = Math.max(0, mouseArea.lastOffset + moveCount);
                root.requestOffsetPosition = [root.count, nextLastOffset];
            }
        }
    }

    // x坐标固定在canvas底部
    function _redraw() {
        var figureData = [];
        var times = [];
        var timeMap = {};
        var height = canvas.xAxisHeight;
        var width = root.width = canvas.chartContainer.width - canvas.leftYAxisWidth - canvas.rightYAxisWidth;
        var top = canvas.chartContainer.height;
        var bottom = top + height;
        var left = canvas.leftYAxisWidth;
        var right = left + width;

        // 数据个数不小于最少显示个数
        var count = Math.max(chartData.length, minCount);
        var pixelPer = root.pixelPer = width / count;

        var gridLineWidth = root.gridLineWidth;
        var gridLineColor = root.gridLineColor;
        var getXTickLabel = chart.getXTickLabel;
        var draw = canvas.draw;
        var fontStyle = root.fontStyle;
        var tickColor = root.tickColor;

        // 画出坐标点和网格
        var lastLabel, currentLabel, lastIndex = 0;
        for (var i = 0; i < count; i++) {
            var eachData = chartData[i] || {};
            var time = eachData.ShiJian;
            if (time) {
                times.push(time);
                timeMap[time] = i;
                currentLabel = eachData.xAxisLabel;
                if (!currentLabel) {
                    currentLabel = eachData.xAxisLabel = getXTickLabel(time);
                }
                if (currentLabel !== lastLabel) {
                    lastLabel = currentLabel;
                    if ((i - lastIndex) * pixelPer > 80) {

                        // 垂直网格线
                        var x = left + i * pixelPer;
                        var y1 = 0;
                        var y2 = top;
                        var gridLineFigure = {
                            name: 'Line',
                            x1: x,
                            y1: y1,
                            x2: x,
                            y2: y2,
                            lineWidth: gridLineWidth,
                            style: gridLineColor
                        };
                        figureData.push(gridLineFigure);
                        draw(gridLineFigure);

                        // 坐标点
                        var tickFigure = {
                            name: 'Text',
                            text: currentLabel,
                            x: x,
                            y: bottom - 4,
                            fontStyle: fontStyle,
                            fillStyle: tickColor,
                            align: 'center',
                        };
                        figureData.push(tickFigure);
                        draw(tickFigure);

                        lastIndex = i;
                    }
                }
            }
        }

//        // 坐标轴上方的分隔线
//        var gridLineFigure = {
//            name: 'Line',
//            x1: 0,
//            y1: top,
//            x2: canvas.chartContainer.width,
//            y2: top,
//            lineWidth: gridLineWidth,
//            style: gridLineColor
//        };
//        figureData.push(gridLineFigure);
//        draw(gridLineFigure);

        root.figureData = figureData;
        root.timeMap = timeMap;
        root.times = times;
    }

    function getLeftX(time) {
        return getCenterX(time) - getWidth() / 2;
    }

    function getCenterX(time, index) {
        if (index == null) {

            // 使用map提升性能
//            if (times) {
//                index = times.indexOf(time);
//            }
            if (timeMap) {
                index = timeMap[time];
            }
        }
        if (index >= 0) {
            return canvas.leftYAxisWidth + (index + 0.5) * pixelPer;
        }
        return NaN;
    }

    function getWidth() {
        return pixelPer > 1 ? (pixelPer - pixelPer / 3) : pixelPer;
    }

    function getXTickLabel(time, detail) {
        return chart.getXTickLabel(time, detail);
    }

    function moreData() {
        var nextCount = root.count + parseInt(root.count / 3);
        if (nextCount !== requestOffsetPosition[0]) {
            requestOffsetPosition = [nextCount, lastOffset];
        }
    }

    function lessData() {
        var nextCount = Math.max(minCount, root.count - parseInt(root.count / 3));
        if (nextCount !== requestOffsetPosition[0]) {
            requestOffsetPosition = [nextCount, lastOffset];
        }
    }

    function left() {
        var nextOffset = root.lastOffset + 1;
        requestOffsetPosition = [root.count, nextOffset];
    }

    function right() {
        if (root.lastOffset === 0) {
            return;
        }

        var nextOffset = root.lastOffset - 1;
        requestOffsetPosition = [root.count, nextOffset];
    }

    function moveLeft(start) {
        var nextIndex;
        if (start) {
            nextIndex = chartData.length - 1;
        } else if (mouseIndex === 0) {
            var nextOffset = root.lastOffset + 1;
            requestOffsetPosition = [root.count, nextOffset];
            return;
        } else {
            nextIndex = Math.max(mouseIndex - 1, 0);
        }
        canvas._mouseX = getCenterX(null, nextIndex);
    }

    function moveRight(start) {

        var nextIndex;
        if (start) {
            nextIndex = 0;
        } else if (mouseIndex === chartData.length - 1) {
            if (root.lastOffset > 0) {
                var nextOffset = root.lastOffset - 1;
                requestOffsetPosition = [root.count, nextOffset];
            }
            return;
        } else {
            nextIndex = Math.min(mouseIndex + 1, chartData.length - 1);
        }
        canvas._mouseX = getCenterX(null, nextIndex);
    }

    function getXAxisCrossLine() {
        if (mouseXData) {
            var x = getCenterX(mouseXData, mouseIndex);
            if (x) {
                return {
                    position: x,
                    value: mouseXData,
                    label: getXTickLabel(mouseXData, true)
                }
            }
        }
    }
}
