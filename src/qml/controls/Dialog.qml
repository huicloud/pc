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
import QtQuick.Window 2.0
import "./"
import "../core"

Window {
    id: dialog
    width: 300
    height: 200
    flags:Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    modality: Qt.WindowModal

    default property alias customItem: content.data

    property bool isSimple: false
    property var theme: ThemeManager.currentTheme
    property bool showButton: true //是否显示按钮
    property int confirmType: 2    //显示按钮数量
    property int contentMargin: 10
    property alias miniTitlebar: title.miniTitlebar
    property alias title: title.title

    signal dialogCancel()          //取消信号
    signal dialogConfirm()         //确认信号

    RectangleWithBorder{
        focus: true
        anchors.fill: parent
        leftBorder: 1
        rightBorder: 1
        topBorder: 0
        bottomBorder: 1
        border.color: theme.toolbarColor
        TitleBar{
            //标题区域
            id: title
            width: parent.width
            anchors.top: parent.top
            anchors.left: parent.left
            mainWindow: dialog
            windowButton.showMaxButton: false
            windowButton.showMinButton: false
            windowButton.width: theme.toolbarControlButtonWidth
        }

        Item{
            //自定义区域
            id: center
            anchors.top: title.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottom.top

            Item {
                id: content
                anchors.fill: parent
                anchors.margins: dialog.contentMargin
            }
        }

        Item {
            //底部按钮区域
            id: bottom
            visible: showButton
            height: showButton ? 40 : 0
            width: parent.width
            anchors.bottom: parent.bottom
            Loader {
                id: buttonsLoader
                anchors.fill: parent
                active: showButton
                focus: true
                sourceComponent: confirmType === 2 ? twoButtonComponent : oneButtonComponent

                Component {
                    id: oneButtonComponent
                    Item{
                        anchors.fill: parent
                        Button {
                            anchors.centerIn: parent
                            id: oneConfirmBtn
                            width: 60
                            height: 30
                            borderWidth: 1
                            checkedColor: 'black'
                            backgroundColor: Qt.lighter(theme.toolbarColor, 1.2)
                            textColor: theme.backgroundColor
                            hoveredTextColor: Qt.lighter(theme.backgroundColor, 1.2)
                            text: isSimple ? '是':'确定'
                            focus: true
                            onClickTriggered: {
                                dialog.dialogConfirm()
                                dialog.close();
                            }
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    oneConfirmBtn.clickTriggered();
                                }
                            }

                            Component.onCompleted: {
                                oneConfirmBtn.forceActiveFocus();
                            }
                        }
                    }
                }

                Component {
                    id: twoButtonComponent
                    Item{
                        anchors.fill: parent

                        Button {
                            id: twoConfirmBtn
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width / 2 + 10

                            width: 60
                            height: 30
                            backgroundColor: Qt.lighter(theme.toolbarColor, 1.2)
                            borderWidth: 1
                            checkedColor: 'black'
                            textColor: theme.backgroundColor
                            hoveredTextColor: Qt.lighter(theme.backgroundColor, 1.2)
                            text: isSimple ? '是':'确认'
                            onClickTriggered: {
                                dialog.close();
                                dialog.dialogConfirm();
                            }

                            KeyNavigation.tab: twoCancelBtn
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    twoConfirmBtn.clickTriggered();
                                }
                            }

                            Component.onCompleted: {
                                twoConfirmBtn.forceActiveFocus();
                            }
                        }

                        Button {
                            id: twoCancelBtn
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width / 2 + 10
                            width: 60
                            height: 30
                            backgroundColor: Qt.lighter(theme.toolbarColor, 1.2)
                            borderWidth: 1
                            checkedColor: 'black'
                            textColor: theme.backgroundColor
                            hoveredTextColor: Qt.lighter(theme.backgroundColor, 0.8)

                            text: isSimple ? '否':'取消'
                            onClickTriggered: {
                                dialog.close();
                                dialog.dialogCancel();
                            }
                            KeyNavigation.tab: twoConfirmBtn
                            Keys.onPressed: {
                                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    twoCancelBtn.clickTriggered();
                                }
                            }
                        }
                    }
                }
            }
        }

        Keys.onPressed: {
            if(event.key === Qt.Key_Escape) {
                event.accepted= true;
                dialog.close();
            }
        }
    }


    onVisibleChanged: {
        if (visible){
            if (showButton){
                buttonsLoader.active = false;
                buttonsLoader.active = true;
            }
        }
    }
    Component.onCompleted: {
        dialog.requestActivate();
    }
}
