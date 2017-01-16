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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import "../core"

ScrollView{
    id: root
    property bool controlVisible: true    //是否显示按钮
    property int minimumHandleLength: 30  //滚动条最小宽度（高度）
    property int handleOverlap: 0         //滚动条位置偏移
    property bool scrollToClickedPosition: true  //是否滚动条上点击后 位置发生变化
    property real verticalScrollBarStep: 20      //每次点击上下按钮移动的距离
    property real horizontalScrollBarStep: 20    //每次点击左右按钮移动的距离
    property alias wheelAreaScrollSpeed: root.__wheelAreaScrollSpeed  //滚动一次偏移距离

    Binding on wheelAreaScrollSpeed {
        value: verticalScrollBarStep
    }

    width: 400
    height: 300

    style: ScrollViewStyle{
        minimumHandleLength: root.minimumHandleLength
        handleOverlap: root.handleOverlap
        scrollToClickedPosition: root.scrollToClickedPosition
        handle: Rectangle {
            implicitHeight: theme.tableScrollbarSize
            implicitWidth: theme.tableScrollbarSize
            color: theme.scrollbarBackgroundColor
            Rectangle{
                height: parent.height - 3
                width: parent.width - 3
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 2
                anchors.topMargin: 2
                color: theme.scrollbarSliderColor
                opacity: styleData.hovered ? 1 : 0.8
                //border.width: 1
                //border.color: theme.scrollbarSliderBorderColor
                radius:  parent.width - 3
            }
        }

        scrollBarBackground: Rectangle {
            implicitHeight: theme.tableScrollbarSize
            implicitWidth: theme.tableScrollbarSize
            color: theme.scrollbarBackgroundColor
        }

        incrementControl: Rectangle {
            visible: root.controlVisible
            implicitWidth: visible ? theme.tableScrollbarSize : 0
            implicitHeight: visible ? theme.tableScrollbarSize : 0
            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: -1
                anchors.rightMargin: -1
                color: theme.scrollbarBackgroundColor
                Image{
                    source: styleData.horizontal ? theme.scrollBarRightImage : theme.scrollBarDownImage
                    anchors.centerIn: parent
                    opacity: styleData.hovered ? 1 : 0.5
                }
            }
        }

        decrementControl: Rectangle {
            visible: root.controlVisible
            implicitWidth: visible ? theme.tableScrollbarSize : 0
            implicitHeight: visible ? theme.tableScrollbarSize : 0
            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: -1
                anchors.rightMargin: -1
                color: theme.scrollbarBackgroundColor
                Image{
                    source: styleData.horizontal ? theme.scrollBarLeftImage : theme.scrollBarUpImage
                    anchors.centerIn: parent
                    opacity: styleData.hovered ? 1 : 0.8
                }
            }
        }

        corner: Rectangle {
            color: theme.backgroundColor
            anchors.fill: parent
        }

//        frame: Rectangle{
//            anchors.fill: parent
//            color: theme.scrollbarBackgroundColor
//        }
    }

    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOn
    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn

    Component.onCompleted: {
        root.__scroller.verticalScrollBar.singleStep = root.verticalScrollBarStep
        root.__scroller.horizontalScrollBar.singleStep = root.horizontalScrollBarStep
        root.flickableItem.boundsBehavior = Flickable.StopAtBounds
    }

    onVerticalScrollBarStepChanged: {
        root.__scroller.verticalScrollBar.singleStep = root.verticalScrollBarStep;
    }

    onHorizontalScrollBarStepChanged: {
        root.__scroller.horizontalScrollBar.singleStep = root.horizontalScrollBarStep;
    }
}

