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

/**
 * 买卖盘数据组件
 */
ContextComponent {
    id: root
//    readonly property int minHeightPer: 50
    property string obj

    property bool isLevel2: UserService.isLevel2

    property int showLevelCount: 10//(height / minHeightPer >= 10) ? 10 : (height / minHeightPer >= 8) ? 8 : 5

    // 内部用，控制level1只能展示基础5档行情
    property int _showLevelCount: isLevel2 ? showLevelCount : Math.min(showLevelCount, 5)

    readonly property var defaultBuys: '          '.split('').map(function(data, index) {return {price: NaN, volume: NaN, change: NaN, label: buyLabel + buySellLabelCount[index]}})
    readonly property var defaultSells: '          '.split('').map(function(data, index) {return {price: NaN, volume: NaN, change: NaN, label: sellLabel + buySellLabelCount[index]}})

    property var buys: defaultBuys
    property var sells: defaultSells

    // 昨收
    property real lastClose

    property int precision

    property int selectedIndex: -1

    property DataProvider dataProvider

    property string buyLabel: '买'
    property string sellLabel: '卖'
    property string buySellLabelCount: '一二三四五六七八九十'

    focusAvailable: false

    // 样式相关
    property color buySellLabelColor: theme.buySellLabelColor
    property int buySellLabelFontSize: theme.buySellLabelFontSize
    property int buySellLabelFontWeight: theme.buySellLabelFontWeight
    property string buySellLabelFontFamily: theme.buySellLabelFontFamily

    property color buySellPriceColor: theme.buySellPriceColor
    property color buySellPriceUpColor: theme.buySellPriceUpColor
    property color buySellPriceDownColor: theme.buySellPriceDownColor
    property int buySellPriceFontSize: theme.buySellPriceFontSize
    property int buySellPriceFontWeight: theme.buySellPriceFontWeight
    property string buySellPriceFontFamily: theme.buySellPriceFontFamily

    property color buySellVolumeColor: theme.buySellVolumeColor
    property int buySellVolumeFontSize: theme.buySellVolumeFontSize
    property int buySellVolumeFontWeight: theme.buySellVolumeFontWeight
    property string buySellVolumeFontFamily: theme.buySellVolumeFontFamily

    property color buySellChangeColor: theme.buySellChangeColor
    property color buySellChangeUpColor: theme.buySellChangeUpColor
    property color buySellChangeDownColor: theme.buySellChangeDownColor
    property int buySellChangeFontSize: theme.buySellChangeFontSize
    property int buySellChangeFontWeight: theme.buySellChangeFontWeight
    property string buySellChangeFontFamily: theme.buySellChangeFontFamily

    property int buySellComponentRowLeftMargin: theme.buySellComponentRowLeftMargin
    property int buySellComponentRowRightMargin: theme.buySellComponentRowRightMargin
    property int buySellComponentRowTopMargin: theme.buySellComponentRowTopMargin
    property int buySellComponentRowBottomMargin: theme.buySellComponentRowBottomMargin
    property int buySellComponentRowHeight: theme.buySellComponentRowHeight

    property int buySellLabelPreferredWidth: theme.buySellLabelPreferredWidth
    property int buySellPricePreferredWidth: theme.buySellPricePreferredWidth
    property int buySellVolumePreferredWidth: theme.buySellVolumePreferredWidth
    property int buySellChangePreferredWidth: theme.buySellChangePreferredWidth

    Component {
        id: defaultDataProvider
        DataProvider {
            autoQuery: true
            serviceUrl: '/stkdata'
            sub: 1
            params: ({
                obj: obj,
                field: ['ZuoShou', 'ChengJiaoLiangDanWei'].concat('     '.split('').map(function(_, i) {
                    return [
                                'WeiTuoMaiRuJia' + (i + 1),
                                'WeiTuoMaiRuLiang' + (i + 1),
                                'KuoZhanMaiRuJia' + (i + 1),
                                'KuoZhanMaiRuLiang' + (i + 1),
                                'WeiTuoMaiChuJia' + (i + 1),
                                'WeiTuoMaiChuLiang' + (i + 1),
                                'KuoZhanMaiChuJia' + (i + 1),
                                'KuoZhanMaiChuLiang' + (i + 1),
                            ];
                }))
            })
            function adapt(data) {
                return data[0]
            }
        }
    }

    Component.onCompleted: {

        // 初始化数据提供商，如果从外部传入了dataProvider则不创建
        dataProvider = dataProvider || defaultDataProvider.createObject(root);
    }

    onObjChanged: {

        // obj变化清理数据
        buys = defaultBuys;
        sells = defaultSells;
    }

    onShowLevelCountChanged: {
        selectedIndex = -1;
    }

    function formatData(value) {
        return value == null ? NaN : value;
    }

    Connections {
        target: dataProvider
        onSuccess: {
            lastClose = data.ZuoShou || 0;
            precision = dynaData.XiaoShuWei || 2;

            var unit = data.ChengJiaoLiangDanWei

            // 计算委托量变化
            var lastMap = {};
            for (var i = 0; i < 10; i++) {
                lastMap['buy' + root.buys[i].price] = root.buys[i].volume;
                lastMap['sell' + root.sells[i].price] = root.sells[i].volume;
            }

            var buys = [];
            var sells = [];
            var price;
            var volume;
            for (i = 0; i < 5; i++) {
                buys[i] = {
                    price: price = formatData(data['WeiTuoMaiRuJia' + (i + 1)]),
                    volume: volume = formatData(data['WeiTuoMaiRuLiang' + (i + 1)]) / unit,
                    change: (volume - formatData(lastMap['buy' + price])) || NaN,
                    label: buyLabel + buySellLabelCount[i]
                };
                buys[i + 5] = {
                    price: price = formatData(data['KuoZhanMaiRuJia' + (i + 1)]),
                    volume: volume = formatData(data['KuoZhanMaiRuLiang' + (i + 1)]) / unit,
                    change: (volume - formatData(lastMap['buy' + price])) || NaN,
                    label: buyLabel + buySellLabelCount[i + 5]
                };
                sells[i] = {
                    price: price = formatData(data['WeiTuoMaiChuJia' + (i + 1)]),
                    volume: volume = formatData(data['WeiTuoMaiChuLiang' + (i + 1)]) / unit,
                    change: (volume - formatData(lastMap['sell' + price])) || NaN,
                    label: sellLabel + buySellLabelCount[i]
                };
                sells[i + 5] = {
                    price: price = formatData(data['KuoZhanMaiChuJia' + (i + 1)]),
                    volume: volume = formatData(data['KuoZhanMaiChuLiang' + (i + 1)]) / unit,
                    change: (volume - formatData(lastMap['sell' + price])) || NaN,
                    label: sellLabel + buySellLabelCount[i + 5]
                };
            }
            root.buys = buys;
            root.sells = sells;
        }
    }

    height: layout.height
    ColumnLayout {
        id: layout
        width: parent.width
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        property var model: sells.slice(0, _showLevelCount).reverse().concat(buys.slice(0, _showLevelCount))
        Repeater {
            model: layout.model.length
            ColumnLayout {
                property var buySellData: layout.model[modelData]
                Layout.fillWidth: true
                Layout.fillHeight: true
                height: container.height
                spacing: 0
                Rectangle {
                    id: container
                    height: childrenRect.height
                    Layout.fillWidth: true
                    color: selectedIndex === index ? theme.rightSideBarHighLight : 'transparent'
                    ColumnLayout {
                        width: parent.width
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: buySellComponentRowLeftMargin
                            Layout.rightMargin: buySellComponentRowRightMargin
                            Layout.topMargin: buySellComponentRowTopMargin
                            Layout.bottomMargin: buySellComponentRowBottomMargin
                            Layout.preferredHeight: buySellComponentRowHeight
                            Text {
                                id: label
                                verticalAlignment: Qt.AlignVCenter
                                Layout.fillHeight: true
                                Layout.preferredWidth: buySellLabelPreferredWidth
                                text: buySellData.label
                                color: buySellLabelColor
                                font.weight: buySellLabelFontWeight
                                font.family: buySellLabelFontFamily
                                font.pixelSize: buySellLabelFontSize
                            }
                            Label {
                                id: price
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.preferredWidth: buySellPricePreferredWidth
                                horizontalAlignment: Qt.AlignRight
                                isAutoFormat: true
                                baseValue: lastClose
                                value: buySellData.price
                                normalColor: buySellPriceColor
                                upColor: buySellPriceUpColor
                                downColor: buySellPriceDownColor
                                font.weight: buySellPriceFontWeight
                                font.family: buySellPriceFontFamily
                                font.pixelSize: buySellPriceFontSize
                                precision: dynaData.XiaoShuWei || 2
                            }
                            Label {
                                id: volume
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.preferredWidth: buySellVolumePreferredWidth
                                horizontalAlignment: Qt.AlignRight
                                value: buySellData.volume
                                precision: 0
                                normalColor: buySellVolumeColor
                                font.weight: buySellVolumeFontWeight
                                font.family: buySellVolumeFontFamily
                                font.pixelSize: buySellVolumeFontSize
                            }
                            Label {
                                id: change
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.preferredWidth: buySellChangePreferredWidth
                                horizontalAlignment: Qt.AlignRight
                                isAutoFormat: true
                                precision: 0
                                defaultText: ' '
                                hasSign: true
                                baseValue: 0
                                value: buySellData.change
                                normalColor: buySellChangeColor
                                upColor: buySellChangeUpColor
                                downColor: buySellChangeDownColor
                                font.weight: buySellChangeFontWeight
                                font.family: buySellChangeFontFamily
                                font.pixelSize: buySellChangeFontSize
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedIndex = index;
                        }
                    }
                }
                SeparatorLine {
                    Layout.fillWidth: true
                    orientation: Qt.Horizontal
                    length: parent.width
                    color: '#e1e1e1'
                    visible: index === _showLevelCount - 1
                }
            }
        }
    }
}
