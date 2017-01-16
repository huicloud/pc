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

import "../js/Util.js" as Util

// 会收入指标栏的指标图
BaseChart {
    id: root

    property bool indicatorChart: true

    // 显示在指标栏上的标题
    property string tabTitle: '指标'

    property real tabWidth: 100

    property bool tabVisible: availability

    signal close

    property string name

    property var parameter: undefined

    property var text: undefined

    property string obj: canvas.obj
    property string period: canvas.period
    property int split: canvas.split
    property var stock: canvas.stock

    // 范围判断取JieGuo中的字段
    property var rangeJieGuoField: []

    // 缓存时间和数据对应表，用作查找光标时间对应数据（避免下标查找数据不准确）
    property var timeMap: ({})

    // 十字光标位置的数据（默认是最后一条数据）
    property var indexData: {
        if (root.skip) {
            return;
        }

        var time = xAxis.mouseXData;
        if (time && timeMap) {
            return timeMap[time];
        } else {
            return chartData[chartData.length - 1];
        }

//        var lastIndex = xAxis.lastIndex;
//        if (lastIndex === -1) {
//            return chartData[chartData.length - 1];
//        } else {
//            var index = chartData.length - lastIndex;
//            return chartData[index];
//        }
    }

    dataProvider: KlineChartDataProvider {
        parent: root
        serviceUrl: '/indicator/calc'
        params: ({
                     name: root.name,
                     parameter: root.parameter,
                     text: root.text,
                     obj: root.obj,
                     period: root.period,
                     split: root.split
                 })
        chart: root

        requestOffsetPosition: xAxis.requestOffsetPosition

        function adapt(nextData) {
            return nextData[0].ShuJu || [];
        }
    }

    yAxis: YAxis {
        chart: root
        chartData: [dataProvider.chartData, root.xAxis.lastTime]
    }

    function getRange() {
        return getRangeMaxMin();
    }

    // 通过计算最大值和最小值确定范围
    function getRangeMaxMin() {
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        var maxFun = Math.max;
        var minFun = Math.min;
        var lastTime = root.xAxis.lastTime;
        var timeMap = [];
        var rangeJieGuoField = root.rangeJieGuoField;
//        root.chartData = dataProvider.chartData.filter(function(eachData) {
//            if (eachData.ShiJian <= lastTime) {
//                timeMap[eachData.ShiJian] = eachData;
//                rangeJieGuoField.forEach(function(field) {
//                    var data = eachData.JieGuo[field];
//                    max = maxFun(data, max);
//                    min = minFun(data, min);
//                });
//                return true;
//            }
//        });
        root.chartData = dataProvider.chartData.filter(function(eachData) {
            if (eachData.ShiJian <= lastTime) {
                timeMap[eachData.ShiJian] = eachData;
                var jieGuo = eachData.JieGuo;
                var jieGuo1 = jieGuo[rangeJieGuoField[0]] || null;
                var jieGuo2 = jieGuo[rangeJieGuoField[1]] || null;
                var jieGuo3 = jieGuo[rangeJieGuoField[2]] || null;
                var jieGuo4 = jieGuo[rangeJieGuoField[3]] || null;
                var jieGuo5 = jieGuo[rangeJieGuoField[4]] || null;
                var jieGuo6 = jieGuo[rangeJieGuoField[5]] || null;
                max = maxFun(max, jieGuo1, jieGuo2, jieGuo3, jieGuo4, jieGuo5, jieGuo6);
                min = minFun(min, jieGuo1, jieGuo2, jieGuo3, jieGuo4, jieGuo5, jieGuo6);
                return true;
            }
        });
        root.timeMap = timeMap;
        return [max, min];
    }

    // 通过计算最大绝对值确定范围
    function getRangeAbsMax() {
        var max = Number.MIN_VALUE;
        var lastTime = root.xAxis.lastTime;
        var timeMap = [];
        var maxFun = Math.max;
        var absFun = Math.abs;
        var rangeJieGuoField = root.rangeJieGuoField;
//        root.chartData = dataProvider.chartData.filter(function(eachData) {
//            if (eachData.ShiJian <= lastTime) {
//                timeMap[eachData.ShiJian] = eachData;
//                rangeJieGuoField.forEach(function(field) {
//                    var data = absFun(eachData.JieGuo[field]);
//                    max = maxFun(data, max);
//                });
//                return true;
//            }
//        });
        root.chartData = dataProvider.chartData.filter(function(eachData) {
            if (eachData.ShiJian <= lastTime) {
                timeMap[eachData.ShiJian] = eachData;
                var jieGuo = eachData.JieGuo;
                var jieGuo1 = absFun(jieGuo[rangeJieGuoField[0]]) || null;
                var jieGuo2 = absFun(jieGuo[rangeJieGuoField[1]]) || null;
                var jieGuo3 = absFun(jieGuo[rangeJieGuoField[2]]) || null;
                var jieGuo4 = absFun(jieGuo[rangeJieGuoField[3]]) || null;
                max = maxFun(max, jieGuo1, jieGuo2, jieGuo3, jieGuo4);
                return true;
            }
        });
        root.timeMap = timeMap;
        return [max, -max];
    }

    function getYTickLabel(value) {
        return Util.formatStockText(value, 2, null, false);
    }

    function getYTicksAbsMax(max, min, yOffset, height, minHeightPerTick) {
        var count = Math.floor(height / minHeightPerTick);
        count -= (count % 2 === 1 ? 1 : 0);
        var diff = max - min;
        var diffPerTick = diff / (count + 1);
        var heightPerTick = height / (count + 1);
        var middleY = yAxis.getY(0);
        var ticks = [];
        ticks.push({
                        position: middleY,
                        value: 0,
                        label: 0,
                    });
        for (var i = 1; i <= count / 2; i++) {
            var value = i * diffPerTick;
            var offsetPosition = i * heightPerTick;
            ticks.unshift({
                            position: middleY - offsetPosition,
                            value: value,
                            label: getYTickLabel(value),
                        });
            ticks.push({
                            position: middleY + offsetPosition,
                            value: -value,
                            label: getYTickLabel(-value),
                        });
        }
        return ticks;
    }

    function drawPath(points, color) {
        var pathFigure = {
            name: 'Path',
            points: points,
            lineWidth: defaultLineWidth,
            strokeStyle: color
        };
        figureData.push(pathFigure);
        canvas.draw(pathFigure);
    }

    function getLineFigure(x1, y1, width, y2, lineWidth, strokeStyle) {
        return {
            name: 'Line',
            x1: x1,
            y1: y1,
            x2: x1,
            y2: y2,
            lineWidth: lineWidth,
            style: strokeStyle
        }
    }

    function getRectFigure(x1, y1, width, y2, lineWidth, strokeStyle, fillStyle) {
        return {
            name: 'Rect',
            x: x1,
            y: y1,
            width: width,
            height: y2 - y1,
            strokeStyle: strokeStyle,
            fillStyle: fillStyle,
            lineWidth: lineWidth
        }
    }
}
