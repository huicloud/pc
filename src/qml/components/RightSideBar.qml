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
import QtQuick.Controls 1.4
import "../core"
import "../core/data"
import "../controls"
import "../util"
import "./stockList/detail_right"

/**
 * 右侧边栏，根据列表或者详细页面，股票或者指数板块类型展示不同
 */
ContextComponent {
    id: root

    focusAvailable: false

    property string market: ""
    property int marketType: -1

    property string obj

    property var block: BlockUtil.blockName.createObject(root)
    property var blockFullName: block.fullName

    property var stock: StockUtil.stock.createObject(root)

    // obj对象类型(1,股票  0,指数板块)
    property int type: stock.type

    // 侧边栏类型(1,列表用 2,详细页面用)
    property int sideBarType: 1

    property var dynaData: ({})

    // level2行情时才能展开收缩，level1行情直接是展开状态
    property bool dynaExpanded: UserService.isLevel2 ? false : true

    // 样式相关
    property int rightSideBarComponentMargin: theme.rightSideBarComponentMargin
    property color rightSideBarHighLight: theme.rightSideBarHighLight

    property int rightSideBarTitleLeftMargin: theme.rightSideBarTitleLeftMargin
    property int rightSideBarTitleRightMargin: theme.rightSideBarTitleRightMargin
    property int rightSideBarTitleTopMargin: theme.rightSideBarTitleTopMargin
    property int rightSideBarTitleBottomMargin: theme.rightSideBarTitleBottomMargin
    property int rightSideBarTitleRowSpacing: theme.rightSideBarTitleRowSpacing
    property int rightSideBarTitleColumnSpacing: theme.rightSideBarTitleColumnSpacing

    property color rightSideBarNameColor: theme.rightSideBarNameColor
    property int rightSideBarNameFontSize: theme.rightSideBarNameFontSize
    property int rightSideBarNameFontWeight: theme.rightSideBarNameFontWeight
    property string rightSideBarNameFontFamily: theme.rightSideBarNameFontFamily

    property color rightSideBarCodeColor: theme.rightSideBarCodeColor
    property int rightSideBarCodeFontSize: theme.rightSideBarCodeFontSize
    property int rightSideBarCodeFontWeight: theme.rightSideBarCodeFontWeight
    property string rightSideBarCodeFontFamily: theme.rightSideBarCodeFontFamily

    property color rightSideBarPriceColor: theme.rightSideBarPriceColor
    property color rightSideBarPriceUpColor: theme.rightSideBarPriceUpColor
    property color rightSideBarPriceDownColor: theme.rightSideBarPriceDownColor
    property int rightSideBarPriceFontSize: theme.rightSideBarPriceFontSize
    property int rightSideBarPriceFontWeight: theme.rightSideBarPriceFontWeight
    property string rightSideBarPriceFontFamily: theme.rightSideBarPriceFontFamily

    property color rightSideBarUpDownColor: theme.rightSideBarUpDownColor
    property color rightSideBarUpDownUpColor: theme.rightSideBarUpDownUpColor
    property color rightSideBarUpDownDownColor: theme.rightSideBarUpDownDownColor
    property int rightSideBarUpDownFontSize: theme.rightSideBarUpDownFontSize
    property int rightSideBarUpDownFontWeight: theme.rightSideBarUpDownFontWeight
    property string rightSideBarUpDownFontFamily: theme.rightSideBarUpDownFontFamily

    property color rightSideBarRatioColor: theme.rightSideBarRatioColor
    property color rightSideBarRatioUpColor: theme.rightSideBarRatioUpColor
    property color rightSideBarRatioDownColor: theme.rightSideBarRatioDownColor
    property int rightSideBarRatioFontSize: theme.rightSideBarRatioFontSize
    property int rightSideBarRatioFontWeight: theme.rightSideBarRatioFontWeight
    property string rightSideBarRatioFontFamily: theme.rightSideBarRatioFontFamily

    property color rightSideBarMarkColor: theme.rightSideBarMarkColor
    property int rightSideBarMarkFontSize: theme.rightSideBarMarkFontSize
    property int rightSideBarMarkFontWeight: theme.rightSideBarMarkFontWeight
    property string rightSideBarMarkFontFamily: theme.rightSideBarMarkFontFamily
    property int rightSideBarMarkWidth: theme.rightSideBarMarkWidth
    property int rightSideBarMarkHeight: theme.rightSideBarMarkHeight

    property color rightSideBarBorderColor: theme.rightSideBarBorderColor
    property int rightSideBarMiniChartHeight: theme.rightSideBarMiniChartHeight

    contextMenuItems: [
        createMenuItem(portfolioContextMenuItem, {obj: root.obj}),
        createMenuItem(f10ContextMenuItem, {obj: root.obj})
    ]

    property DataProvider dataProvider: BaseObjDataProvider {
        parent: root
        serviceUrl: '/stkdata'
        sub: 1
        obj: root.obj
        params: ({
            field: [
                        'ZuiXinJia', 'JunJia', 'ZhangDie', 'HuanShou', 'ZhangFu', 'KaiPanJia', 'ChengJiaoLiang',/*总手就是总成交量*/
                        'ZuiGaoJia', 'XianShou', 'ZuiDiJia', 'ChengJiaoE', 'LiangBi', 'ZhangTing', 'DieTing', 'ZhenFu',
                        'ZongChengJiaoBiShu', 'MeiBiChengJiaoGuShu', 'NeiPan', 'WaiPan', 'ZongMaiRu', 'ZongMaiRuJunJia',
                        'ZongMaiChu', 'ZongMaiChuJunJia', 'ShiYingLv', 'ShiJingLv', 'ZongShiZhi', 'LiuTongShiZhi',
                        'ChengJiaoLiangDanWei', 'ZuoShou', 'BaoGaoQi', 'XiaoShuWei', 'WeiBi'
                    ].concat('     '.split('').map(function(_, i) {
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
        onSuccess: {
            root.dynaData = data;
        }
    }

    onObjChanged: {

        // obj变化清理数据
        dynaData = {};
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: childrenRect.height
            Layout.leftMargin: rightSideBarTitleLeftMargin
            Layout.rightMargin: rightSideBarTitleRightMargin
            Layout.topMargin: rightSideBarTitleTopMargin
            Layout.bottomMargin: rightSideBarTitleBottomMargin
            spacing: rightSideBarTitleRowSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: rightSideBarTitleColumnSpacing
                Text {
                    id: stockName
                    font.pixelSize: rightSideBarNameFontSize
                    font.weight: rightSideBarNameFontWeight
                    font.family: rightSideBarNameFontFamily
                    color: rightSideBarNameColor
                    text: stock.name
                }
                Text {
                    id: stockCode
                    font.pixelSize: rightSideBarCodeFontSize
                    font.weight: rightSideBarCodeFontWeight
                    font.family: rightSideBarCodeFontFamily
                    color: rightSideBarCodeColor
                    text: stock.code
                }
                Rectangle {
                    border.width: 1
                    border.color: rightSideBarMarkColor
                    width: rightSideBarMarkWidth
                    height: rightSideBarMarkHeight
                    visible: stock.financing
                    Text {
                        id: stockFinancing
                        anchors.centerIn: parent
                        font.pixelSize: rightSideBarMarkFontSize
                        font.weight: rightSideBarMarkFontWeight
                        font.family: rightSideBarMarkFontFamily
                        color: rightSideBarMarkColor
                        text: '融'
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                ImageButton {
                    property bool isPortfolio: PortfolioUtil.inPortfolios(root.obj)
                    Layout.fillHeight: true
                    imageRes: isPortfolio ? theme.iconRemoveMyStocks : theme.iconAddMyStocks
                    imageSize: Qt.size(20, 18)
                    Indicator {
                        visible: parent.visible && parent.hovered
                        indicateText: parent.isPortfolio ? '删除自选股' : '添加自选股'
                    }
                    onClickTriggered: {

                        if (isPortfolio) {

                            // 删除自选股
                            PortfolioUtil.remove({obj: root.obj});
                        } else {

                            // 添加自选股
                            PortfolioUtil.add({obj: root.obj});
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: rightSideBarTitleColumnSpacing
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignBottom
                    isAutoFormat: true
                    hasSuffix: true
                    font.pixelSize: rightSideBarPriceFontSize
                    font.weight: rightSideBarPriceFontWeight
                    font.family: rightSideBarPriceFontFamily
                    upColor: rightSideBarPriceUpColor
                    downColor: rightSideBarPriceDownColor
                    baseValue: dynaData.ZuoShou || NaN
                    value: dynaData.ZuiXinJia || NaN
                    precision: dynaData.XiaoShuWei || 2
                }
                Label {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    Layout.bottomMargin: (rightSideBarPriceFontSize - rightSideBarUpDownFontSize) / 4
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment: Qt.AlignBottom
                    isAutoFormat: true
                    hasSign: true
                    font.pixelSize: rightSideBarUpDownFontSize
                    font.weight: rightSideBarUpDownFontWeight
                    font.family: rightSideBarUpDownFontFamily
                    upColor: rightSideBarUpDownUpColor
                    downColor: rightSideBarUpDownDownColor
                    value: dynaData.ZhangDie || 0
                    baseValue: 0
                    precision: dynaData.XiaoShuWei || 2
                }
                Label {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    Layout.bottomMargin: (rightSideBarPriceFontSize - rightSideBarUpDownFontSize) / 4
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment: Qt.AlignBottom
                    isAutoFormat: true
                    hasSign: true
                    unit: '%'
                    font.pixelSize: rightSideBarRatioFontSize
                    font.weight: rightSideBarRatioFontWeight
                    font.family: rightSideBarRatioFontFamily
                    upColor: rightSideBarRatioUpColor
                    downColor: rightSideBarRatioDownColor
                    value: dynaData.ZhangFu / 100
                    baseValue: 0
                }
            }
        }
        SeparatorLine {
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            length: parent.width
            color: rightSideBarBorderColor
        }
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: {
                if (sideBarType === 1) {
                    return listSideBar;
                } else {
                    return detailSideBar;
                }
            }
        }
    }

    Component {
        id: buySellComponent
        BuySellComponent {
            obj: root.obj
            showLevelCount: sideBarType === 1 ? 5 : (dynaExpanded ? 5 : 10)
            dataProvider: root.dataProvider
        }
    }

    Component {
        id: list
        BlockIndexStocks {
            obj: root.obj
            market: root.market
            marketType: root.marketType
            type: ['SH000001', 'SZ399001', 'SZ399006'].indexOf(root.obj) >= 0 ? 1 : 0
        }
    }

    Component {
        id: tickComponent
        ColumnLayout {
            spacing: 0
            TabView {
                id: tabView
                Layout.fillHeight: true
                Layout.fillWidth: true
                tabPosition: Qt.BottomEdge
                tabsVisible: false
                Tab {
                    title: "逐笔"
                    Rectangle {
                        ReportComponent {
                            anchors.fill: parent
                            obj: root.obj
                            lastClose: dynaData.ZuoShou || NaN
                        }
                    }
                }
                Tab {
                    title: "分笔"
                    Rectangle {
                        TickComponent {
                            anchors.fill: parent
                            obj: root.obj
                            lastClose: dynaData.ZuoShou || NaN
                        }
                    }
                }
                Tab {
                    title: "财务"
                    Rectangle {
                        FinanceComponent {
                            anchors.fill: parent
                            obj: root.obj
                        }
                    }
                }
            }
            SeparatorLine {
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                length: parent.width
                color: rightSideBarBorderColor
            }
            TabBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
//                tabBarTabWidth: 80

                // 只有Level2行情才能查看逐笔
                tabs: [UserService.isLevel2 ? '逐笔' : '', '分笔','财务']
                onChangeTab: {
                    tabView.currentIndex = index;
                }
            }
        }
    }

    Component {
        id: dyna
        DynaComponent {
            obj: root.obj
            dataProvider: root.dataProvider
        }
    }

    Component {
        id: listSideBar
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Loader {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                // 保证买卖盘和成分股列表高度一致
                Layout.preferredHeight: 211 //Qt.platform.os === 'osx' ? 221 : 204
                sourceComponent: type !== 0 ? buySellComponent : dyna
            }
            SeparatorLine {
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                length: parent.width
                color: rightSideBarBorderColor
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: rightSideBarMiniChartHeight
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: rightSideBarComponentMargin
                Layout.rightMargin: rightSideBarComponentMargin
                Layout.topMargin: rightSideBarComponentMargin / 2
                Layout.bottomMargin: rightSideBarComponentMargin / 2

                MiniChartComponent {
                    anchors.fill: parent
                    obj: root.obj
                }
            }

            SeparatorLine {
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                length: parent.width
                color: rightSideBarBorderColor
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                visible: type !== 0
                Flickable {
                    id: flicker
                    width: parent.width
                    height: parent.height
                    contentHeight: dynaComponent.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    DynaComponent {
                        id: dynaComponent
                        width: scrollbar.visible ? flicker.width - 8 : flicker.width
                        obj: root.obj
                        dataProvider: root.dataProvider
                    }
                }
                VScrollBar {
                    id: scrollbar
                    flicker: flicker
                    sliderBorder.color: "#aec1da"
                    sliderColor: "#aec1da"
                    color: "#e7e7ec"
                }
            }
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: type === 0
                sourceComponent: !!blockFullName ? list : null
            }
        }
    }

    Component {
        id: detailSideBar
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Loader {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                height: childrenRect.height
                Layout.preferredHeight: childrenRect.height
                sourceComponent: type !== 0 ? buySellComponent : null
                visible: type !== 0
            }
            SeparatorLine {
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                length: parent.width
                color: rightSideBarBorderColor
                visible: type !== 0
            }
            RectangleWithBorder {
                bottomBorder: 1
                border.color: rightSideBarBorderColor
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                Button {
                    anchors.fill: parent
                    hoveredColor: rightSideBarHighLight
                    onClickTriggered: {
                        if (UserService.isLevel2) {
                            root.dynaExpanded = !root.dynaExpanded;
                        }
                    }
                    SeparatorLine {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 1
                        orientation: Qt.Horizontal
                        length: 16
                        separatorWidth: 2
                        color: rightSideBarBorderColor
                    }
                    SeparatorLine {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        orientation: Qt.Horizontal
                        length: 16
                        separatorWidth: 2
                        color: rightSideBarBorderColor
                    }
                }
                visible: type !== 0 && UserService.isLevel2
            }

            DynaComponent {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: childrenRect.height
                obj: root.obj
                dataProvider: root.dataProvider
                mini: !dynaExpanded
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (UserService.isLevel2) {
                            root.dynaExpanded = !root.dynaExpanded;
                        }
                    }
                }
            }
            SeparatorLine {
                Layout.fillWidth: true
                orientation: Qt.Horizontal
                length: parent.width
                color: rightSideBarBorderColor
            }
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: type !== 0 ? tickComponent : list
            }
        }
    }
}
