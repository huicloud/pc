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

import './'
import "../core"

BaseComponent {
    id: root
    property Window mainWindow: null  //传入被控制的窗体
    property alias windowButton: windowButtonSystem
    property string title: ''
    property int textLeftMargin: 5
    property alias miniTitlebar: windowButtonSystem.miniTitlebar
    height: miniTitlebar ? theme.toolbarMiniHeight : theme.toolbarHeight

    Rectangle {
        id: titlebar
        width: parent.width
        height: root.height
        anchors.top: parent.top
        color: theme.toolbarColor
        Text{
            id: text
            anchors.fill: parent
            anchors.leftMargin: textLeftMargin
            anchors.rightMargin: 5 +  windowButtonSystem.width
            elide: Text.ElideMiddle
            text: title
            color: theme.backgroundColor
        }

        MouseArea {
            //鼠标拖拽标题栏 窗口移动
            id: toolBarMouseArea
            anchors.fill: titlebar
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
            onDoubleClicked: {
                if (windowButtonSystem.showMaxButton && windowButtonSystem.showMaximized())
                    windowButtonSystem.showMaximized();
            }
        }

        WindowControlBox {
            id: windowButtonSystem
            height: parent.height
            anchors.top: parent.top
            anchors.right: parent.right
            controlWindow: mainWindow
        }
    }

    function showMaximized(){
        windowButtonSystem.showMaximized()
    }
}
