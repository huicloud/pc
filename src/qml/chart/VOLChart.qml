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

import "../core"
import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

BaseChart {
    id: volChart

    name: 'VOL'
    showYAxis: true
//    showXAxis: true

//    bottomSpace: 20

    property bool rectChart: xAxis.pixelPer > 4

    onCacheChanged: {
        cacheChangedFun();
    }

    Connections {
        target: volChart.dataProvider
        onSuccess: {
            cache = data;
            canvas.requestPaint();
        }
    }

    function cacheChangedFun() {

        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        cache.forEach(function(eachData) {
            max = Math.max(max, eachData.ChengJiaoLiang);
        });

        yMin = 0;
        yMax = max + (max) * 0.1;
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
        drawYAxisGridLine(chartHeight - bottomSpace);

        // 顶部分隔线
        drawYAxisGridLine(0, 2, '#aec1da');
    }

    function drawChart() {
        cache.forEach(function(eachData, index) {
            var lastClose = eachData.lastClose;

            // 添加数据附加属性
            if (!lastClose) {
                lastClose = eachData.lastClose = index > 0 ? cache[index - 1].ShouPanJia : 0;
                eachData.isUp = isUp(eachData.KaiPanJia, eachData.ShouPanJia, lastClose);
            }
            drawVOL(eachData.ShiJian, eachData.ChengJiaoLiang, eachData.isUp);
        });
    }

    function drawVOL(time, volume, isUp) {
        var width = xAxis.getWidth();
        var x;
        var y = yAxis.getY(volume);
        var height = chartHeight - bottomSpace - y;
        if (y % 1 >= 0.5 && height % 1 >= 0.5) {
            height++;
        }

        var color = isUp ? upColor : downColor;

        if (height > 0) {
            if (rectChart) {
                x = xAxis.getLeftX(time);
                drawRect(x, y, width, height, color, isUp ? '#ffffff' : color);
            } else {
                x = xAxis.getCenterX(time);
                drawLine(x, y, x, chartHeight - bottomSpace, 1, color);
            }
        }
    }

    function isUp(open, close, lastClose) {

      // FIXME 还需要考虑当天收盘和昨收相同的情况
      return open !== close ? close > open : close > lastClose;
    }

    function getYTickLabel(value) {
        return Util.formatStockText(value / volumeUnit, 2, '万/亿', false);
    }
}
