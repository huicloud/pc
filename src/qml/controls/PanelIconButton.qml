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

BaseComponent {
    id: root

    property alias imageRes: button.imageRes
    property bool alignRight: false
    property bool alignLeft: false
    property alias exitedWhenClicked: button.exitedWhenClicked
    signal clickTriggered

    height: parent.height
    width: layout.width
    implicitWidth: width

    RowLayout {
        id: layout
        spacing: 0
        height: parent.height

        SeparatorLine {
            Layout.fillHeight: true
            length: parent.height
            color: button.hovered && (alignLeft !== true) ? theme.borderColor : 'transparent'
        }
        ImageButton {
            id: button
            Layout.fillHeight: true
            Layout.preferredWidth: 30
            Layout.alignment: Qt.AlignRight
            hoveredColor: theme.backgroundColor
            imageRes: theme.iconBottomHide
            imageSize: Qt.size(20, 18)

            onClickTriggered: {
                root.clickTriggered()
            }
        }
        SeparatorLine {
            Layout.fillHeight: true
            length: parent.height
            color: button.hovered && (alignRight !== true) ? theme.borderColor : 'transparent'
        }
    }
}
