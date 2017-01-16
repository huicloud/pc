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
import '../util'
import '../controls'
import "../js/DateUtil.js" as DateUtil

BaseCanvas {
    id: root
    property string period: '1day'
    property int split: 1
    property alias count: klineDataProvider.count
    property alias showMA: maChart.visible
    property alias showVOL: volChart.visible
    property var stock: StockUtil.stock.createObject(root);

    property var historyMinParams

    // 当K线图状态和参数变化是将历史分时参数删除（隐藏历史分时）
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

//    onCountChanged: {
//        historyMinParams = null;
//    }

    showMenuItems: [
        {
            text: '十字线',
            checked: root.crossLine,
            triggered: function() {
                if (root.crossLine) {
                    root.hideCrossLine();
                } else {
                    root.showCrossLine();
                }
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
        },
        {
            text: 'MA均线',
            checked: maChart.visible,
            triggered: function(item) {
                maChart.visible = !item.checked;
            }
        }
    ]

    chartContainer: canvas
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.showCrossLine();
                }
//                onDoubleClicked: {
//                    root.showHistoryMin();
//                }
            }
            BaseChartContainer {
                id: canvas
                anchors.fill: parent

                MultiplateChart {
                    id: mainChart
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 100
                    xAxis: klineChart.xAxis
                    topSpace: klineChart.topSpace
                    tooltipComponent: klineChart.tooltipComponent
                    stock: root.stock
                    z: 100
                    KlineChart {
                        id: klineChart
                        period: root.period
                        anchors.fill: parent
                        stock: root.stock
                        topSpace: maChart.visible ? maChart.topSpace : 0
                        dataProvider: KlineChartDataProvider {
                            id: klineDataProvider
                            serviceUrl: '/quote/kline'
                            count: root.count
                            params: ({
                                obj: root.obj,
                                period: root.period,
                                split: root.split
                            })
                        }
                    }
                    MAChart {
                        id: maChart
                        stock: root.stock
                        dataProvider: KlineChartDataProvider {
                            id: maDataProvider
                            count: root.count
                            serviceUrl: '/indicator/calc'
                            params: ({
                                         name: 'MA',
                                         parameter: 'P1=5,P2=10,P3=20,P4=30,P5=60,P6=120',
                                         obj: root.obj,
                                         period: root.period,
                                         split: root.split
                                     })
                            function adapt(nextData) {
                                return nextData[0].ShuJu;
                            }
                        }
                        anchors.fill: parent
                        xAxis: klineChart.xAxis
                    }
                }

                VOLChart {
                    id: volChart
                    dataProvider: klineDataProvider
                    Layout.fillWidth: true
                    Layout.preferredHeight: canvas.chartHeightPer
                    xAxis: klineChart.xAxis
                    stock: root.stock
                }

                MACDChart {
                    id: macdChart
                    Layout.fillWidth: true
                    Layout.preferredHeight: canvas.chartHeightPer
                    xAxis: klineChart.xAxis
                    stock: root.stock
                    visible: indicatorTab.tabName === name
                    dataProvider: KlineChartDataProvider {
                        count: root.count
                        serviceUrl: '/indicator/calc'
                        params: ({
                                     name: 'MACD',
                                     parameter: 'SHORT=12,LONG=26,M=9',
                                     obj: root.obj,
                                     period: root.period,
                                     split: root.split
                                 })
                        function adapt(nextData) {
                            return nextData[0].ShuJu;
                        }
                    }
                    onClose: {
                        indicatorTab.currentIndex = -1;
                    }
                }
                KDJChart {
                    id: kdjChart
                    Layout.fillWidth: true
                    Layout.preferredHeight: canvas.chartHeightPer
                    xAxis: klineChart.xAxis
                    stock: root.stock
                    visible: indicatorTab.tabName === name
                    dataProvider: KlineChartDataProvider {
                        count: root.count
                        serviceUrl: '/indicator/calc'
                        params: ({
                                     name: 'KDJ',
                                     parameter: 'N=9,M1=3,M2=3',
                                     obj: root.obj,
                                     period: root.period,
                                     split: root.split
                                 })
                        function adapt(nextData) {
                            return nextData[0].ShuJu;
                        }
                    }
                    onClose: {
                        indicatorTab.currentIndex = -1;
                    }
                }
                RSIChart {
                    id: rsiChart
                    Layout.fillWidth: true
                    Layout.preferredHeight: canvas.chartHeightPer
                    xAxis: klineChart.xAxis
                    stock: root.stock
                    visible: indicatorTab.tabName === name
                    dataProvider: KlineChartDataProvider {
                        count: root.count
                        serviceUrl: '/indicator/calc'
                        params: ({
                                     name: 'RSI',
                                     parameter: 'N1=6,N2=12,N3=24',
                                     obj: root.obj,
                                     period: root.period,
                                     split: root.split
                                 })
                        function adapt(nextData) {
                            return nextData[0].ShuJu;
                        }
                    }
                    onClose: {
                        indicatorTab.currentIndex = -1;
                    }
                }

                Keys.onLeftPressed: {
                    root.showCrossLine('left');
                    if (root.historyMinParams) {
                        root.showHistoryMin();
                    }
                    event.accepted = true;
                }

                Keys.onRightPressed: {
                    root.showCrossLine('right');
                    if (root.historyMinParams) {
                        root.showHistoryMin();
                    }
                    event.accepted = true;
                }
            }
        }
        SeparatorLine {
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            length: parent.width
        }
        TabBar {
            id: indicatorTab
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            tabBarTabWidth: 100
            tabBarTabTextColor: '#555555'
            tabs: ['MACD', 'KDJ', 'RSI']
            initTabIndex: -1
            cancelCheckedEnable: true
            property string tabName: tabs[currentIndex] || ''
        }
    }

    Keys.onUpPressed: {
        root.count -= Math.floor(root.count / 3);
    }

    Keys.onDownPressed: {
        root.count += Math.floor(root.count / 3);
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
        var data = klineChart.cache[xAxis._mouseIndex];
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

    function pressEscape(event) {
        if (root.historyMinParams) {
            root.historyMinParams = null;
            event.accepted = true;
        } else if (crossLine) {
            hideCrossLine();
            event.accepted = true;
        }
    }
}

