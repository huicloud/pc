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
import "../components"
import "../js/Util.js" as Util
import "../js/DateUtil.js" as DateUtil

BaseChart {
    id: root

    property var mainMinChart

    property var chartData: []

    property var colors: ['#d959f7', '#ff3838']
    property var texts: ['一突', '双突']

    signal close

    // 显示在指标栏上的标题
    property string tabTitle: '双突战法'

    property real tabWidth: 100

    // 限制沪深A股
    property bool tabVisible: obj.match(/^[SH|SZ]/) && stock.type === 1

    // 保证提前加载选股窗口
    property bool stockSelectionWindowInited: SingletonStockSelectionWindow.inited

    property var customButtons: ['yitu', 'ertu'].map(function(name, index) {
        return {
            text: texts[index] + '选股',
            triggered: function() {
                SingletonStockSelectionWindow.openWindow(appConfig.webUrlMap[name]);
            }
        }
    });

    property var topComponentModel: {
        if (chartData.length > 0) {
            var result = [];
            chartData.map(function(eachData, index) {
                result.push(
                            { text: texts[index], color: colors[index]},
                            { text: 'T' + DateUtil.moment.unix(eachData.time).format('hh:mm'), color: theme.textColor },
                            { text: 'P' + Util.formatStockText(eachData.price, stock.precision, null), color: eachData.isUp ? upColor : downColor }
                            );
            });
            return result;
        } else {
            return [{ text: '今天暂时未发出双突信号', color: theme.textColor }];
        }
    }

    Connections {
        target: root.dataProvider
        onSuccess: {
            root.cache = data;
            canvas.requestPaint();
        }
    }

    function initChart(){}

    function drawBackground() {}

    function drawChart() {
        var getCenterX = xAxis.getCenterX;
        var getY = yAxis.getY;
        var drawTT = root.drawTT;
        var minData = mainMinChart.cache;
        var chartData = [];
        var colors = root.colors;
        var texts = root.texts;

        cache.forEach(function(eachData, index) {
            var data = eachData.JieGuo;
            var one = data[0];
            var two = data[1];
            if (one || two) {
                var time = eachData.ShiJian;
                var min = minData[time] || {};
                var price = min.ChengJiaoJia;
                var isUp = min.isUp;
                chartData.push({time: time, price: price, isUp: isUp, x: getCenterX(eachData.ShiJian), y: getY(price)});
            }
        });

        chartData.forEach(function(eachData, index) {
            if (index > 1) {
                return;
            }
            drawTT(texts[index], eachData.x, eachData.y, colors[index]);
        });
        root.chartData = chartData;
    }

    function drawTT(text, x, y, color) {
        var colorString = color.toString();
        var colorOpacity = ['rgba(' + parseInt(colorString.substr(1, 2), 16),
                            parseInt(colorString.substr(3, 2), 16),
                            parseInt(colorString.substr(5, 2), 16),
                            '0.1)'].join(',')
        drawCircle(x, y, 7, color, colorOpacity, 1);
        drawCircle(x, y, 3, color, color, 0);

        var width = 40;
        var height = 20;
        var halfHeight = height / 2;
        var radius = 2;
        var trangleWidth = 4;
        var trangleHalfWidth = trangleWidth / 2;
        var trangleHeight = 5;
        x -= 8;

        // 指示图形
        ctx.beginPath();
        ctx.moveTo(x, y);
        ctx.lineTo(x - trangleHeight, y + trangleHalfWidth);
        ctx.lineTo(x - trangleHeight, y + halfHeight - radius);
        ctx.quadraticCurveTo(x - trangleHeight, y + halfHeight, x - trangleHeight - radius, y + halfHeight);
        ctx.lineTo(x - trangleHeight - width + radius, y + halfHeight);
        ctx.quadraticCurveTo(x - trangleHeight - width, y + halfHeight, x - trangleHeight - width, y + halfHeight - radius);
        ctx.lineTo(x - trangleHeight - width, y - halfHeight + radius);
        ctx.quadraticCurveTo(x - trangleHeight - width, y - halfHeight, x - trangleHeight - width + radius, y - halfHeight);
        ctx.lineTo(x - trangleHeight - radius, y - halfHeight);
        ctx.quadraticCurveTo(x - trangleHeight, y - halfHeight, x - trangleHeight, y - halfHeight + radius);
        ctx.lineTo(x - trangleHeight, y - trangleHalfWidth);
        ctx.closePath();
        ctx.lineWidth = 1;
        ctx.strokeStyle = color;
        ctx.fillStyle = colorOpacity;
        ctx.fill();
        ctx.stroke();

        drawTextAlignCenter(text, x - trangleHeight - width / 2, y + fontSize / 2 - 2, fontSize, color);
    }
}
