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
import QtQuick.Window 2.2

import "./"
import "../core"
import '../controls'

ContextComponent {
    id: canvas

    readonly property alias _canvas: canvas

    readonly property int devicePixelRatio: Screen.devicePixelRatio
    readonly property var ctx: internalCanvas.context

    property list<Item> charts;
    default property alias _charts: canvas.charts

    // 筛选所有chart
    property var chartArray: Array.prototype.filter.call(charts, function(eachChart) {
        return eachChart.objectName.toLowerCase().indexOf('chart') >= 0;
    })
    property var visibleCharts: chartArray.filter(function(eachChart) { return eachChart.visible && eachChart.availability })

    property bool _enableCrossline: false
    property bool enableCrossline: _enableCrossline

    // x轴高度，等于0则不显示x轴
    property int xAxisHeight: 20

    // 左侧的y轴宽度，等于0则不显示左侧y轴
    property int leftYAxisWidth: 80

    // 右侧的y轴宽度，等于0则不显示右侧y轴
    property int rightYAxisWidth: 80

    property var mainChart
    property var attachCharts: []
    property var commonCharts: []

    property int visibleChartFlexCount: visibleCharts.reduce(function(result, eachChart) {
        if (eachChart.chartType !== eachChart.chart_type_attach) {
            result += eachChart.flex;
        }
        return result;
    }, 0) || 1

    property real heightPerChart: chartContainer.height / visibleChartFlexCount

    property alias chartContainer: chartContainer

    property alias crossLineCanvas: crossLineCanvas

    property alias indicatorTabBar: indicatorTabBar

    readonly property alias redrawCount: internalCanvas.redrawCount

    property real crossLineWidth: theme.chartCrossLineWidth
    property color crossLineColor: theme.chartCrossLineColor
    property color crossLineLabelColor: theme.chartCrossLineLabelColor
    property color crossLineLabelTextColor: theme.chartCrossLineLabelTextColor
    property string crossLineLabelFontFamily: theme.chartCrossLineLabelFontFamily
    property int crossLineLabelFontSize: theme.chartCrossLineLabelFontSize
    property string crossLineLabelFontStyle: [crossLineLabelFontSize, 'px ', '"', crossLineLabelFontFamily, '"'].join('')

    property bool forceFocus: true

    property var tooltipComponentModel: Array.prototype.concat.apply([], visibleCharts.map(function(eachChart) { return eachChart.tooltipComponentModel }))
    property var customButtons: Array.prototype.concat.apply([], visibleCharts.map(function(eachChart) { return eachChart.customButtons || [] }))

    property Component tooltipComponent: ChartTooltip {
        model: tooltipComponentModel
    }

    onVisibleChanged: {
        visible && forceFocus && forceActiveFocus();
    }

    // 将所有图按照类型分为主图，附图和其它
    onChartArrayChanged: {
        var mainChart;
        var attachCharts = [];
        var commonCharts = [];
        chartArray.forEach(function(eachChart, index) {
            if (eachChart.chartType === eachChart.chart_type_main) {
                mainChart = eachChart;
            } else if (eachChart.chartType === eachChart.chart_type_attach) {
                attachCharts.push(eachChart);
            } else if (eachChart.chartType === eachChart.chart_type_common) {
                commonCharts.push(eachChart);
            }
        });
        canvas.mainChart = mainChart;
        canvas.attachCharts = attachCharts;
        canvas.commonCharts = commonCharts;
    }

    // 底层画板
    Canvas {
        id: internalCanvas

        contextType: '2d'
        width: root.width * canvas.devicePixelRatio
        height: root.height * canvas.devicePixelRatio

        // 注释掉使用默认的Canvas.Immediate, 修复bug ZYPC-384
//        renderStrategy: Canvas.Threaded

        transformOrigin: Item.TopLeft

        scale: 1 / devicePixelRatio

        // 重绘计数，控制在相同一次绘制画板时坐标轴不会重复绘制
        property int redrawCount: 0

        onPaint: {
            if (visible && ctx) {

                // 还是考虑将当前画板上所有的图都重画一遍，避免如果单独重画某一部分图形时造成图形不一致的情况
                ctx.reset();
                ctx.scale(devicePixelRatio, devicePixelRatio);
                redrawCount++;
                visibleCharts.forEach(function(eachChart) {
                    if (eachChart.visible) {
                        eachChart.redraw(canvas);
                    }
                });
            }
        }

        Canvas {
            id: crossLineCanvas
            contextType: '2d'

            width: parent.width
            height: parent.height
            renderStrategy: Canvas.Threaded
            onPaint: {

                // 根据XAxis和YAxis设置画出十字光标
                if (context) {
                    context.reset();
                    context.scale(devicePixelRatio, devicePixelRatio);

                    if (enableCrossline) {

                        // x轴上位置
                        var xAxisCrossLine = mainChart.xAxis.getXAxisCrossLine();

                        if (xAxisCrossLine) {
                            var x = xAxisCrossLine.position;
                            var label = xAxisCrossLine.label;
                            drawCrossLineXAxisTick(context, label, x);
                        }

                        // 循环请求每个chart, 找到y轴上位置
                        visibleCharts.some(function(eachChart) {
                            var yAxisCrossLine = eachChart.yAxis.getYAxisCrossLine();
                            if (yAxisCrossLine) {
                                var y = yAxisCrossLine.position;
                                var label = yAxisCrossLine.label;
                                var bound = yAxisCrossLine.bound;
                                drawCrossLineYAxisTick(context, label, y, bound);
                                return true;
                            }
                        });
                    }
                }
            }
        }

        onVisibleChanged: {
            requestPaint();
        }
    }

    onEnableCrosslineChanged: { crossLineCanvas.requestPaint() }

    property real _mouseX: -1
    property real _mouseY: -1

    property real mouseX: enableCrossline ? _mouseX : -1
    property real mouseY: enableCrossline ? _mouseY : -1

    MouseArea {
        id: crossLineMouseArea
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: indicatorTabBar.top
        hoverEnabled: true
        propagateComposedEvents: true

        onPositionChanged: {
            root._mouseX = mouse.x;
            root._mouseY = mouse.y;
        }

        onExited: {
            root._mouseX = -1;
            root._mouseY = -1;
        }
        onPressed: {
            if (forceFocus) {
                forceActiveFocus();
            }
            if (!_enableCrossline) {
                _enableCrossline = true;
            }
        }
    }

    Column {
        id: chartContainer
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: indicatorTabBar.top

        // 如果显示X轴的话，底部保留X轴的高度
        anchors.bottomMargin: xAxisHeight > 0 ? xAxisHeight : 0

        // 主图和附图
        MultiplateChart {
            id: mainMultiplateChart
            parent: chartContainer
            mainChart: canvas.mainChart
            attachCharts: canvas.attachCharts
            separatorLineWidth: 0
            flex: 2
        }

        Column {
            width: parent.width
            children: canvas.commonCharts
        }
//        SeparatorLine {
//            orientation: Qt.Horizontal
//            length: parent.width
//        }
    }

    Loader {
        id: tooltip
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: mainMultiplateChart.topComponentHeight
        width: leftYAxisWidth
        sourceComponent: tooltipComponent
    }

    // 指标tabbar
    TabBar {
        id: indicatorTabBar
        anchors.bottom: parent.bottom
        width: parent.width
        height: indicatorCharts.length > 0 ? 24 : 0
        multipleCheckedEnable: true
        initTabIndex: -1

        property var loadedCharts: []

        // 筛选指标图
        property var indicatorCharts: chartArray.filter(function(eachChart) { return eachChart.indicatorChart })

        tabs: indicatorCharts || []

        onIndicatorChartsChanged: {
            indicatorCharts.forEach(function(eachChart) {
                if (loadedCharts.indexOf(eachChart) < 0) {

                    // 绑定显示条件
                    eachChart.visible = Qt.binding(function() { return eachChart.tabVisible && indicatorTabBar.checkedTabs.indexOf(eachChart) >= 0 });

                    // 监听关闭事件
                    eachChart.close && eachChart.close.connect(function() {
                        indicatorTabBar.currentIndex = -1;
                        var index = indicatorTabBar.checkedTabs.indexOf(eachChart);
                        if (index >= 0) {
                            indicatorTabBar.checkedTabs.splice(index, 1);
                            indicatorTabBar.checkedTabs = [].concat(indicatorTabBar.checkedTabs);
                        }
                    });
                }
            });
        }

        property bool changing;
        onCheckedTabsChanged: {
            if (changing) {
                return;
            }

            // 筛选保证主图和附图中指标各自只能选中一个
            var checkedTabs = indicatorTabBar.checkedTabs;
            if (checkedTabs.length > 1) {
                changing = true;
                var mark = 0;
                var types = [1, 2, 4]
                indicatorTabBar.checkedTabs = checkedTabs.reverse().filter(function(eachChart) {
                    var type = types[eachChart.chartType];
                    var nextMark = mark | type;
                    var result = nextMark !== mark;
                    mark = nextMark;
                    return result;
                });
                changing = false;
            }
        }

        SeparatorLine {
            anchors.top: parent.top
            orientation: Qt.Horizontal
            length: parent.width
        }
    }

    function requestPaint() {
        internalCanvas.requestPaint();
    }

    function draw(figure) {
        if (figure) {
            var drawFun = canvas['draw' + figure.name] || noop;
            drawFun(figure);
        }
    }

    function noop() {}

    function drawLine(options) {
        _drawLine(ctx, options.x1, options.y1, options.x2, options.y2, options.lineWidth, options.style);
    }

    function _drawLine(ctx, x1, y1, x2, y2, lineWidth, style) {

        // 画成点
        if (x1 === x2 && Math.abs(y1 - y2) < 0.5) {
            _drawRect(ctx, x1, y1, 0.5, 1, style, null, 1);
            return;
        }

        var _normalizeDrawLinePoint = root._normalizeDrawLinePoint;
        ctx.beginPath();
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = style;
        ctx.moveTo(_normalizeDrawLinePoint(x1), _normalizeDrawLinePoint(y1));
        ctx.lineTo(_normalizeDrawLinePoint(x2), _normalizeDrawLinePoint(y2));
        ctx.stroke();
    }

    function drawRect(options) {
        _drawRect(ctx, options.x, options.y, options.width, options.height, options.strokeStyle, options.fillStyle, options.lineWidth);
    }

    function _drawRect(ctx, x, y, width, height, strokeStyle, fillStyle, lineWidth) {
        var _normalizeDrawLinePoint = root._normalizeDrawLinePoint;
        var _normalizeSize = root._normalizeSize;
        ctx.lineWidth = lineWidth;
        if (fillStyle) {
            ctx.fillStyle = fillStyle;
            ctx.fillRect(_normalizeDrawLinePoint(x), _normalizeDrawLinePoint(y), _normalizeSize(width), _normalizeSize(height));
        }
        ctx.strokeStyle = strokeStyle;
        ctx.strokeRect(_normalizeDrawLinePoint(x), _normalizeDrawLinePoint(y), _normalizeSize(width), _normalizeSize(height));
    }

    function drawText(options) {
        _drawText(ctx, options.text, options.x, options.y, options.fontStyle, options.fillStyle, options.align, options.bound);
    }

    function _drawText(ctx, text, x, y, fontStyle, fillStyle, alignPosition, bound) {
        ctx.font = fontStyle;
        var size = ctx.measureText(text);
        var width = size.width;
        var fontSize = parseInt(fontStyle.match(/(\d+)px/)[1]);
        var height = fontSize;

        if (alignPosition === 'center') {
            x = x - width / 2;
        } else if (alignPosition === 'right') {
            x = x - width;
        }

        if (bound) {
            if (x < bound.left) {
                x = bound.left;
            } else if (x + width > bound.right) {
                x = bound.right - width;
            }
            if (y < bound.top + height) {
                y = bound.top + height;
            } else if (y > bound.bottom) {
                y = bound.bottom;
            }
        }

        ctx.fillStyle = fillStyle;
        ctx.fillText(text, x, y);
    }

    function drawPath(options) {
        _drawPath(ctx, options.points, options.lineWidth, options.strokeStyle, options.fillStyle);
    }

    function _drawPath(ctx, points, lineWidth, strokeStyle, fillStyle) {
        var _normalizeDrawLinePoint = root._normalizeDrawLinePoint;
        ctx.beginPath();
        points.forEach(function (eachPoint, index) {
            if (index === 0) {
                ctx.moveTo(_normalizeDrawLinePoint(eachPoint[0]), _normalizeDrawLinePoint(eachPoint[1]));
            } else {
                ctx.lineTo(_normalizeDrawLinePoint(eachPoint[0]), _normalizeDrawLinePoint(eachPoint[1]));
            }
        });

        ctx.lineJoin = 'round';
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = strokeStyle;
        ctx.stroke();

        if (fillStyle && points.length > 1) {
            ctx.lineWidth = 0;
//            ctx.lineTo(_normalizeDrawLinePoint(points[points.length - 1][0]), _normalizeDrawLinePoint(y0));
//            ctx.lineTo(_normalizeDrawLinePoint(points[0][0]), _normalizeDrawLinePoint(y0));
            ctx.closePath();
            ctx.fillStyle = fillStyle;
            ctx.fill();
        } else {
            ctx.closePath();
        }
    }

    function drawCircle(options) {
        _drawCircle(ctx, options.x, options.y, options.radius, options.strokeStyle, options.fillStyle, options.lineWidth);
    }

    function _drawCircle(ctx, x, y, radius, strokeStyle, fillStyle, lineWidth) {
        ctx.beginPath();
        ctx.arc(x, y, radius, 0, Math.PI * 2);
        ctx.closePath();
        ctx.fillStyle = fillStyle;
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = strokeStyle;
        ctx.fill();
        ctx.stroke();
    }

    function drawCrossLineXAxisTick(ctx, label, x) {
        var y1 = 0;
        var y2 = chartContainer.height;
        var dashPatten = ctx.createPattern(crossLineColor, Qt.Dense5Pattern);
        _drawLine(ctx, x, y1, x, y2, crossLineWidth, dashPatten);

        var textY = y2 + crossLineLabelFontSize + 2;

        // qml bug, fillStyle和strokeStyle是相同color对象时会引起接下来使用createPattern样式画线出问题
//        _drawRect(ctx, x - 50, y2, 100, xAxisHeight, crossLineLabelColor, crossLineLabelColor);
        var crossLineLabelColor = root.crossLineLabelColor.toString();
        _drawRect(ctx, x - 50, y2, 100, xAxisHeight, crossLineLabelColor, crossLineLabelColor);
        _drawText(ctx, label, x, textY, crossLineLabelFontStyle, crossLineLabelTextColor, 'center');
    }

    function drawCrossLineYAxisTick(ctx, label, y, bound) {
        var height = crossLineLabelFontSize + 4;
        var bottomY = y + height / 2;
        if (bound) {
            bottomY = Math.max(Math.min(bottomY, bound.bottom), bound.top + height);
        }
        var textY = bottomY - 2;

        var x1 = leftYAxisWidth;
        var x2 = width - rightYAxisWidth;
        var dashPatten = ctx.createPattern(crossLineColor, Qt.Dense5Pattern);
        _drawLine(ctx, x1, y, x2, y, crossLineWidth, dashPatten);

        var fontStyle = crossLineLabelFontStyle;
        var crossLineLabelColor = root.crossLineLabelColor.toString();
        if (leftYAxisWidth) {
            _drawRect(ctx, 0, bottomY, leftYAxisWidth, -height, crossLineLabelColor, crossLineLabelColor);
            _drawText(ctx, label, leftYAxisWidth - 10, textY, fontStyle, crossLineLabelTextColor, 'right');
        }
        if (rightYAxisWidth) {
            _drawRect(ctx, x2, bottomY, rightYAxisWidth, -height, crossLineLabelColor, crossLineLabelColor);
            _drawText(ctx, label, x2 + 10, textY, fontStyle, crossLineLabelTextColor, 'left');
        }
    }

    function _normalizeDrawLinePoint(point) {
      if (devicePixelRatio === 1) {
        var intPoint = Math.round(point);
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

    function beforeLeftPressed(event) {}
    function afterLeftPressed(event) {}
    function beforeRightPressed(event) {}
    function afterRightPressed(event) {}
    function beforeEscapePressed(event) {}
    function afterEscapePressed(event) {}

    Keys.onPressed: {
        if (event.key === Qt.Key_Left) {
            if (canvas.beforeLeftPressed(event) === false) {
                return;
            }
            if (root.enableCrossline) {
                mainChart.xAxis.moveLeft();
            } else {
                root._enableCrossline = true;
                mainChart.xAxis.moveLeft(true);
            }
            canvas.afterLeftPressed(event);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            if (canvas.beforeRightPressed(event) === false) {
                return;
            }
            if (root.enableCrossline) {
                mainChart.xAxis.moveRight();
            } else {
                root._enableCrossline = true;
                mainChart.xAxis.moveRight(true);
            }
            canvas.afterRightPressed(event);
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            if (canvas.beforeEscapePressed(event) === false) {
                return;
            }

            if (_enableCrossline) {
                _enableCrossline = false;
                event.accepted = true;
            }
            canvas.afterEscapePressed(event);
        }
    }
}
