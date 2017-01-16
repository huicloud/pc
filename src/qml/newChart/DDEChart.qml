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

BaseChart {
    id: root

    flex: 3

    property bool indicatorChart: true
    property string tabTitle: 'DDE决策'
    property real tabWidth: 100
    property bool tabVisible: availability

    signal close

    property string obj: canvas.obj
    property string period: canvas.period
    property var stock: canvas.stock

    // 限制沪深A股
    availability: obj.match(/^[SH|SZ]/) && stock.type === 1

    // 限制日K
    skip: period !== '1day'
    skipTip: '本指标仅适用于日K线周期'

    yAxis: YAxis {
        chart: root
        function getYAxisCrossLine() {
            return ddxChart.yAxis.getYAxisCrossLine() ||
                    ddyChart.yAxis.getYAxisCrossLine() ||
                    ddzChart.yAxis.getYAxisCrossLine();
        }
    }

    onAxisDirtyChanged: {

        // 保证DDE图位置变化时，子图坐标轴可以重绘
        if (axisDirty) {
            ddxChart.yAxis.isDirty = true;
            ddyChart.yAxis.isDirty = true;
            ddzChart.yAxis.isDirty = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        DDXChart {
            id: ddxChart
            skip: root.skip
            Layout.fillWidth: true
            Layout.fillHeight: true
            onClose: {
                root.close();
            }
        }
        DDYChart {
            id: ddyChart
            skip: root.skip
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        DDZChart {
            id: ddzChart
            skip: root.skip
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    function redraw() {
        ddxChart.redraw();
        ddyChart.redraw();
        ddzChart.redraw();
        root.xAxis.isDirty = false;
        root.yAxis.isDirty = false;
    }
}
