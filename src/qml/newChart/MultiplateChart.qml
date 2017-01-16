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

BaseChart {
    id: root

    property var mainChart
    property var attachCharts

    // 所有的图
    property var _charts: [mainChart].concat(attachCharts)

    // 所有可见的图
    property var charts: _charts.filter(function(eachChart) { return eachChart && eachChart.visible })

    chartData: charts.map(function(eachChart) { return eachChart.dataProvider ? eachChart.dataProvider.chartData : eachChart.chartData })

    topComponentModel: Array.prototype.concat.apply([], charts.map(function(eachChart) { return eachChart.topComponentModel }))

    on_ChartsChanged: {
        _charts.forEach(function(eachChart) {
            eachChart.parent = root;
            eachChart.width = root.width;
            eachChart.height = root.height;
            eachChart.yAxis = root.yAxis;
            eachChart.topComponent = null;
            eachChart.separatorLineWidth = 0;
        });
    }

    function getYTicks(max, min, yOffset, height, minHeightPerTick) {
        return mainChart.getYTicks(max, min, yOffset, height, minHeightPerTick);
    }

    function getYTickLabel(value) {
        return mainChart.getYTickLabel(value);
    }

    property var close: {
        var result;
        for (var i = charts.length; i > 0; i--) {
            var chart = charts[i - 1];
            if (chart.close) {
                result = chart.close;
                break;
            }
        }
        return result;
    }

    function getRange() {
        return charts.reduce(function(result, currentChart) {
            var range = currentChart.getRange();
            result[0] = Math.max(result[0], range[0]);
            result[1] = Math.min(result[1], range[1]);
            return result;
        }, [Number.MIN_VALUE, Number.MAX_VALUE]);
    }
}
