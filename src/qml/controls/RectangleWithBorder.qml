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
  * @brief  RectangleWithBorder
  * @author dongwei
  * @date   2016
  */


import QtQuick 2.0

Rectangle {
    id: root

    property int leftBorder: 0
    property int rightBorder: 0
    property int topBorder: 0
    property int bottomBorder:0
    default property alias contents: content.children
    property alias color: content.color

    height: 200
    width: 200
    border.color: "#ccc"
    border.width: 0
    clip: true

    Rectangle {
        id: content
        anchors.fill: parent
        anchors.leftMargin: leftBorder
        anchors.rightMargin: rightBorder
        anchors.topMargin: topBorder
        anchors.bottomMargin: bottomBorder
        clip: true
    }

    onLeftBorderChanged: {
        changeBorder()
    }
    onRightBorderChanged: {
        changeBorder()
    }
    onTopBorderChanged: {
        changeBorder()
    }
    onBottomBorderChanged: {
        changeBorder()
    }

    function changeBorder() {
        var border = Math.max(leftBorder, rightBorder, topBorder, bottomBorder)
        root.border.width = border
    }
}
