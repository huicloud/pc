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
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls.Styles 1.4
import "../core"
import "./"
Controls.Menu {
    property bool checkableStyle: false
    property int textLeftMarigin: 0
    property var theme: ThemeManager.currentTheme

    style:MenuStyle {
        frame:Rectangle{
            border.width: 1
            border.color: theme.popMenuBorderColor
        }

        separator: Rectangle {
            implicitHeight: 1
            implicitWidth: 1
            color: theme.popMenuSeparatorColor
        }

        scrollIndicator: Rectangle{
            height: 10
            width: parent.width
            color: theme.popMenuScollIndicatorColor
            Image{
               anchors.centerIn: parent
               source: styleData.scrollerDirection === Qt.DownArrow ? theme.downImage : theme.upImage
               sourceSize: Qt.size(6, 6)
            }
        }

        itemDelegate.background : Rectangle {
            color: styleData.selected ? theme.popMenuItemSelectedColor : theme.backgroundColor
            Rectangle{
                height: parent.height
                width: 24
                color:  styleData.selected ? theme.popMenuItemSelectedColor : checkableStyle ? theme.popMenuCheckableStyleColor : "transparent"
            }
        }

        itemDelegate.label: Text {
            x: 8 + textLeftMarigin
            text:styleData.text
        }

        itemDelegate.checkmarkIndicator: Image{
            visible: styleData.checked
            source: theme.selectedImage
            sourceSize: Qt.size(12, 12)
        }

        itemDelegate.submenuIndicator: Image {
            source: theme.rightImage
            sourceSize: Qt.size(12, 12)
            baselineOffset: 11
        }
    }
}

