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

/**
  * @brief 定制的工具栏
  * @author dongwei
  * @date   2016
  */


import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import "../core"
import "../controls"
import "./toolbar"

ContextComponent {
    id: root
    property Window mainWindow: null  //传入被控制的窗体
    property alias navigatorMenu: navigatorMenu

    property var dialog;
    Rectangle {
        id: toolBar
        width: parent.width
        height: theme.toolbarHeight
        anchors.top: parent.top
        color: theme.toolbarColor

        MouseArea {
            //鼠标拖拽标题栏 窗口移动
            id: toolBarMouseArea
            anchors.fill: toolBar
            property point previousPosition
            onPressed: previousPosition = Qt.point(mouseX, mouseY)
            onPositionChanged: {
                if (mainWindow.visibility === Window.Maximized)
                {
                    windowButtonSystem.showMaximized()
                    return
                }
                if (pressedButtons == Qt.LeftButton) {
                    var dx = mouseX - previousPosition.x
                    var dy = mouseY - previousPosition.y
                    mainWindow.x = mainWindow.x + dx
                    mainWindow.y = mainWindow.y + dy
                }
            }
            onDoubleClicked: windowButtonSystem.showMaximized()
        }

        RowLayout {
            id: toolBarLayout
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            Rectangle {
                id: backItemRect
                color: "transparent"
                height: parent.height
                width: theme.toolbarBackItemRectWidth
                Layout.fillWidth: true
                Layout.preferredWidth: theme.toolbarBackItemRectWidth
                Layout.maximumWidth: theme.toolbarBackItemRectWidth
                BackItem {
                    id: backItem
                    //navigatorMenu: navigatorMenu
                    anchors.fill: parent
                }
            }

            Rectangle {
                id: menuRect
                color: "transparent"
                height: parent.height
                Layout.preferredWidth: navigatorMenu.width
                Layout.maximumWidth: navigatorMenu.width
                Layout.fillWidth: true
                clip: true
                //导航菜单栏
                NavigatorMenu {
                    id: navigatorMenu
                }
            }

            Rectangle {
                color: "transparent"
                height: parent.height
                Layout.fillWidth: true
                Layout.minimumWidth: logo.width

                Image {
                    id: logo
                    anchors.centerIn: parent
                    height: theme.toolbarLogoHeight
                    width: theme.toolbarLogoWidth
                    source: theme.logoPath
                }
            }
            Rectangle {
                //用于使logo居中的hack
                color: theme.toolbarColor
                height: parent.height
                Layout.fillWidth: true
                Layout.minimumWidth: 30
                Layout.maximumWidth: {
                     var diffWidth = backItemRect.width + menuRect.width - profileRect.width - controlRect.width
                     return diffWidth <= 120 ? 120: diffWidth
                }
            }
            Rectangle {
                id: profileRect
                height: parent.height
                Layout.minimumWidth: theme.toolbarMenuButtonWidth * 2
                Layout.maximumWidth: theme.toolbarMenuButtonWidth * 2
                color: "transparent"
                Row {
                    layoutDirection: Qt.RightToLeft
                    anchors.fill: parent
//                    Button {
//                        id: aboutButton
//                        width: theme.toolbarMenuButtonWidth
//                        height: parent.height
//                        text: "关于"
//                        textColor: theme.toolbarButtonTextColor
//                        hoveredColor: theme.toolbarButtonHoverColor
//                    }
//                    Button {
//                        id: peopleCenterButton
//                        width: theme.toolbarMenuButtonWidth
//                        height: parent.height
//                        text: "我的"
//                        textColor: theme.toolbarButtonTextColor
//                        hoveredColor: theme.toolbarButtonHoverColor
//                    }
                    MenuButton{
                        id: peopleCenterButton
                        width: theme.toolbarMenuButtonWidth
                        height: parent.height
                        text: "我的"
                        color: "transparent"
                        textColor: theme.toolbarButtonTextColor
                        hoverEnabled: true
                        hoveredColor: theme.toolbarButtonHoverColor
                        minimumPopMenuWidth: 100
                        menu: PopMenu{
                           MenuItem{text: '委托设置'; onTriggered: {
                                   tradeControl.doTrade(true);
                               }
                           }
                           MenuItem{text: '关于'; onTriggered: {
                                   var component = Qt.createComponent('/dzh/pages/About.qml')
                                   if (component.status == Component.Ready){
                                       if (!dialog){
                                           dialog = component.createObject(mainWindow);
                                           dialog.show()

                                           dialog.closing.connect(function() {
                                               dialog.destroy();
                                               dialog = null;
                                           });
                                       }
                                   }
                               }
                           }
                        }
                        TradeControl{
                            id: tradeControl
                //            onResetTrade: {
                //                //调整到交易界面
                //                applicationContent.context.pageNavigator.push(appConfig.routePathTrade)
                //            }
                        }
                    }
                    Button {
                        id: feedbackButton
                        width: theme.toolbarMenuButtonWidth
                        height: parent.height
                        text: "反馈"
                        textColor: theme.toolbarButtonTextColor
                        hoveredColor: theme.toolbarButtonHoverColor
                    }
//                    Button {
//                        id: messageButton
//                        width: theme.toolbarMenuButtonWidth
//                        height: parent.height
//                        text: "消息"
//                        redDotSpacing: 1
//                        hasRedDot: true
//                        textColor: theme.toolbarButtonTextColor
//                        hoveredColor: theme.toolbarButtonHoverColor
//                    }
                }
            }

            Rectangle {
                id: controlRect
                height: parent.height
                Layout.maximumWidth: windowButtonSystem.width
                Layout.minimumWidth: windowButtonSystem.width
                color: "transparent"
                WindowControlBox {
                    id: windowButtonSystem
                    controlWindow: mainWindow
                }
            }
        }

        onWidthChanged: {
            if (width < 480){
                profileRect.visible = false
                menuRect.visible = false
                backItemRect.visible = false
            }else{
                profileRect.visible = true
                menuRect.visible = true
                backItemRect.visible = true
            }
        }
    }

//    Connections {
//        target: peopleCenterButton
//        onClickTriggered: {
//           root.context.pageNavigator.push(appConfig.routePathProfile)
//        }
//    }

//    Connections {
//        target: messageButton
//        onClickTriggered: {
//           onClickTriggered: messageButton.hasRedDot = false
//           root.context.pageNavigator.push(appConfig.routePathMessage)
//        }
//    }

    Connections {
        target: feedbackButton
        onClickTriggered: {
           root.context.pageNavigator.push(appConfig.routePathFeedback)
        }
    }

    function navigatorBack(){
        backItem.back()
    }

    function showMaximized(){
        windowButtonSystem.showMaximized()
    }
}
