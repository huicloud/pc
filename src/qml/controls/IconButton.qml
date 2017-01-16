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
  * @brief  IconButton
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import "../core/common"

Button {
    id: iconButton
    property size iconSize: Qt.size(24, 24) //默认大小
    property IconResource iconRes           //Icon资源
    property color backgroundColor: "transparent"   //背景颜色
    property alias hoverEnabled: mouseArea.hoverEnabled //是否允许触发鼠标移动

    implicitHeight: iconSize.height
    implicitWidth: iconSize.width
    iconSource: iconRes.defaultIcon //默认显示图标

    signal clickTriggered //点击事件触发信号
    signal pressTriggered //鼠标按下事件触发信号
    signal hoverTriggered //鼠标移动事件触发信号

    style: ButtonStyle {
        background: Rectangle {
            anchors.fill: parent
            color: backgroundColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: iconButton
        hoverEnabled: true
        onEntered: {
            iconButton.hoverTriggered()
            iconButton.iconSource = Qt.binding(function () {
                if (iconRes.hoverIcon == "")
                    return iconRes.defaultIcon
                else
                    return iconRes.hoverIcon
            })
        }
        onExited: iconButton.iconSource = Qt.binding(function () {
            return iconRes.defaultIcon
        })
        onPressed: {
            iconButton.pressTriggered()
            iconButton.iconSource = Qt.binding(function () {
                if (iconRes.pressIcon == "")
                    return iconRes.defaultIcon
                else
                    return iconRes.pressIcon
            })
        }
        onReleased: {
            iconButton.iconSource = Qt.binding(function () {
                return iconRes.defaultIcon
            })
        }
        onClicked: {
            iconButton.clickTriggered()
        }
    }
}
