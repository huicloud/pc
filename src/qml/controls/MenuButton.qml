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
import QtQuick.Controls 1.4
import "../core"
import "./"

Rectangle {
    id: root
    width: 40
    height: 30
    property Menu menu: null
    property int minimumPopMenuWidth: 80
    property int textLeftMargin: 6
    property int imageRightMargin: theme.dropdownImageSize / 2
    property alias text: text.text
    property alias textColor: text.color
    property alias textHorizontalAlignment: text.horizontalAlignment
    property var theme: ThemeManager.currentTheme
    property bool isTextClickedDropDownEnable: true

    property alias hoverEnabled: mouseArea.hoverEnabled
    property bool hovered: false
    property bool checked: false
    property color hoveredColor: theme.backgroundColor
    property color backgroundColor: theme.backgroundColor //背景色
    property color checkedColor: theme.backgroundColor //选中时的背景色

    property color __preColor
    color: backgroundColor

    signal clicked

    Text{
        id: text
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: textLeftMargin
        anchors.rightMargin: textLeftMargin
        anchors.top: parent.top
        anchors.right: image.left
        clip: true

    }

    Image{
        id: image
        anchors.right: parent.right
        anchors.rightMargin: imageRightMargin
        anchors.top: parent.top
        anchors.topMargin:{
            var margin = (parent.height - theme.dropdownImageSize) / 2;
            if (parseInt(margin)){
                margin = margin - 0.5
            }
            return margin;
        }
        width: theme.dropdownImageSize
        height: theme.dropdownImageSize
        source: theme.dropdownImage
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        visible: image.status == Image.Ready
        asynchronous: true
    }

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        onClicked: {

            if (isTextClickedDropDownEnable) {
                showPopMenu()
            } else {
                if (mouseX < text.width){   //文字区域点击
                    root.clicked();
                } else {    //下拉图标区域点击
                    showPopMenu()
                }
            }
        }

        onEntered: {
            if (mouseArea.hoverEnabled){
                root.hovered = true
                __preColor = root.color
                root.color =  root.checked ? root.checkedColor : (root.hovered ? root.hoveredColor : root.backgroundColor)
            }
        }

        onExited: {
            if (mouseArea.hoverEnabled){
                root.hovered = false
                root.color = root.checked ? root.checkedColor : __preColor
            }
        }
    }

    Binding {
        target: root.menu
        property: "__visualItem"
        value: mouseArea
    }

    onCheckedChanged: {
        root.color = root.checked ? root.checkedColor : (root.hovered ? root.hoveredColor : root.backgroundColor)
    }

    function showPopMenu(){
        if (menu !== null){
            menu.__minimumWidth = minimumPopMenuWidth
            menu.aboutToHide.connect(function(){
            })

            menu.aboutToShow.connect(function(){
            })

            menu.__popup(Qt.rect(0, root.height, 0, 0),0)

        }
    }
}
