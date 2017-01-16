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

import QtQuick 2.0
import QtQuick.Layouts 1.1

import "../core"
import "../controls"

BaseComponent {
    id: root

    property var chart
    property color backgroundColor: theme.chartTopBackgroundColor
    property color borderColor: theme.chartTopBorderColor
    property real topComponentHeight: theme.chartTopHeight

    property bool withBackground: true

    property var model: []

    width: parent.width
    height: topComponentHeight
    anchors.top: parent.top

    Rectangle {
        anchors.fill: parent
        visible: withBackground
        color: backgroundColor

        SeparatorLine {
            id: separatorLine
            anchors.bottom: parent.bottom
            orientation: Qt.Horizontal
            length: parent.width
            color: borderColor
            separatorWidth: 1
        }
    }

    RowLayout {
        anchors.fill: parent
        Repeater {
            model: root.model.length

            Text {
                property var textData: root.model[modelData]
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                text: textData.text || ''
                color: textData.color || theme.textColor
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }

    // 最右侧的关闭按钮
    ImageButton {
        id: button
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: 20
        height: 20
        imageRes: theme.iconIndicatorClose
        imageSize: Qt.size(16, 16)
        backgroundColor: root.backgroundColor

        visible: !!chart.close
        onClickTriggered: {
            chart.close();
        }
    }
}
