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
  * @brief  button
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls.Styles 1.4

import "../core/"
import "../core/common"
import "./"

Controls.Button {
    id: button
    height: 30
    width: 40
    property var theme: ThemeManager.currentTheme

    property real backgroundRadius: 0             //默认背景圆角
    property real checkedRadius: backgroundRadius           //选中时的背景圆角
    property real hoveredRadius: backgroundRadius           //鼠标移动时的背景圆角
    property color backgroundColor: "transparent" //背景色
    property color checkedColor: backgroundColor  //选中时的背景色
    property int borderWidth: 0;                  //边框大小

    property color borderColor: backgroundColor  //边框颜色
    property color borderCheckedColor: backgroundColor
    property color borderHoverColor: backgroundColor

    property color hoveredColor: backgroundColor  //鼠标移动时的背景色

    property bool isAlwaysChecked: false          //点击是否一直选中状态

    property color textColor: theme.textColor //默认文字颜色
    property color checkedTextColor: textColor //选中时的文字颜色
    property color hoveredTextColor: textColor //鼠标移动时的文字颜色

    property color disenabledColor: backgroundColor //不可用的时候的颜色
    property color disenabledTextColor: textColor   //不可用的时候的文字颜色

    property alias hoverEnabled: mouseArea.hoverEnabled //是否允许触发鼠标移动
    property font textFont    //字体格式
    property real paddingLeft: 0
    property real paddingTop: 0
    property real paddingRight: 0
    property real paddingBottom: 0
    property real backgroundMarginLeft: 0
    property real backgroundMarginTop: 0
    property real backgroundMarginRight: 0
    property real backgroundMarginBottom: 0
    property bool hasRedDot: false
    property color redDotColor: theme.redDotColor
    property real redDotSize: theme.redDotSize
    property real redDotSpacing: theme.redDotSpacing
    property alias pressed: mouseArea.pressed
    property alias hovered: mouseArea.hovered

    signal clickTriggered  //点击事件触发信号
    signal pressTriggered  //鼠标按下事件触发信号
    signal hoverTriggered //鼠标移动事件触发信号
    signal hoverExitTriggered //鼠标移出事件触发信号

    //checkable: true //是否支持选中状态
    style: ButtonStyle {
        padding {
            left: button.paddingLeft
            right: button.paddingRight
            top: button.paddingTop
            bottom: button.paddingBottom
        }

        background: Rectangle {
            anchors.fill: parent
            color: button.enabled ? (button.checked ? button.checkedColor : (button.hovered ? button.hoveredColor : button.backgroundColor)) : disenabledColor
            radius: button.checked ? button.checkedRadius : (button.hovered ? button.hoveredRadius : button.backgroundRadius)
            anchors.leftMargin: button.backgroundMarginLeft
            anchors.topMargin: button.backgroundMarginTop
            anchors.rightMargin: button.backgroundMarginRight
            anchors.bottomMargin: button.backgroundMarginBottom
            border.width: borderWidth
            border.color: button.checked ? button.borderCheckedColor: (button.hovered ? button.borderHoverColor : (button.focus ? button.checkedColor : button.borderColor))
        }

        label: Item {
            clip: true
            anchors.centerIn: parent
            implicitHeight: text.height + button.redDotSpacing
            implicitWidth: text.width + button.redDotSpacing
            Text {
                id: text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: button.text
                //font: button.textFont
                color: button.enabled ? (button.checked ? button.checkedTextColor : (button.hovered ? button.hoveredTextColor : button.textColor)) : disenabledTextColor
            }

            Rectangle {
                id: redDot
                visible: hasRedDot
                anchors.left: text.right
                anchors.leftMargin: button.redDotSpacing
                anchors.top: text.top
                anchors.topMargin: -button.redDotSpacing
                width: button.redDotSize
                height: button.redDotSize
                radius: button.redDotSize / 2
                color: button.redDotColor
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        property bool pressed: false
        property bool hovered: false

        onEntered: {
            hovered = true
            button.hoverTriggered()
        }
        onExited: {
            hovered = false
            button.hoverExitTriggered()
        }
        onPressed: {
            pressed = true
            button.pressTriggered()
        }
        onReleased: {
            pressed = false
        }
        onClicked: {

            if (button.checkable) {
                if (isAlwaysChecked)
                    button.checked = true
                else
                    button.checked = !button.checked
            }

            button.clickTriggered()
        }
    }
}
