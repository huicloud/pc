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
  * @brief  EditLabel
  * @author dongwei
  * @date   2016
  */
import QtQuick 2.0
import QtQuick.Window 2.0
import "./"
import "../core"

Rectangle {
    id: root
    height: 26
    width: 100
    border.color: theme.keyboardSpriteBoderColor
    border.width: 1
    color: theme.keyboardSpriteInputBackgroundColor

    property var theme: ThemeManager.currentTheme

    property alias textHint: textHint.text
    property alias textHintColor: textHint.color
    property alias textHintFont: textHint.font
    property alias textHintAnchors: textHint.anchors

    property alias textFocus: textInput.focus
    property alias text: textInput.text
    property alias textColor: textInput.color
    property alias textFont: textInput.font
    property alias textAnchors: textInput.anchors
    property alias selectByMouse: textInput.selectByMouse
    property alias selectedTextColor: textInput.selectedTextColor
    property alias selectionColor: textInput.selectionColor
    property alias verticalAlignment: textInput.verticalAlignment
    property alias horizontalAlignment: textInput.horizontalAlignment
    property alias maximumLength: textInput.maximumLength

    property alias readOnly: textInput.readOnly
    signal accepted                       //回车事件触发
    signal inputTextChanged(string text)  //文本变化事件触发
    Text {
        id: textHint
        anchors {
            fill: parent
            leftMargin: 4
            rightMargin: 4
        }
        verticalAlignment: Text.AlignVCenter
        text: "请输入内容……"
        color: theme.hintTextColor
    }

    TextInput {
        id: textInput
        anchors {
            fill: parent
            leftMargin: 4
            rightMargin: 4
        }

        verticalAlignment: Text.AlignVCenter
        renderType: Screen.devicePixelRatio === 1 ? Text.NativeRendering : Text.QtRendering
        focus: true
        selectByMouse: true
        font {
            family: theme.fontFamily
            pixelSize: theme.fontSize
            weight: theme.fontWeight
            //capitalization: Font.AllUppercase
        }
        //selectedTextColor: "green"
        //selectionColor: "red"
        color: theme.textColor
        onAccepted: {
            root.accepted()
        }
        onTextChanged: {
            root.inputTextChanged(textInput.text)
        }
    }

    states: State {
        name: "hasTextInput"
        when: textInput.text !== ''
        PropertyChanges {
            target: textHint
            opacity: 0
        }
    }

    onFocusChanged: {
       if (root.focus){
           textInput.forceActiveFocus();
       }
    }
}
