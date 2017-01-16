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
    * @brief  VScrollBar 垂直滚动条
    * @author dongwei
    * @date   2016
    */

import QtQuick 2.0
import "../core"

Rectangle {
    id: scrollbar
    property var theme: ThemeManager.currentTheme

    color: theme.scrollbarBackgroundColor
    width: theme.scrollbarSize
    visible: (flicker.visibleArea.heightRatio < 1.0)

    property Flickable flicker: null
    property bool horizontalScrollBarIsVisible: false
    property real horizontalScrollBarWidth: 0
    property alias sliderRadius: slider.radius
    property alias sliderBorder: slider.border
    property alias sliderColor: slider.color

    anchors {
        top: flicker.top
        right: flicker.right
        bottom: flicker.bottom
        bottomMargin: horizontalScrollBarIsVisible ? horizontalScrollBarWidth: 0
    }

    Rectangle {
        id: slider
        height: Math.max(scrollbar.height * flicker.visibleArea.heightRatio, 10)
        color: theme.scrollbarSliderColor
        radius: slider.width
        border {
            width: 1
            color: theme.scrollbarSliderBorderColor
        }

        anchors {
            left: parent.left
            right: parent.right
        }

        Binding {
            target: slider
            property: "y"
            value: (flicker.visibleArea.yPosition * scrollbar.height)
            when: (!dragger.drag.active)
        }

        Binding {
            target: flicker
            property: "contentY"
            value: (slider.y / scrollbar.height * flicker.contentHeight)
            when: (dragger.drag.active)
        }

        MouseArea {
            id: dragger
            anchors.fill: parent
            drag {
                target: slider
                minimumX: slider.x
                maximumX: slider.x
                minimumY: 0
                maximumY: (scrollbar.height - slider.height)
                axis: Drag.YAxis
            }
        }
    }
}
