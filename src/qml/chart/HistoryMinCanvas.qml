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
import './'

import '../core'
import '../controls'
import '../util'
import "../js/DateUtil.js" as DateUtil

BaseCanvas {
    id: root
    property string obj: root.historyMinParams ? root.historyMinParams.obj : ''
    property var historyMinParams

    property int leftSpace: 40
    property int rightSpace: 40
    property int fontSize: 10

    property var stock: StockUtil.stock.createObject(root);

    property bool hasData: false

    property string title

    property HistoryMinChartDataProvider minDataProvider: HistoryMinChartDataProvider {
//        obj: historyMinParams ? historyMinParams.obj : ''
//        date: historyMinParams ? historyMinParams.date : ''
//        lastClose: historyMinParams ? historyMinParams.lastClose : ''

        onSuccess: {
            root.hasData = true;
            root.title = stock.name + ' ' + DateUtil.moment(date, 'YYYYMMDD').format('YYYY/MM/DD dddd')
        }

        onError: {
            if (root.historyMinParams) {
                root.historyMinParams.close();
            } else {
                root.hasData = false;
            }
        }
    }

    forceFocus: false
    visible: root.historyMinParams && root.hasData
    chartContainer: panel.contentItem

    onHistoryMinParamsChanged: {
        if (historyMinParams) {
            minDataProvider.obj = historyMinParams.obj;
            minDataProvider.date = historyMinParams.date;
            minDataProvider.lastClose = historyMinParams.lastClose;
            minDataProvider.query();
        } else {
            hasData = false;
        }
    }

    Panel {
        id: panel
        anchors.fill: parent
        leftBorder: 1
        rightBorder: 1
        topBorder: 1
        bottomBorder: 1
        header: Text {
            leftPadding: 10
            color: '#294683'
            text: root.title
        }

        content: BaseChartContainer {
            id: canvas
            MinChart {
                id: minChart
                Layout.fillWidth: true
                Layout.fillHeight: true
                leftSpace: root.leftSpace
                rightSpace: root.rightSpace
                fontSize: root.fontSize
                stock: root.stock
                index: ['SH000001', 'SZ399001', 'SZ399006'].indexOf(root.obj) >= 0
                xAxis: XAxis {
                    chart: minChart
                    data: {
                        return minChart.cache && minChart.cache.minTimes || [];
                    }
                }

                dataProvider: root.minDataProvider
                pressedForce: false
            }
            MinVOLChart {
                id: minVolChart
                dataProvider: root.minDataProvider
                Layout.fillWidth: true
                Layout.preferredHeight: minChart.height / 2
                leftSpace: root.leftSpace
                rightSpace: root.rightSpace
                fontSize: root.fontSize
                xAxis: minChart.xAxis
                stock: root.stock
                pressedForce: false
            }
        }
        function onClickMiniButton() {
            if (root.historyMinParams) {
                root.historyMinParams.close();
            } else {
                root.hasData = false;
            }
        }
    }
}
