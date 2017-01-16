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
import "../js/Util.js" as Util

VOLChart {
    rectChart: false

    function cacheChangedFun() {

        // 计算最大值和最小值
        var max = Number.MIN_VALUE;
        for (var key in cache) {
            max = Math.max(max, (cache[key] && cache[key].ChengJiaoLiang) || Number.MIN_VALUE);
        }

        yMin = 0;
        yMax = max + (max) * 0.1;
    }

    function drawChart() {
        var lastPrice = cache.lastClose;
        var minTimes = cache.minTimes;

        if (minTimes) minTimes.forEach(function (time, index) {
            var minData = cache[time];
            if (minData) {
                if (minData.isUp === undefined) {
                    minData.isUp = minData.ChengJiaoJia >= lastPrice;
                }
                drawVOL(time, minData.ChengJiaoLiang, minData.isUp);
                lastPrice = minData.ChengJiaoJia;
            }
        });
    }

    function drawYAxisTicks() {
        yAxis.ticks.forEach(function(tick) {
            var text = Util.formatStockText(tick.value / volumeUnit, 2, '万/亿', false);
            if (leftSpace !== 0) {
                drawTextAlignRight(text, leftSpace - 10, tick.position + fontSize / 2, fontSize, tickColor);
            }
            if (rightSpace !== 0) {
                drawText(text, chartWidth - rightSpace + 10, tick.position + fontSize / 2, fontSize, tickColor);
            }
        });
    }

    function drawBackground() {

        // 画出集合竞价背景
        if (cache._minTimes) {
            var auctionEndTime = cache._minTimes[cache._auctionIndex];
            var auctionEndX = xAxis.getCenterX(auctionEndTime);
            if (auctionEndX !== NaN) {
                var auctionStartX = xAxis.getLeftX(cache._minTimes[0]);
                drawRect(auctionStartX, 0 + topSpace, auctionEndX - auctionStartX, chartHeight - topSpace - bottomSpace, 'transparent', '#f2f5ff');
            }
        }

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
}
