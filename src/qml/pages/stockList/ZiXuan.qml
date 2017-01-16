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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../../core"
import "../../core/data"
import "../../controls"
import "../../components"
import "../../util"
import "../../components/dzhTable"

/*自选股列表、最近浏览*/
BasePage {

    id: root

    //外部传入 1自选股 2最近浏览
    property int type: 1

    property int currentIndex: 0
    property int hoverIndex: 0
    property real tabBarTabWidth: theme.stockTableNavigationButtonWidth

    property bool ziXuanRightSideBarVisible: true
    property bool recentReadRightSideBarVisible: true

    //1: 基本行情 2：资金分析 表头
    property int tableHeaderType: 1

    title: type===2 ? "最近浏览" : "自选股列表"

    property var zixuanReqObjs: PortfolioUtil.getList().map(function(eachData){ return eachData.obj})
    property var historyReqObjs: HistoryUtil.getList().map(function(eachData){ return eachData.obj})

    onTypeChanged: {
        if (type === 1 && currentIndex!==0) {
            currentIndex = 0;
        } else {
            if (currentIndex !== type - 1){
                currentIndex = type -1;
            }
        }

        if (root.tableHeaderType !== 1) {
            root.tableHeaderType = 1;
        }
    }

    Keys.onPressed: {
        if (UserService.isLevel2 && event.key === Qt.Key_F5){
            if (tableHeaderType === 1) {
                tableHeaderType = 2;
            } else if (tableHeaderType === 2) {
                tableHeaderType = 1;
            }
            event.accepted = true;
        }
    }

    Panel {
        id: panel
        anchors.fill: parent
        closeButtonEnable: false

        header: RowLayout {
            width: parent.width
            height: 30
            spacing: 0

            TabBar {
                id: tabbar
                tabBarBackgroundColor: theme.panelHeaderBackgroundColor
                currentIndex: root.currentIndex
                Layout.fillHeight: true
                Layout.preferredWidth: root.tabBarTabWidth * tabs.length
                tabBarTabWidth: root.tabBarTabWidth
                tabs: ['自选股', '最近浏览']
                tabDelegate: RowLayout {
                    spacing: 0

                    ImageButton {
                        id: tabButton
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        checked: root.currentIndex === tabIndex
                        backgroundColor: tabbar.tabBarTabColor
                        textColor: theme.stockTableNavigationButtonTextColor
                        hoveredColor: theme.toolbarButtonCheckedColor
                        hoveredTextColor: theme.stockTableNavigationButtonTextColor
                        checkedColor: theme.toolbarButtonCheckedColor
                        checkedTextColor: theme.stockTableNavigationButtonTextColor
                        paddingLeft: tabbar.tabBarTabPadding
                        paddingRight: tabbar.tabBarTabPadding
                        spacing: 6
                        anchorsAlignment: Qt.AlignCenter
                        imageSize: Qt.size(12, 12)
                        hasText: true
                        imageRes: {
                            if (currentIndex === 0 && tabIndex === 0) {
                                return theme.iconZiXuan;
                            } else if (currentIndex === 0 && tabIndex === 1) {
                                return theme.iconRecentReadNoActivate;
                            } else if (currentIndex === 1 && tabIndex === 0) {
                                return theme.iconZiXuanNoActivate;
                            } else if (currentIndex === 1 && tabIndex === 1) {
                                return theme.iconRecentRead;
                            }
                        }

                        onClickTriggered: {
                            root.currentIndex = tabIndex;
                            root.type = root.currentIndex+1;
                            root.context.pageNavigator.push(appConfig.routePathSelfStock, {"type":root.type});
                        }
                        onHoverTriggered: {
                            root.hoverIndex = tabIndex;
                        }
                        onHoverExitTriggered: {
                            if (root.hoverIndex === tabIndex) {
                                root.hoverIndex = -1;
                            }
                        }

                        text: tabName

                    }
                    SeparatorLine {
                        Layout.fillHeight: true
                        separatorWidth: tabbar.tabBarTabBorderWidth
                        color: tabbar.tabBarTabBorderColor
                        visible: true;//(tabButton.checked || tabButton.hovered) || (root.currentIndex === tabIndex + 1) || (root.hoverIndex === tabIndex + 1) ? true : false
                        length: parent.height
                    }
                }
            }

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
                minimumPopMenuWidth: ziJinFenXiBtn.width
                color: "transparent"
                visible: UserService.isLevel2
                menu: PopMenu {
                    id: ziJinFenXiMenu
                    checkableStyle: true
                    ExclusiveGroup { id: tabZiJin }
                    MenuItem { checkable: true; checked: tableHeaderType === 1; text: "基本行情"; onTriggered: ziJinFenXiBtn.process(1); exclusiveGroup: tabZiJin;}
                    MenuItem { checkable: true; checked: tableHeaderType === 2; text: "资金分析"; onTriggered: ziJinFenXiBtn.process(2); exclusiveGroup: tabZiJin;}
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

            PanelIconButton {
                id: closeButton
                Layout.alignment: Qt.AlignRight
                imageRes: theme.iconRightHide
                onClickTriggered: {
                    switch(root.currentIndex) {
                    case 0: root.ziXuanRightSideBarVisible = !root.ziXuanRightSideBarVisible; break;
                    case 1: root.recentReadRightSideBarVisible = !root.recentReadRightSideBarVisible; break;
                    }
                }
            }
        }

        content:

            TabView {
            anchors.fill: parent
            tabsVisible: false
            currentIndex: root.currentIndex

            Tab {
                // 切换到自选股列表时，重新请求远程自选股
                onVisibleChanged: {
                    if (visible === true) {
                        PortfolioUtil.requestRemoteList();
                    }
                }

                Loader {
                    sourceComponent: root.tableHeaderType===1 ? _head1_zixuan_Component : _head2_zixuan_Component
                }
            }

            Tab {
                Loader {
                    sourceComponent: root.tableHeaderType===1 ? _head1_history_Component : _head2_history_Component
                }
            }

        }

    }

    Component {
        id: _head1_zixuan_Component
        DZHTableV2 {
            type: 1
            requestObj: zixuanReqObjs
            showRightSideBar: root.ziXuanRightSideBarVisible
            stockTable.orderByColumn: null
            tableHeaderType: 1
            draggable: !stockTable.orderByColumn
            onStockDragSorted: {
                PortfolioUtil.move(srcObj, destObj, isFront);
            }
        }
    }

    Component {
        id: _head2_zixuan_Component
        DZHTableV2 {
            type: 1
            requestObj: zixuanReqObjs
            showRightSideBar: root.ziXuanRightSideBarVisible
            stockTable.orderByColumn: null
            tableHeaderType: 2
            draggable: !stockTable.orderByColumn
            onStockDragSorted: {
                PortfolioUtil.move(srcObj, destObj, isFront);
            }
        }
    }

    Component {
        id: _head1_history_Component
        DZHTableV2 {
            type: 2
            requestObj: historyReqObjs
            showRightSideBar: root.recentReadRightSideBarVisible
            stockTable.orderByColumn: null
            tableHeaderType: 1
        }
    }

    Component {
        id: _head2_history_Component
        DZHTableV2 {
            type: 2
            requestObj: historyReqObjs
            showRightSideBar: root.recentReadRightSideBarVisible
            stockTable.orderByColumn: null
            tableHeaderType: 2
        }
    }

    onAfterActive: {
        UBAUtil.sendUserBehavior(root.type === 1 ? UBAUtil.ziXuanGuTag : UBAUtil.zuiJinLiuLanTag)
    }

}
