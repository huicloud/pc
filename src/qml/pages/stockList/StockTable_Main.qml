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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQml 2.2

import "../../util"
import "../../core"
import "../../core/data"
import "../../controls/"
import "../../components"
import "../../components/blockList/main"
import "../../components/dzhTable"

/*沪深股、板块、指数列表*/
BasePage {
    id: root;
    title: "沪深A股"
    property string market: ""

    property Loader currentTableLoader: null;

    property bool rightSideBarVisible: true

    //1：沪深 2：板块 3：上证 4：深证 5:基金 6:常用指数
    property int type: 0;

    //1: 基本行情 2：资金分析 3: 基金 4:常用指数
    property int tableHeaderType: 1

    //是否由键盘宝进入
    property bool isSprite: false

    onMarketChanged: {

        root.type = appConfig.marketTypeMap[market];

        _head1_stkTableViewLoader.visible = false;
        _head2_stkTableViewLoader.visible = false;
        _head3_stkTableViewLoader.visible = false;
        _head4_stkTableViewLoader.visible = false;
        _31_stkTableViewLoader.visible = false;

        if (root.type === 1) {
            if (root.tableHeaderType === 3) {
                root.tableHeaderType = 1;
            }
            currentTableLoader = root.tableHeaderType === 2 ? _head2_stkTableViewLoader : _head1_stkTableViewLoader;
        } else if (root.type === 2) {
            currentTableLoader = _31_stkTableViewLoader;
        } else if (root.type === 3 || root.type === 4) {
            root.tableHeaderType = 1;
            currentTableLoader = _head1_stkTableViewLoader;
        } else if (root.type === 5) {
            root.tableHeaderType = 3;
            currentTableLoader = _head3_stkTableViewLoader;
        } else if (root.type === 6) {
            //常用指数
            root.tableHeaderType = 4;
            currentTableLoader = _head4_stkTableViewLoader;
        }
        currentTableLoader.focus = true;
        currentTableLoader.visible = true;

    }

    onTableHeaderTypeChanged: {
        if (root.type === 1) {

            _head1_stkTableViewLoader.visible = false;
            _head2_stkTableViewLoader.visible = false;
            _head3_stkTableViewLoader.visible = false;
            _31_stkTableViewLoader.visible = false;

            if (root.tableHeaderType === 1) {
                currentTableLoader = _head1_stkTableViewLoader;
            } else if (root.tableHeaderType === 2) {
                currentTableLoader = _head2_stkTableViewLoader;
            } else if (root.tableHeaderType === 3) {
                currentTableLoader = _head3_stkTableViewLoader;
            }

            currentTableLoader.focus = true;
            currentTableLoader.visible = true;
        }
    }

    Keys.onPressed: {
        if (UserService.isLevel2 && event.key === Qt.Key_F5){
//        if (event.key === Qt.Key_F5){
            if (type === 1) {
                if (tableHeaderType === 1) {
                    tableHeaderType = 2;
                } else if (tableHeaderType === 2) {
                    tableHeaderType = 1;
                }
            }
            event.accepted = true;
        }
    }

    Rectangle {
        id: navigation
        height: theme.stockTableNavigationHeight
        width: parent.width
        anchors.top: parent.top
        color: theme.stockTableNavigationBackGroundColor
        RowLayout {
            anchors.fill: parent
            height: 30
            spacing: 0
            MenuButton{
                id: marketBtn
                Layout.fillHeight: true
                Layout.preferredWidth: theme.stockTableNavigationButtonWidth
                hoverEnabled: true
                text: (menuMarkets.indexOf(root.market) > -1) ? appConfig.marketNameMap[root.market] : appConfig.marketNameMap[lastCheckedMarket]
                minimumPopMenuWidth: marketBtn.width-2
                isTextClickedDropDownEnable: false
                textColor: theme.stockTableNavigationButtonTextColor
                textHorizontalAlignment:Qt.AlignHCenter
                checkedColor: theme.toolbarButtonCheckedColor
                hoveredColor: theme.toolbarButtonCheckedColor
                backgroundColor: theme.stockTableNavigationBackGroundColor
                checked: root.type === 1

                property var menuMarkets: appConfig.marketListMap.hsStock
                property string lastCheckedMarket: '60'

                menu: PopMenu {
                    id: listMenu
                    checkableStyle: true
                    textLeftMarigin: 8
                    Instantiator {
                        model: marketBtn.menuMarkets
                        onObjectAdded: listMenu.insertItem( index, object )
                        delegate: MenuItem {
                            checkable: true;
                            checked: root.market === modelData;
                            text: appConfig.marketNameMap[modelData];
                            onTriggered: marketBtn.process(modelData);
                        }
                    }
                }

                SeparatorLine {
                    Layout.fillHeight: true
                    separatorWidth: theme.tabBarTabBorderWidth
                    color: theme.tabBarTabBorderColor
                    visible: true
                    length: parent.height
                    anchors.right:marketBtn.right
                }
                onClicked: {
                    process(lastCheckedMarket);
                }

                function process(m) {
                    marketBtn.lastCheckedMarket = m;
                    root.title = appConfig.marketNameMap[m];
                    root.context.pageNavigator.push(appConfig.routePathMarketList, {"market":m, "isSprite":"false"});
                }
            }

            Component {
                id: panelButton
                ImageButton {
                    id: imageButton
                    property string market: modelData
                    property var marketTab: {'31':2, 'SHINX':3, 'SZINX':4, 'CYINX':6}
                    Layout.preferredWidth: theme.stockTableNavigationButtonWidth
    //                anchors.left: marketBtn.right
                    Layout.fillHeight: true
                    text: appConfig.marketNameMap[imageButton.market]
                    spacing: 6
                    imageSize: Qt.size(12, 12)
                    hasText: true
                    hasImage: false

                    textColor: theme.stockTableNavigationButtonTextColor
                    hoveredColor: theme.toolbarButtonCheckedColor
                    checkedColor: theme.toolbarButtonCheckedColor
                    backgroundColor: theme.stockTableNavigationBackGroundColor;

                    checked: imageButton.market === root.market

                    onClickTriggered: {
                        root.title = text;
                        root.context.pageNavigator.push(appConfig.routePathMarketList, {"market":imageButton.market, "isSprite":"false"});
                    }

                    SeparatorLine {
                        anchors.right: parent.right
                        separatorWidth: theme.tabBarTabBorderWidth
                        color: theme.tabBarTabBorderColor
                        visible: true
                        length: parent.height
                    }
                }
            }

            Repeater {
                model: ['31','CYINX','SHINX', 'SZINX']
                delegate: panelButton
            }

            //fund start
            MenuButton{
                id: fundMenuBtn
                Layout.fillHeight: true
                Layout.preferredWidth: theme.stockTableNavigationButtonWidth
                hoverEnabled: true
                text: appConfig.marketNameMap[fundLastCheckedMarket]
                minimumPopMenuWidth: fundMenuBtn.width-2
                isTextClickedDropDownEnable: false
                textColor: theme.stockTableNavigationButtonTextColor
                textHorizontalAlignment:Qt.AlignHCenter
                checkedColor: theme.toolbarButtonCheckedColor
                hoveredColor: theme.toolbarButtonCheckedColor
                backgroundColor: theme.stockTableNavigationBackGroundColor
                checked: root.type === 5

                property var menuMarkets: appConfig.marketListMap.fund
                property string fundLastCheckedMarket: 'ETFFund'

                menu: PopMenu {
                    id: fundListMenu
                    checkableStyle: true
                    textLeftMarigin: 8
                    Instantiator {
                        model: fundMenuBtn.menuMarkets
                        onObjectAdded: fundListMenu.insertItem( index, object )
                        delegate: MenuItem {
                            checkable: true;
                            checked: root.market === modelData;
                            text: appConfig.marketNameMap[modelData];
                            onTriggered: fundMenuBtn.process(modelData);
                        }
                    }
                }

                SeparatorLine {
                    Layout.fillHeight: true
                    separatorWidth: theme.tabBarTabBorderWidth
                    color: theme.tabBarTabBorderColor
                    visible: true
                    length: parent.height
                    anchors.right:fundMenuBtn.right
                }
                onClicked: {
                    process(fundLastCheckedMarket);
                }

                function process(m) {
                    fundMenuBtn.fundLastCheckedMarket = m;
                    root.title = appConfig.marketNameMap[m];
                    root.context.pageNavigator.push(appConfig.routePathMarketList, {"market":m, "isSprite":"false"});
                }
            }
            //fund end

            Item {
                Layout.fillWidth: true
            }

            //基本行情、资金分析切换表头
            MenuButton{
                id: ziJinFenXiBtn
                Layout.fillHeight: true
                Layout.preferredWidth: 90
                Layout.alignment: Qt.AlignRight
                hoverEnabled: true
                hoveredColor: theme.toolbarButtonCheckedColor
                textColor: theme.stockTableNavigationButtonTextColor
                text: tableHeaderType === 2 ? "资金分析" : "基本行情"
                visible:  UserService.isLevel2 && type === 1
//                visible: type === 1
                minimumPopMenuWidth: ziJinFenXiBtn.width
                color: "transparent"

                menu: PopMenu {
                    id: ziJinFenXiMenu
                    checkableStyle: true
                    ExclusiveGroup { id: tabZiJin }
                    MenuItem {checkable: true; checked: tableHeaderType === 1; text: "基本行情"; onTriggered: ziJinFenXiBtn.process(1);exclusiveGroup: tabZiJin;}
                    MenuItem {checkable: true; checked: tableHeaderType === 2; text: "资金分析"; onTriggered: ziJinFenXiBtn.process(2);exclusiveGroup: tabZiJin;}
                }

                function process(type) {
                    root.tableHeaderType = type;
                }

                SeparatorLine {
                    anchors.left: parent.left
                    length: parent.height
                    color: ziJinFenXiBtn.hovered ? theme.borderColor : 'transparent'
                }

                SeparatorLine {
                    anchors.left: parent.right
                    length: parent.height
                    color: ziJinFenXiBtn.hovered ? theme.borderColor : 'transparent'
                }
            }

            //隐藏右边详情
            PanelIconButton {
                id: closeButton
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight
                imageRes: theme.iconRightHide

                onClickTriggered: {
                    rightSideBarVisible = !rightSideBarVisible;
                }
            }
        }

        SeparatorLine {
            anchors.bottom: navigation.bottom
            orientation: Qt.Horizontal
            length: navigation.width
            color: theme.rightSideBarBorderColor
        }
    }

    RowLayout {
        id: layout
        spacing: 0
        Layout.alignment: Qt.AlignCenter
        anchors.top: navigation.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        Loader {
            id: _head1_stkTableViewLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: false
            sourceComponent: _head1_Component
        }

        Loader {
            id: _head2_stkTableViewLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: false
            sourceComponent: _head2_Component
        }

        Loader {
            id: _head3_stkTableViewLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: false
            sourceComponent: _head3_Component
        }

        //常用指数
        Loader {
            id: _head4_stkTableViewLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: false
            sourceComponent: _head4_Component
        }

        Loader {
            id: _31_stkTableViewLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: false
            sourceComponent: _31_Component
        }
    }

    Component {
        id: _head1_Component
        DZHTableV2 {
            type: 0
            tableHeaderType: 1
            market: root.market
            showRightSideBar: rightSideBarVisible
        }
    }

    Component {
        id: _head2_Component
        DZHTableV2 {
            type: 0
            tableHeaderType: 2
            market: root.market
            showRightSideBar: rightSideBarVisible
        }
    }

    Component {
        id: _head3_Component
        DZHTableV2 {
            type: 0
            tableHeaderType: 3
            market: root.market
            showRightSideBar: rightSideBarVisible
        }
    }

    //常用指数
    Component {
        id: _head4_Component
        DZHTableV2 {
            type: 7
            requestObj: appConfig.requestObjsCyinx
            tableHeaderType: 4
            market: root.market
            showRightSideBar: rightSideBarVisible
        }
    }

    Component {
        id: _31_Component
        DZHTableV2 {
            type: 0
            tableHeaderType: 1
            market: "31"
            showRightSideBar: rightSideBarVisible
        }
    }

    onVisibleChanged: {
        if (isSprite) {
            currentTableLoader.item.stockTable.reset();
        }
    }

    onAfterActive:{
        if (root.market && root.market.length>0) {
            var tag = 0;

            if (root.type === 1) {
                tag = UBAUtil.huShenAGuTag;
            } else if (root.type === 2) {
                tag = UBAUtil.reMenBanKuaiTag;
            } else if (root.type === 3) {
                tag = UBAUtil.shangZhengZhiShuTag;
            } else if (root.type === 4) {
                tag = UBAUtil.shenZhengZhiShuTag;
            }

            if (tag) UBAUtil.sendUserBehavior(tag);

        }
    }

}
