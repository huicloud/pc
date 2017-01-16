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

import "./"
import "../core"
import "../controls"

Drawable {
    id: root

    objectName: 'BaseChart'

    property int flex: 1

    // 标志该图形是否有效，需要具体图形根据一定条件判断（无效的图形不会显示出来）
    property bool availability: true

    // 默认宽高
    width: parent ? parent.width : 0
    height: canvas.heightPerChart * flex || 0

    property int chartType: 0

    readonly property int chart_type_common: 0

    // 主图
    readonly property int chart_type_main: 1

    // 附属图，显示在主图上
    readonly property int chart_type_attach: 2

    property var dataProvider

    property var chartData: dataProvider ? dataProvider.chartData : []

    property var xAxis: canvas.mainChart && canvas.mainChart.xAxis

    property var yAxis: YAxis { chart: root }

    // 当坐标轴有变化或者数据变化时dirty置为true
    property bool axisDirty: (xAxis ? xAxis.isDirty : false) || (yAxis ? yAxis.isDirty : false)
    onAxisDirtyChanged: {
        isDirty = axisDirty || isDirty;
        if (canvas && isDirty) {
            canvas && canvas.requestPaint();
        }
    }
//    onChartDataChanged: { isDirty = true; canvas && canvas.requestPaint() }

//    property var range: dataProvider ? dataProvider.range : []

    property var topComponentModel: []
    property Component topComponent: TopComponent {
        chart: root
        model: topComponentModel
    }

    property var tooltipComponentModel: []

    readonly property real topComponentHeight: topComponentLoader.visible ? topComponentLoader.height : 0

    property int separatorLineWidth: 1

    property alias topComponentLoader: topComponentLoader

    property bool skip: false
    property string skipTip

    // 头部提示区域
    Loader {
        id: topComponentLoader
        width: parent.width
        anchors.top: parent.top
        sourceComponent: topComponent
        visible: topComponentModel && topComponentModel.length > 0
    }

    // 分割线
    SeparatorLine {
        id: separatorLine
        anchors.top: parent.top
        orientation: Qt.Horizontal
        length: parent.width
        separatorWidth: separatorLineWidth
    }

    // 不画图时显示信息
    Rectangle {
        visible: root.skip
        anchors.top: topComponentLoader.top
        anchors.bottom: parent.bottom
        width: parent.width
        color: 'transparent'
        Text {
            anchors.centerIn: parent
            text: root.skipTip
        }
    }

    function redraw() {
        if (skip || !visible || redrawCount === canvas.redrawCount) {
            return;
        }
        redrawCount = canvas.redrawCount;

        // 先画出坐标轴和网格
        xAxis.redraw();
        yAxis.redraw();

        if (isDirty) {
            _redraw();
            isDirty = false;
        } else {

            // 将chartData中对应数据按顺序画到画板上
            figureData.forEach(function(eachFigure) {

                // 使用canvas（在外部作用范围中能找到的画板对象，注意从Chart到Canvas的范围中不要重定义canvas这个id的对象）
                canvas.draw(eachFigure);
            });
        }
    }

    function getYTicks(max, min, yOffset, height, minHeightPerTick) {
        if (max === Number.MIN_VALUE) {
            max = min = 0;
        }

        var count = Math.floor(height / minHeightPerTick);
        var heightPerTick = height / count;
        var valuePerTick = (max - min) / count;
        var ticks = [];

        for (var i = 0; i < count; i++) {
            var value = max - (valuePerTick * i);
            ticks.push({
                position: yOffset + heightPerTick * i,
                value: value,
                label: getYTickLabel(value)
            });
        }
        return ticks;
    }

    function getYTickLabel(value) {
        return value;
    }

    function getRange() {
        return [Number.MIN_VALUE, Number.MAX_VALUE];
    }
}
