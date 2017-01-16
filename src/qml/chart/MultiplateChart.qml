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

/**
 * 复合图，支持多个图形叠加
 */
BaseChart {
    id: root

    property list<Item> charts
    default property alias _charts: root.charts

    showYAxis: true
    yAxis: YAxis {
        charts: root.charts.length > 0 ? Array.prototype.map.call(root.charts, function(eachChart) {return eachChart}) : [root];
    }

    children: [canvas].concat(Array.prototype.map.call(charts, function(eachChart) {
        eachChart.canvas = canvas;
        eachChart.xAxis = xAxis;
        eachChart.yAxis = yAxis;
        return eachChart;
    }))

    function redraw() {
        Array.prototype.forEach.call(charts, function(eachChart) {
            if (eachChart.visible) eachChart.redraw();
        });
    }

    onShowXAxisChanged: {
        Array.prototype.forEach.call(charts, function(eachChart) {
            eachChart.showXAxis = root.showXAxis;
        });
    }
}
