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
import QtQuick.Layouts 1.1
import './'

Panel {
    id: root
    property list<Item> tabs
    default property alias _tabs: root.tabs
    property int currentIndex: 0

    property color tabPanelTabColor: theme.tabPanelTabColor
    property color tabPanelTabTextColor: theme.tabPanelTabTextColor
    property color tabPanelTabHoveredColor: theme.tabPanelTabHoveredColor
    property color tabPanelTabHoveredTextColor: theme.tabPanelTabHoveredTextColor
    property color tabPanelTabCheckedColor: theme.tabPanelTabCheckedColor
    property color tabPanelTabCheckedTextColor: theme.tabPanelTabCheckedTextColor
    property color tabPanelTabBorderColor: theme.tabPanelTabBorderColor
    property real tabPanelTabWidth: 80

    header: TabBar {
        tabBarBackgroundColor: 'transparent'
        tabBarTabColor: tabPanelTabColor
        tabBarTabTextColor: tabPanelTabTextColor
        tabBarTabHoveredColor: tabPanelTabHoveredColor
        tabBarTabHoveredTextColor: tabPanelTabHoveredTextColor
        tabBarTabCheckedColor: tabPanelTabCheckedColor
        tabBarTabCheckedTextColor: tabPanelTabCheckedTextColor
        tabBarTabBorderColor: tabPanelTabBorderColor
        tabBarTabWidth: tabPanelTabWidth

        tabs: Array.prototype.map.call(root.tabs, function(eachTab) {
            return eachTab.title
        })
        onChangeTab: {
            root.currentIndex = index;

            if (_clicked) {

                // 点击tab时，显示内容区
                root.showContent = true;
            }
        }
    }

    content: TabView {
        id: tabView
        currentIndex: root.currentIndex
        tabsVisible: false
        data: root.tabs
    }
}
