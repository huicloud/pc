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

import '../core'

/**
 * TabBar组件
 */
BaseComponent {
    id: root

    property var tabs: []

    // 初始状态选中的tab序号
    property int initTabIndex: 0
    property int currentIndex: root.initTabIndex
    property int hoverIndex: -1

    // 是否支持取消选中（再次点击选中的tab时变成不选中，currentIndex变成-1）
    property bool cancelCheckedEnable: multipleCheckedEnable

    // 是否支持多个选中（currentIndex不再有效，使用checkedTabs）
    property bool multipleCheckedEnable: false

    property var checkedTabs: []

    signal changeTab(int index, var tab)
    signal clickTab(int index, var tab)

    property bool _clicked: false

    property color tabBarBackgroundColor: theme.tabBarBackgroundColor
    property color tabBarTabColor: theme.tabBarTabColor
    property color tabBarTabTextColor: theme.tabBarTabTextColor
    property color tabBarTabHoveredColor: theme.tabBarTabHoveredColor
    property color tabBarTabHoveredTextColor: theme.tabBarTabHoveredTextColor
    property color tabBarTabCheckedColor: theme.tabBarTabCheckedColor
    property color tabBarTabCheckedTextColor: theme.tabBarTabCheckedTextColor
    property color tabBarTabBorderColor: theme.tabBarTabBorderColor
    property real tabBarTabBorderWidth: theme.tabBarTabBorderWidth
    property real tabBarTabWidth: theme.tabBarTabWidth
    property real tabBarTabPadding: theme.tabBarTabPadding

    focusAvailable: false

    // 当tabs改变时修改选中第一个
    onTabsChanged: {

        // 指定了初始tab，则选中指定tab，否则选中第一个显示的tab
        if (initTabIndex !== 0) {
            currentIndex = initTabIndex;
        } else {
            var selectedIndex = 0;
            tabs.some(function(tab, index) {
               if (tab !== '') {
                   selectedIndex = index;
                   return true;
               }
            });
            currentIndex = -1;
            currentIndex = selectedIndex;
        }
    }

    // 当前选中项变化是触发切换信号
    onCurrentIndexChanged: {
        root.changeTab(currentIndex, tabs[currentIndex]);
    }

    property Component tabDelegate: RowLayout {
        spacing: 0
        Button {
            id: tabButton
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            checked: root.multipleCheckedEnable ? root.checkedTabs.indexOf(tab) >= 0 : root.currentIndex === tabIndex
            backgroundColor: tabBarTabColor
            textColor: tabBarTabTextColor
            hoveredColor: tabBarTabHoveredColor
            hoveredTextColor: tabBarTabHoveredTextColor
            checkedColor: tabBarTabCheckedColor
            checkedTextColor: tabBarTabCheckedTextColor
            paddingLeft: tabBarTabPadding
            paddingRight: tabBarTabPadding
            onClickTriggered: {
                _clicked = true;
                var index;
                var clickTab = _tab;
                var clickTabIndex = tabIndex;
                if (root.cancelCheckedEnable && (index = root.checkedTabs.indexOf(clickTab)) >= 0) {
                    root.currentIndex = -1;
                    root.checkedTabs.splice(index, 1);
                    root.checkedTabs = [].concat(root.checkedTabs);
                } else if (root.multipleCheckedEnable) {
                    root.currentIndex = clickTabIndex;
                    root.checkedTabs = root.checkedTabs.filter(function(eachTab) {
                        return eachTab !== clickTab;
                    }).concat([clickTab]);
                } else {
                    root.currentIndex = clickTabIndex;
                    root.checkedTabs = [clickTab];
                }
                root.clickTab(clickTabIndex, clickTab);

                _clicked = false;
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
            separatorWidth: tabBarTabBorderWidth
            color: tabBarTabBorderColor
            visible: (tabButton.checked || tabButton.hovered) || (root.currentIndex === tabIndex + 1) || (root.hoverIndex === tabIndex + 1) ? true : false
            length: parent.height
        }
    }

    Rectangle {
        color: tabBarBackgroundColor
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 0
            Repeater {
                model: root.tabs.length
                Loader {
                    property var _tab: root.tabs[modelData]
                    property var tab: typeof _tab === 'object' ? _tab : ({
                                                                             tabTitle: _tab,
                                                                             tabVisible: _tab !== '',
                                                                             tabWidth: tabBarTabWidth
                                                                         })
                    property var tabName: tab.tabTitle
                    property int tabIndex: index

                    Layout.fillHeight: true
                    Layout.fillWidth: false
                    Layout.preferredWidth: tab.tabWidth
                    Layout.alignment: Qt.AlignLeft
                    sourceComponent: tabDelegate
                    visible: tab.tabVisible
                }
            }

            // 拉伸剩下空间
            Item {
                Layout.fillWidth: true
            }
        }
    }
}
