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
import '../newChart'
import './'

BaseCanvas {
    id: root
//    property string obj
    property bool mini: false

//    property int volChartHeight: 100
    property int leftSpace: 80
    property int rightSpace: 80

    property int fontSize: 14

    property var stock: StockUtil.stock.createObject(root);
    property alias auction: minDataProvider.auction

    property var customButtons: Array.prototype.concat.apply([], canvas.charts.map(function(eachChart) { return eachChart.visible ? (eachChart.customButtons || []) : [] }))

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
            text: '集合竞价',
            checked: root.auction,
            triggered: function() {
                root.auction = !root.auction;
            }
        },
    ]

    chartContainer: canvas

    forceFocus: !root.mini

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!mini) {
                root.showCrossLine();
            }
        }
    }
    BaseChartContainer {
        id: canvas
        anchors.fill: parent

        TopComponent {
            id: topComponent
            Layout.fillWidth: true
            Layout.fillHeight: false
            chart: mainChart
            visible: !mini && model.length > 0
            model: Array.prototype.concat.apply([], canvas.charts.map(function(eachChart) { return eachChart.topComponentModel || [] }))
        }

        MultiplateChart {
            id: mainChart
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 100
            leftSpace: root.leftSpace
            rightSpace: root.rightSpace
            xAxis: minChart.xAxis
            tooltipComponent: minChart.tooltipComponent
            stock: root.stock
            z: 100
            property var topComponentModel: Array.prototype.concat.apply([], Array.prototype.map.call(mainChart.children, function(eachChart) { return eachChart.visible ? (eachChart.topComponentModel || []) : [] }))
            property var customButtons: Array.prototype.concat.apply([], Array.prototype.map.call(mainChart.children, function(eachChart) { return eachChart.visible ? (eachChart.customButtons || []) : [] }))
            property var close: {
                var result;
                var charts = mainChart.charts;
                for (var i = charts.length; i > 0; i--) {
                    var chart = charts[i - 1];
                    if (chart.visible && chart.close) {
                        result = chart.close;
                        break;
                    }
                }
                return result;
            }
            MinChart {
                id: minChart
                anchors.fill: parent
                stock: root.stock
                mini: root.mini
                leftSpace: root.leftSpace
                rightSpace: root.rightSpace
                fontSize: root.fontSize
                pressedForce: !root.mini
                index: ['SH000001', 'SZ399001', 'SZ399006'].indexOf(root.obj) >= 0
                xAxis: XAxis {
                    chart: minChart
                    data: {
                        return minChart.cache && minChart.cache.minTimes || [];
                    }
                }

                dataProvider: MinChartDataProvider {
                    id: minDataProvider
                    params: ({
                                 obj: root.obj
                             })
                }
            }
            MinTTChart {
                id: minTTChart
                tabTitle: '双突战法(主图)'
                tabWidth: 120
                anchors.fill: parent
                fontSize: root.fontSize
                xAxis: minChart.xAxis
                stock: root.stock
                pressedForce: !root.mini
                mainMinChart: minChart
                leftSpace: root.leftSpace
                rightSpace: root.rightSpace

                dataProvider: KlineChartDataProvider {
                    serviceUrl: '/indicator/calc'
                    count: -1
                    params: ({
                                 obj: root.obj,
                                 name: 'TT',
                                 period: 'min'
                             })
                    function adapt(nextData) {
                        return nextData[0].ShuJu;
                    }
                }
            }
        }
        MinVOLChart {
            id: minVolChart
            dataProvider: minDataProvider
            Layout.fillWidth: true
            Layout.preferredHeight: canvas.chartHeightPer
            leftSpace: root.leftSpace
            rightSpace: root.rightSpace
            fontSize: root.fontSize
            xAxis: minChart.xAxis
            stock: root.stock
            pressedForce: !root.mini
            bottomSpace: showXAxis ? (root.mini ? fontSize + 4 : 20) : 0
        }
        MinDDXChart {
            id: minDDXChart
            Layout.fillWidth: true
            Layout.preferredHeight: canvas.chartHeightPer
            leftSpace: root.leftSpace
            rightSpace: root.rightSpace
            fontSize: root.fontSize
            xAxis: minChart.xAxis
            stock: root.stock
            pressedForce: !root.mini
            mainMinChart: minChart

            dataProvider: KlineChartDataProvider {
                serviceUrl: '/indicator/calc'
                count: -1
                params: ({
                             obj: root.obj,
                             name: 'DDX',
                             period: 'min'
                         })
                function adapt(nextData) {
                    return nextData[0].ShuJu;
                }
            }

            Connections {
                target: root
                onAuctionChanged: {
                    minDDXChart.canvas.requestPaint();
                }
            }
        }

        TabBar {
            id: indicatorTabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 24
//            cancelCheckedEnable: true
            multipleCheckedEnable: true
            initTabIndex: -1
            visible: !root.mini && indicatorCharts.some(function(eachChart) { return eachChart.tabVisible })

            property var loadedCharts: []

            // 筛选指标图
            property var indicatorCharts: [minTTChart, minDDXChart]

            tabs: indicatorCharts || []

            onIndicatorChartsChanged: {
                indicatorCharts.forEach(function(eachChart) {
                    if (loadedCharts.indexOf(eachChart) < 0) {

                        // 绑定显示条件
                        eachChart.visible = Qt.binding(function() { return eachChart.tabVisible && indicatorTabBar.checkedTabs.indexOf(eachChart) >= 0 });

                        // 监听关闭事件
                        eachChart.close && eachChart.close.connect(function() {
                            indicatorTabBar.currentIndex = -1;
                            var index = indicatorTabBar.checkedTabs.indexOf(eachChart);
                            if (index >= 0) {
                                indicatorTabBar.checkedTabs.splice(index, 1);
                                indicatorTabBar.checkedTabs = [].concat(indicatorTabBar.checkedTabs);
                            }
                        });
                    }
                });
            }

            onCheckedTabsChanged: {

                // 筛选保证主图和附图中指标各自只能选中一个(分时暂时只有两个图不做考虑)
            }

//            property var selectedIndicatorChart: indicatorCharts[currentIndex]

            SeparatorLine {
                anchors.top: parent.top
                orientation: Qt.Horizontal
                length: parent.width
            }
        }
    }
}
