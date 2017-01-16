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
  * @brief  WindowControlBox
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4

import "../core"
import "../components"

BaseComponent {
    id: root
    height: theme.toolbarHeight
    width: theme.toolbarControlButtonWidth * 3
    property bool miniTitlebar: false
    property bool showMinButton: true //是否显示最小化按钮
    property bool showMaxButton: true //是否显示最大化按钮
    property Window controlWindow: null //传入可被控制的Window,如果未传入，则会激活信号

    signal windowMin
    signal windowMax
    signal windowClose

    Row {
        id: windowController
        anchors.fill: parent
        layoutDirection: Qt.RightToLeft //从右往左排布

        //关闭按钮
        IconButton {
            id: closeButton
            width: miniTitlebar ? theme.toolbarMiniHeight : theme.toolbarControlButtonWidth
            height: miniTitlebar ? theme.toolbarMiniHeight : theme.toolbarControlButtonHeight
            iconRes: miniTitlebar ? theme.iconMiniClose : theme.iconClose
            backgroundColor: theme.toolbarColor
            iconSize: miniTitlebar ?  Qt.size(theme.toolbarMiniHeight, theme.toolbarMiniHeight) : Qt.size(theme.toolbarHeight, theme.toolbarHeight)
        }

        //最大化按钮
        IconButton {
            id: maxButton
            width: theme.toolbarControlButtonWidth
            height: theme.toolbarControlButtonHeight
            visible: showMaxButton
            iconRes: {
                if (controlWindow) {
                    return (controlWindow.visibility == Window.Windowed) ? theme.iconMaximize : theme.iconRestore
                } else {
                    return theme.iconMaximize
                }
            }
            backgroundColor: theme.toolbarColor
            iconSize: Qt.size(theme.toolbarHeight, theme.toolbarHeight)
        }

        //最小化按钮
        IconButton {
            id: minButton
            width: theme.toolbarControlButtonWidth
            height: theme.toolbarControlButtonHeight
            visible: showMinButton
            iconRes: theme.iconMinimize
            backgroundColor: theme.toolbarColor
            iconSize: Qt.size(theme.toolbarHeight, theme.toolbarHeight)
        }

        /*
            如果没有传入被控制的window，则触发信号，外部可处理对应的逻辑
        */
        Connections {
            target: closeButton
            onClickTriggered: {
                if (controlWindow) {
                    if (typeof controlWindow.closeQuery === 'function'){
                        if (controlWindow.closeQuery()){
                            controlWindow.close();
                        }
                    }else{
                        controlWindow.close();
                    }
                }else{
                    root.windowClose() //触发窗体关闭信号
                }
            }
        }

        Connections {
            target: minButton
            onClickTriggered: {
                if (controlWindow) {
                    controlWindow.showMinimized()
                } else {
                    root.windowMin() //触发窗体最小化信号
                }
            }
        }

        Connections {
            target: maxButton
            onClickTriggered: {
                showMaximized()
            }
        }
    }

    function showMaximized() {
        if (controlWindow) {
            if (controlWindow.visibility === Window.Maximized){
                controlWindow.showNormal()
                //maxButton.iconRes = theme.iconMaximize
            }else if (controlWindow.visibility === Window.Windowed){
                controlWindow.showMaximized()
                //maxButton.iconRes = theme.iconRestore
            }else{
                controlWindow.showNormal()
                //maxButton.iconRes = theme.iconMaximize
            }

            //            switch (controlWindow.showState) {
            //            case controlWindow.showAppMaximized:
            //                controlWindow.showState = controlWindow.showAppRestore
            //                controlWindow.showNormal()
            //                maxButton.iconRes = theme.iconMaximize
            //                break
            //            case controlWindow.showAppRestore:
            //                controlWindow.showState = controlWindow.showAppMaximized
            //                controlWindow.showMaximized()
            //                maxButton.iconRes = theme.iconRestore
            //                break
            //            default:
            //                controlWindow.showState = controlWindow.showAppRestore
            //                controlWindow.showNormal()
            //                maxButton.iconRes = theme.iconMaximize
            //                break
            //            }
        } else {
            root.windowMax() //触发窗体最大化信号
        }
    }
}
