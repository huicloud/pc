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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import "../core"
import "../core/data"
import "../controls"
import "../util"

/**
 * 买卖队列组件
 */
ContextComponent {
    id: root

    property string obj

    property var stock: StockUtil.stock.createObject(root)

    // 委托买卖队列数据
//    property var buyQueue
//    property var sellQueue

    property var queueData: []

    // 昨收
    property real lastClose: stock.lastClose
    property real unit: stock.volumeUnit

    property string buyLabel: '买'
    property string sellLabel: '卖'
    property string buySellLabelCount: '一二三四五六七八九十'

    property real rowHeight: height / 5

    property real queueColumnWidth: 60

    // 买卖队列对应的数据提供者
    property DataProvider buySellQueueDataProvider: BaseObjDataProvider {
        parent: root
        serviceUrl: '/quote/queue'
        obj: root.obj
        sub: 1
        function adapt(nextData) {
            return (nextData && nextData[0] && nextData[0].Data);
        }
    }

    Connections {
        target: buySellQueueDataProvider
        onSuccess: {
            if (data && data.length > 0) {
                updateQueueData(data[0]);
//                buyQueue = data[0].MaiRuDuiLie;
//                sellQueue = data[0].MaiChuDuiLie;
            }
        }
    }

    function updateQueueData(data) {
        var input = [data.MaiChuDuiLie, data.MaiRuDuiLie];

        root.queueData = input.map(function(eachData, index) {

            // 买卖队列数据
            var queueData = eachData || [];

            // 是买入（决定查找买卖盘数据时是向上找，还是向下找）
            var isBuy = index === 1 || false;

            var result = [];
            queueData.forEach(function(eachQueueData, index) {
                if (eachQueueData) {
                    result.push({
                                    label: (isBuy ? buyLabel : sellLabel) + buySellLabelCount[index],
                                    price: eachQueueData.Jia,
                                    volume: eachQueueData.ZongLiang,
                                    queue: eachQueueData.Liang,
                                    tick: eachQueueData.BiShu,
                                    isBuy: isBuy
                                });
                }
            });

            // 现在只显示10档
            return result.slice(0, 10);
        });
    }

    onObjChanged: {

//        // obj变化清理数据
//        buyQueue = null;
//        sellQueue = null;
        queueData = [];
    }

    Rectangle {
        anchors.fill: parent
        Flickable {
            id: flicker
            anchors.fill: parent
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: layout.implicitHeight

            RowLayout {
                id: layout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: scrollbar.visible ? 8 : 0
                spacing: 0
                Repeater {
                    model: root.queueData.length
//                    model: [[{
//                            queueData: sellQueue
//                        }, {
//                            queueData: buyQueue,
//                            isBuy: true
//                        }]]
                    delegate: queueList
                }
                SeparatorLine {
                    anchors.centerIn: parent
                    Layout.fillHeight: true
                    length: parent.height
                }
            }
        }

        VScrollBar {
            id: scrollbar
            flicker: flicker
        }
    }

    Component {
        id: rowComponent
        ColumnLayout {
            spacing: 0
            property string queueString: JSON.stringify(rowData.queue)
            property bool isUpdate: false
            Timer {
                id: timer
//                running: true
                interval: 1000
                onTriggered: {
                    isUpdate = false;
                }
            }

            onQueueStringChanged: {

                // 买卖队列变化了设置update为true，再执行定时器
                isUpdate = true;
                timer.start();
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: rowHeight
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                spacing: 0
                Text {
//                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 30
                    Layout.alignment: Qt.AlignLeft
                    text: rowData.label
                }
                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                    isAutoFormat: true
                    value: rowData.price
                    baseValue: lastClose

                    precision: stock.precision || 2
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                    color: '#3e6ac5'
                    text: Math.floor(rowData.volume / root.unit)
                }
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                    text: rowData.tick ? rowData.tick + '笔' : ''
                }
                RowLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 60
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignRight
                        color: '#3e6ac5'
                        text: rowData.tick ? (rowData.volume / root.unit / rowData.tick).toFixed(1) : ''
                    }
                    Text {
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignRight
                        visible: !!rowData.tick
                        text: '手/笔'
                    }
                }
            }

            property int showCountPerRow: Math.floor(width / queueColumnWidth) || 1
            property int rowCount: rowData.queue ? Math.floor((rowData.queue.length + showCountPerRow - 1) / showCountPerRow) : 0
            SeparatorLine {
                orientation: Qt.Horizontal
                Layout.fillWidth: true
                width: parent.width
                visible: rowCount !== 0
            }

            GridLayout {
                id: queueGridLayout
                columns: showCountPerRow
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                columnSpacing: 0
                rowSpacing: 1

                property var queue: rowData.queue || []
                property var fillWidth: rowData.queue.length >= showCountPerRow ? true : false
                property color textColor: rowData.isBuy ? '#ee2c2c' : '#1ca049'
                Repeater {
                    model: parent.queue.length
                    Rectangle {
                        property real volume: parent.queue[modelData] / root.unit
                        Layout.fillWidth: parent.fillWidth
//                        Layout.fillHeight: true
                        Layout.preferredWidth: queueColumnWidth
                        Layout.preferredHeight: rowHeight
                        color: isUpdate ? '#80e8e4': volume > 5000 ? '#eab3ff' : volume > 1000 ? '#ffdc85'  : 'transparent'
                        Text {
                            anchors.fill: parent
                            anchors.rightMargin: 5
                            horizontalAlignment: Text.AlignRight

                            // 买卖队列上的成交量显示规则，四舍五入大于0时显示整数，等于0时显示两位小数
                            text: volume >= 0.5 ? Math.round(volume) : volume.toFixed(2)
                            color: queueGridLayout.textColor
                        }
                    }
                }
            }

            SeparatorLine {
                orientation: Qt.Horizontal
                Layout.fillWidth: true
                width: parent.width
            }
        }
    }

    Component {
        id: queueList
        ColumnLayout {

            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignTop

            // 避免没有数据时不会重新计算高度
            implicitHeight: 1
            spacing: 0

            property var queueData: root.queueData[modelData] || []

            Repeater {
                id: repeater
                model: queueData.length
                Loader {
                    property var rowData: queueData[modelData]
                    property int rowIndex: index
                    Layout.fillWidth: true
                    sourceComponent: rowComponent
                }
            }
        }
    }
}
