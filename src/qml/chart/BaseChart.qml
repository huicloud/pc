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
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "../core"
import "../js/Util.js" as Util
import "../controls"

/**
 * 图形接口
 */
ContextComponent {
    id: chart
    objectName: 'chart'

    property string name

    property var dataProvider
    property var cache: []

    property real chartX: 0
    property real chartY: 0
    property real chartHeight: height
    property real chartWidth: width

    readonly property int devicePixelRatio: Screen.devicePixelRatio

    property var stock
    property int volumeUnit: stock.volumeUnit

    property XAxis xAxis: XAxis {
        chart: chart
    }

    property YAxis yAxis: YAxis {
        charts: [chart]
    }

    property bool showXAxis: false
    property bool showYAxis: false

    property var yMax: Number.MIN_VALUE
    property var yMin: Number.MAX_VALUE

    property int leftSpace: 80
    property int rightSpace: 80
    property int topSpace: 0
    property int bottomSpace: showXAxis ? 20 : 0

    property int fontSize: 14
    property color upColor: '#ee2c2c'
    property color downColor: '#1ca049'

    property int gridLineWidth: 1
    property color gridLineColor: '#eeeeee'

    property color tickColor: '#222222'

    property int defaultLineWidth: 1

    property Component tooltipComponent

    property bool pressedForce: true

    property var canvas: Canvas {
        contextType: '2d'
        width: chart.width * devicePixelRatio
        height: chart.height * devicePixelRatio

        // 注释掉使用默认的Canvas.Immediate, 修复bug ZYPC-384
//        renderStrategy: Canvas.Threaded

        transformOrigin: Item.TopLeft

        scale: 1 / devicePixelRatio

//        canvasSize: Qt.size(chart.width / scale, chart.height /scale)

        onPaint: {
            if (ctx) {
                ctx.reset();
                ctx.scale(devicePixelRatio, devicePixelRatio);
//                ctx.clearRect(0, 0, canvasSize.width, canvasSize.height);
                chart.redraw();
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true

            onPositionChanged: {
                xAxis.mouseX = mouse.x;
                yAxis.mouseY = mouse.y;
            }

            onExited: {
                xAxis.mouseX = -1;
                yAxis.mouseY = -1;
            }
            onPressed: {
                if (pressedForce) {
                    forceActiveFocus();
                }
            }

            transformOrigin: Item.TopLeft
            scale: devicePixelRatio

            Canvas {
                id: crossLineCanvas
                contextType: '2d'
                width: chart.width * devicePixelRatio
                height: chart.height * devicePixelRatio
                renderStrategy: Canvas.Threaded
                transformOrigin: Item.TopLeft
                scale: 1 / devicePixelRatio
                canvasSize: Qt.size(chart.width / scale, chart.height /scale)

                onPaint: {

                    // 根据XAxis和YAxis设置画出十字光标
                    if (context) {
                        context.reset();
                        context.scale(devicePixelRatio, devicePixelRatio);
                        var x = xAxis.lineX;
                        if (x > 0) {
                            _drawLine(context, x, topSpace, x, chartHeight - bottomSpace, 1, ctx.strokeStyle = ctx.createPattern('#294683', Qt.Dense5Pattern));

                            // 画出坐标上的标签
                            if (showXAxis) {
                                drawCrossLineXAxisTick(context, xAxis.mouseXData, x);
//                                var xLabel = xAxis.getXTickLabel(xAxis.mouseXData, true);
//                                var textY = chartHeight - bottomSpace + fontSize + 4;
//                                _drawText(context, xLabel, x, textY, fontSize, '#ffffff' ,'#3e6ac5', 'center');
                            }
                        }
                        var y = yAxis.lineY;
                        if (y > 0) {
                            _drawLine(context, leftSpace, y, chartWidth - rightSpace, y, 1, ctx.strokeStyle = ctx.createPattern('#294683', Qt.Dense5Pattern));

                            if (showYAxis) {
                                drawCrossLineYAxisTick(context, yAxis.getValue(y), y);
//                                var value = yAxis.getValue(y);
//                                var yLabel = Util.formatStockText(value, 2, '万/亿', false);
//                                _drawText(context, yLabel, leftSpace - 8, y + (fontSize + 2) / 2, fontSize, '#ffffff' ,'#3e6ac5', 'right');
//                                _drawText(context, yLabel, chartWidth - rightSpace + 8, y + (fontSize + 2) / 2, fontSize, '#ffffff' ,'#3e6ac5');
                            }
                        }
                    }
                }

                Connections {
                    target: xAxis
                    onLineXChanged: {
                        crossLineCanvas.requestPaint();
                    }
                }

                Connections {
                    target: yAxis
                    onLineYChanged: {
                        crossLineCanvas.requestPaint();
                    }
                }
                Loader {
                    id: tooltip
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: topSpace * devicePixelRatio
                    width: leftSpace
                    visible: xAxis.lineX >= 0
                    active: xAxis.lineX >= 0
                    sourceComponent: tooltipComponent
                    transformOrigin: Item.TopLeft
                    scale: devicePixelRatio
                }
            }
        }
    }

    readonly property var ctx: chart.canvas.context

    children: [canvas, rightClickMouseArea]

    onVisibleChanged: {
        canvas.requestPaint();
    }

    function redraw() {
        chart.initChart();
        chart.drawBackground();
        chart.drawChart();
        chart.drawAxisTicks();
    }

    function drawLine(x1, y1, x2, y2, lineWidth, style) {
        _drawLine(ctx, x1, y1, x2, y2, lineWidth, style);
    }

    function _drawLine(ctx, x1, y1, x2, y2, lineWidth, style) {
        ctx.beginPath();
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = style;
        ctx.moveTo(_normalizeDrawLinePoint(x1), _normalizeDrawLinePoint(y1));
        ctx.lineTo(_normalizeDrawLinePoint(x2), _normalizeDrawLinePoint(y2));
        ctx.stroke();
    }

    function drawYAxisGridLine(y, lineWidth, color) {
        drawLine(chartX + leftSpace, y, chartWidth - rightSpace, y, lineWidth || gridLineWidth, color || gridLineColor);
    }

    function drawXAxisGridLine(x, lineWidth, color) {
        drawLine(x, chartY + topSpace, x, chartHeight - bottomSpace, lineWidth || gridLineWidth, color || gridLineColor);
    }

    function drawRect(x, y, width, height, strokeStyle, fillStyle, lineWidth) {
        _drawRect(ctx, x, y, width, height, strokeStyle, fillStyle, lineWidth);
    }

    function _drawRect(ctx, x, y, width, height, strokeStyle, fillStyle, lineWidth) {
        ctx.lineWidth = lineWidth || chart.defaultLineWidth;
        if (fillStyle) {
            ctx.fillStyle = fillStyle;
            ctx.fillRect(_normalizeDrawLinePoint(x), _normalizeDrawLinePoint(y), _normalizeSize(width), _normalizeSize(height));
        }
        ctx.strokeStyle = strokeStyle;
        ctx.strokeRect(_normalizeDrawLinePoint(x), _normalizeDrawLinePoint(y), _normalizeSize(width), _normalizeSize(height));
    }

    function _drawText(ctx, text, x, y, fontSize, fontStyle, backgroundStyle, alignPosition) {
        ctx.font = (fontSize || chart.fontSize) + 'px Arial';
        var size = ctx.measureText(text);
        var width = size.width;
        var height = fontSize;

        if (alignPosition === 'center') {
            x = x - width / 2;
        } else if (alignPosition === 'right') {
            x = x - width;
        }

        if (x < 0) {
            x = 0;
        } else if (x + width > chart.chartWidth) {
            x = chart.chartWidth - width;
        }

        if (y - topSpace < height) {
            y = height + topSpace;
        } else if (y > chart.chartHeight) {
            y = chart.chartHeight;
        }

        if (backgroundStyle) {

          // 背景边框
          ctx.fillStyle = backgroundStyle;
          ctx.fillRect(_normalizeDrawLinePoint(x - 2), _normalizeDrawLinePoint(y + 2), width + 4, - (fontSize + 4));
        }
        ctx.fillStyle = fontStyle;
        ctx.fillText(text, x, y);
    }

    function drawText(text, x, y, fontSize, fontStyle, backgroundStyle) {
        _drawText(ctx, text, x, y, fontSize, fontStyle, backgroundStyle);
    }

    function drawTextAlignCenter(text, centerX, y, fontSize, fontStyle, backgroundStyle) {
        _drawText(ctx, text, centerX, y, fontSize, fontStyle, backgroundStyle, 'center');
    }

    function drawTextAlignRight(text, rightX, y, fontSize, fontStyle, backgroundStyle) {
        _drawText(ctx, text, rightX, y, fontSize, fontStyle, backgroundStyle, 'right');
    }

    function drawPath(points, color, lineWidth) {
        lineWidth = lineWidth || defaultLineWidth;
        ctx.beginPath();
        ctx.lineJoin = 'round';
        ctx.lineWidth = lineWidth || defaultLineWidth;
        var strokeStyle = ctx.strokeStyle = color = color.toString().toLowerCase();
        points.forEach(function (eachPoint, index) {
            strokeStyle = eachPoint[2] === false ? 'transparent' : color;
            if (ctx.strokeStyle !== strokeStyle) {
                ctx.stroke();
                ctx.closePath();
                ctx.beginPath();
                ctx.strokeStyle = strokeStyle;
            }
            if (index === 0) {
                ctx.moveTo(_normalizeDrawLinePoint(eachPoint[0]), _normalizeDrawLinePoint(eachPoint[1]));
            } else {
                ctx.lineTo(_normalizeDrawLinePoint(eachPoint[0]), _normalizeDrawLinePoint(eachPoint[1]));
            }
        });

        ctx.stroke();
        ctx.closePath();
    }

    function fillPath(points, y0, strokeColor, fillStyle, lineWidth) {
        ctx.beginPath();
        points.forEach(function(eachPoint, index) {
            if (index === 0) {
                ctx.moveTo(_normalizeDrawLinePoint(eachPoint[0]), _normalizeDrawLinePoint(eachPoint[1]));
            } else {
                ctx.lineTo(_normalizeDrawLinePoint(eachPoint[0]), _normalizeDrawLinePoint(eachPoint[1]));
            }
        });
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = strokeColor;
        ctx.lineJoin = 'round';
        ctx.stroke();

        if (points.length > 1) {
            ctx.lineWidth = 0;
            ctx.lineTo(_normalizeDrawLinePoint(points[points.length - 1][0]), _normalizeDrawLinePoint(y0));
            ctx.lineTo(_normalizeDrawLinePoint(points[0][0]), _normalizeDrawLinePoint(y0));
            ctx.closePath();
            ctx.fillStyle = fillStyle;
            ctx.fill();
        } else {
            ctx.closePath();
        }
    }

    function drawCircle(x, y, radius, strokeStyle, fillStyle, lineWidth) {
        ctx.beginPath();
        ctx.arc(x, y, radius, 0, Math.PI * 2);
        ctx.closePath();
        ctx.fillStyle = fillStyle || 'transparent';
        ctx.lineWidth = lineWidth || defaultLineWidth;
        ctx.strokeStyle = strokeStyle;
        ctx.fill();
        ctx.stroke();
    }

    function drawAxisTicks() {
        if (showXAxis) {
            drawXAxisTicks();
        }
        if (showYAxis) {
            drawYAxisTicks();
        }
    }

    function drawXAxisTicks() {

        var textY = chartHeight - bottomSpace + fontSize + 2;

        // 在bottomspace位置画出横坐标轴
        xAxis.ticks.forEach(function(tick) {
            var x = tick.position;
            var y1 = chartHeight - bottomSpace;
            var y2 = y1 + 4;
            drawLine(x, y1, x, y2, 2, gridLineColor);

            var text = tick.xAxisLabel;
            var width = ctx.measureText(text).width;
            drawText(text, x - width / 2, textY, fontSize, tickColor);
        });
    }

    function drawYAxisTicks() {
        if (cache.length > 0) {
            yAxis.ticks.forEach(function(tick) {
                var text = getYTickLabel(tick.value);
                if (leftSpace !== 0) {
                    drawTextAlignRight(text, leftSpace - 10, tick.position + fontSize / 2, fontSize, tickColor);
                }
                if (rightSpace !== 0) {
                    drawText(text, chartWidth - rightSpace + 10, tick.position + fontSize / 2, fontSize, tickColor);
                }
            });
        }
    }

    function getXTickLabel() {
    }

    function getYTickLabel(value) {
        return Util.formatStockText(value, 2, '万/亿', false);
    }

    Component.onCompleted: {
        if (dataProvider) {
            dataProvider.addChart(chart);
        }
    }

    function getXTicks() {
    }

    function drawCrossLineXAxisTick(ctx, value, x) {
        var xLabel = xAxis.getXTickLabel(xAxis.mouseXData, true);
        var textY = chartHeight - bottomSpace + fontSize + 2
        _drawRect(ctx, x - 40, chartHeight - bottomSpace, 80, bottomSpace, '#3e6ac5', '#3e6ac5');
        _drawText(ctx, xLabel, x, textY, fontSize, '#ffffff' ,null, 'center');
    }

    function drawCrossLineYAxisTick(ctx, value, y) {
        var yLabel = getYTickLabel(value);
        var textY = Math.max(Math.min(y + fontSize / 2, chartHeight - fontSize / 2 + 4), topSpace + fontSize + 2);

        // 左边
        if (leftSpace) {
            _drawRect(ctx, 0, textY + 2, leftSpace, -(fontSize + 4), '#3e6ac5', '#3e6ac5');
            _drawText(ctx, yLabel, leftSpace - 10, textY - 2, fontSize, '#ffffff' ,null, 'right');
        }
        if (rightSpace) {
            _drawRect(ctx, chartWidth, textY + 2, -rightSpace, -(fontSize + 4), '#3e6ac5', '#3e6ac5');
            _drawText(ctx, yLabel, chartWidth - rightSpace + 10, textY - 2, fontSize, '#ffffff' ,null, 'left');
        }
    }

    function _normalizeDrawLinePoint(point) {
      if (devicePixelRatio === 1) {
        var intPoint = parseInt(point);
        return intPoint > point ? intPoint - 0.5 : intPoint + 0.5;
      } else {
        return point;
      }
    }

    function _normalizeSize(size) {
        if (devicePixelRatio === 1) {
          return Math.floor(size);
        } else {
          return size;
        }
    }
}
