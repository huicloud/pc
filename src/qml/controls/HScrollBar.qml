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
    * @brief  HScrollBar 水平滚动条
    * @author dongwei
    * @date   2016
    */

import QtQuick 2.0
import "../core"
Rectangle {
    id: scrollbar
    color: theme.scrollbarBackgroundColor
    height: theme.scrollbarSize

    visible: flicker.visibleArea.widthRatio < 1.0

    property var theme: ThemeManager.currentTheme
    property bool verticalScrollBarIsVisible: false
    property real verticalScrollBarWidth: 0
    property Flickable flicker: null
    property alias sliderRadius: slider.radius
    property alias sliderBorder: slider.border
    property alias sliderColor: slider.color

    anchors {
        left: flicker.left
        right: flicker.right
        bottom: flicker.bottom
        rightMargin: (verticalScrollBarIsVisible ? verticalScrollBarWidth: 0)
    }

//    Rectangle{
//        id: block
//        color:scrollbar.color
//        visible: verticalScrollBarIsVisible ? true: false
//        height: scrollbar.height
//        width: verticalScrollBarWidth
//        anchors{
//           left: parent.left
//           right: flicker.right
//           bottom: flicker.bottom
//        }
//    }
    Rectangle {
        id: slider
        width: (scrollbar.width * flicker.visibleArea.widthRatio)
        color: theme.scrollbarSliderColor
        radius: slider.height
        border {
            width: 1
            color: theme.scrollbarSliderBorderColor
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        Binding {
            target: slider
            property: "x"
            value: (flicker.visibleArea.xPosition * scrollbar.width)
            when: (!dragger.drag.active)
        }

        Binding {
            target: flicker
            property: "contentX"
            value: (slider.x / scrollbar.width * flicker.contentWidth)
            when: (dragger.drag.active)
        }

        MouseArea {
            id: dragger
            anchors.fill: parent
            drag {
                target: slider
                minimumX: 0
                maximumX: (scrollbar.width - slider.width)
                minimumY: slider.y
                maximumY: slider.y
                axis: Drag.XAxis
            }
        }
    }
}
