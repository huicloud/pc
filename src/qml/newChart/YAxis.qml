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

    property var chart

//    property string rangeString: chart.range.join('|')
//    onRangeStringChanged: { isDirty = true }
    property string chartProperty: [chart.width, chart.height, chart.x, chart.y, chart.topComponentHeight].join('|')
    onChartPropertyChanged: { isDirty = true }
    property bool rangeChanged: false
    property var chartData: chart.chartData
    onChartDataChanged: { isDirty = true; rangeChanged = true; }

    property real minHeightPerTick: 30

    property real yOffset
    property real leftYAxisX
    property real rightYAxisX

    property real mouseY: canvas.mouseY
    property real lineY: (mouseY > yOffset && mouseY < yOffset + height) && !chart.skip ? mouseY : -1

    property real max: Number.MIN_VALUE
    property real min: Number.MAX_VALUE

    onLineYChanged: { canvas.crossLineCanvas.requestPaint() }

    function _redraw() {

        // 范围变化重新计算
        if (rangeChanged) {
            var range = chart.getRange();
            max = range[0];
            min = range[1];
            rangeChanged = false;
        }

        var figureData = root.figureData = [];

        // 根据chart在canvas中的位置确定Y轴的坐标位置
        var yOffset = chart.mapToItem(canvas, 0, 0).y + chart.topComponentHeight;
        var height = chart.height - chart.topComponentHeight;

        // 修补height, yOffset，避免在devicePixelRatio为1的情况下图形会计算超出高度的问题
        if (canvas.devicePixelRatio === 1) {
            var bottomY = yOffset + height;
            if (Math.round(bottomY) > bottomY) {
                height += 0.4;
            } else {
                yOffset += 0.4;
            }
            height -= 1;
        }
        root.height = height;
        root.yOffset = yOffset;

        var x1 = root.leftYAxisX = canvas.leftYAxisWidth;
        var x2 = root.rightYAxisX = canvas.width - rightYAxisWidth;
        var drawLeftYAxisLabel = x1 > 0 ? root.drawLeftYAxisLabel : noop;
        var drawRightYAxisLabel = x2 < canvas.width ? root.drawRightYAxisLabel : noop;

        // 画出坐标点和网格
        var ticks = getTicks() || [];
        var tickColor = root.tickColor;
        var gridLineWidth = root.gridLineWidth;
        var gridLineColor = root.gridLineColor;

        ticks.forEach(function(eachTick) {
            var y = eachTick.position;
            var color = eachTick.color || tickColor;
            drawLeftYAxisLabel(y, eachTick.label, color);
            drawRightYAxisLabel(y, eachTick.label, color);

            // 水平网格线
            var gridLineFigure = {
                name: 'Line',
                x1: x1,
                y1: y,
                x2: x2,
                y2: y,
                lineWidth: gridLineWidth,
                style: gridLineColor
            };
            figureData.push(gridLineFigure);
            canvas.draw(gridLineFigure);
        });
    }

    function drawYAxisLabel(x, y, text, fillStyle, align) {
        var yOffset = root.yOffset;
        var labelFigure = {
            name: 'Text',
            text: text,
            x: x,
            y: y + root.tickFontSize / 2,
            fontStyle: root.tickFontStyle,
            fillStyle: fillStyle,
            align: align,
            bound: {
                top: yOffset,
                bottom: yOffset + height
            }
        }
        figureData.push(labelFigure);
        canvas.draw(labelFigure);
    }

    function drawLeftYAxisLabel(y, text, fillStyle) {
        drawYAxisLabel(leftYAxisX - 10, y, text, fillStyle, 'right');
    }

    function drawRightYAxisLabel(y, text, fillStyle) {
        drawYAxisLabel(rightYAxisX + 10, y, text, fillStyle, 'left');
    }

    function getTicks() {
        return chart.getYTicks(max, min, yOffset, height, minHeightPerTick);
    }

    function getY(value) {
        return height * (max - value) / (max - min) + yOffset;
    }

    function getValidY(value) {
        if (value > max || value < min) {
            return NaN;
        }

        return getY(value);
    }

    function getValue(y) {
        return max - (y - yOffset) * (max - min) / height;
    }

    function getYAxisCrossLine() {
        if (lineY >= 0) {
            var value = getValue(lineY);
            return {
                position: lineY,
                bound: {
                    top: yOffset,
                    bottom: yOffset + height
                },
                value: value,
                label: chart.getYTickLabel(value)
            }
        }
    }
}
