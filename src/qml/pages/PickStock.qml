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

import QtQuick 2.6
import QtQuick.Layouts 1.3

import "../core"
import "../core/data"
import "../controls"
import "../components"
import "../util"

BasePage {
    id: root
    focus: false
    title: '选股-' +__titles[type - 1]
    objectName: 'WebEngine'
    property alias webView: webView
    property int type: 1    //外部传入 1慧搜、2选股宝
    property int currentIndex: 0
    property int hoverIndex: 0
    property var __titles: ['慧搜', '选股宝']
    property string platformType: Qt.platform.os === 'osx' ? 'windows' : 'mac'
    property var __urls: [
        'http://i.bankuang.com/platform/search_new?from=DSB&userid=' + UserService.userId + '&system=' + platformType,
        'http://zttz.yundzh.com/xgb'
    ]
    property string currentUrl: __urls[type -1]

    property real tabBarTabWidth: theme.newsNavigationButtonWidth

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
                tabs: root.__titles
                tabDelegate: RowLayout {
                    spacing: 0

                    ImageButton {
                        id: tabButton
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        checked: root.currentIndex === tabIndex
                        backgroundColor: tabbar.tabBarTabColor
                        textColor: theme.newsNavigationButtonTextColor
                        hoveredColor: theme.toolbarButtonCheckedColor
                        hoveredTextColor: theme.newsNavigationButtonTextColor
                        checkedColor: theme.toolbarButtonCheckedColor
                        checkedTextColor: theme.newsNavigationButtonTextColor
                        paddingLeft: tabbar.tabBarTabPadding
                        paddingRight: tabbar.tabBarTabPadding
                        spacing: 6
                        anchorsAlignment: Qt.AlignCenter
                        hasImage: false
                        hasText: true

                        onClickTriggered: {
                            root.currentIndex = tabIndex;
                            root.type = root.currentIndex+1;
                            root.context.pageNavigator.push(appConfig.routePathSelectStock, {"type": root.type});
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
                        visible: true;
                        length: parent.height
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        content: WebView{
            id: newsWebView
            anchors.fill: parent
            activeFocusOnPress: true
            url: currentUrl
        }
    }

    //hack处理
    Item{
        id: webView
        property bool canGoBack: false
    }

    onTypeChanged: {
        if (type === 1 && currentIndex!==0) {
            currentIndex = 0;
        } else {
            if (currentIndex !== type - 1){
                currentIndex = type -1;
            }
        }
    }

    Connections{
        target: root.context.mainWindow
        onWebViewKeyEventTrigger:{
            if (visible)
                root.context.mainWindow.pressEsc()
        }
    }
}
