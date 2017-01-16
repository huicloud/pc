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

import '../util'
import "../js/DateUtil.js" as DateUtil

BaseCanvas {
    id: root

    property string obj
    property string period
    property int split: 1

    property var stock: StockUtil.stock.createObject(root);

    property var historyMinParams

    onVisibleChanged: {
        historyMinParams = null;
    }

    onObjChanged: {
        historyMinParams = null;
    }

    onSplitChanged: {
        historyMinParams = null;
    }

    onPeriodChanged: {
        historyMinParams = null;
    }

    property var showMenuItems: [
        {
            text: '十字线',
            checked: root.enableCrossline,
            triggered: function() {
                root.enableCrossline = !root.enableCrossline
            }
        },
        {
            text: '除权',
            checked: root.split !== 1,
            triggered: function() {
                if (root.split === 1) {
                    root.split = 0;
                } else {
                    root.split = 1;
                }
            }
        }/*,
        {
            text: 'MA均线',
            checked: maChart.visible,
            triggered: function(item) {
                maChart.visible = !item.checked;
            }
        }*/
    ]

    KlineChart { id: klineChart }
    VOLChart { dataProvider: klineChart.dataProvider }
    MAChart { id: maChart; tabTitle: 'MA(主图)' }
    TSChart { tabTitle: '九转指标(主图)'; tabWidth: 120  }
    DDEChart { }
    MACDChart { }
    KDJChart { }
    RSIChart { }

    Component.onCompleted: {

        // 初始选中第一个指标（MA）
        indicatorTabBar.checkedTabs = [maChart];
    }

    Keys.onUpPressed: {
        mainChart.xAxis.lessData();
    }

    Keys.onDownPressed: {
        mainChart.xAxis.moreData();
    }

    Keys.onSpacePressed: {
        showHistoryMin();
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_F11) {
            root.split = (root.split + 1) % 2;
            event.accepted = true;
        }
    }

    function showHistoryMin() {
        var xAxis = klineChart.xAxis;
        var time = xAxis.mouseXData;
        var data = klineChart.chartData[xAxis.mouseIndex];
        if (period === '1day' && time > 0 && data && data.lastClose) {
            var date = DateUtil.moment.unix(time).format('YYYYMMDD');
            root.historyMinParams = {
                obj: root.obj,
                date: date,
                lastClose: data.lastClose,
                close: function() {
                    root.historyMinParams = null;
                }
            };
        } else {
            root.historyMinParams = null;
        }
    }

    function beforeEscapePressed(event) {
        if (root.historyMinParams) {
            root.historyMinParams = null;
            event.accepted = true;
            return false;
        }
    }
    function afterLeftPressed(event) {
        if (root.historyMinParams) {
            root.showHistoryMin();
        }
    }
    function afterRightPressed(event) {
        if (root.historyMinParams) {
            root.showHistoryMin();
        }
    }
}
