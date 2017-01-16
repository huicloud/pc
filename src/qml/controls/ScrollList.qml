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

/**
 * 滚动列表组件(动态计算滚动位置，更新展示数据)
 */
BaseComponent {

    id: root

    // 数据，对象数组
    property var model: []

    default property Component delegate

    readonly property Flickable flickableItem: _flicker

    readonly property ColumnLayout contentItem: _contentItem

    readonly property VScrollBar scrollBar: _scrollBar

    property bool highlightOnFocus: false

    property int minRowHeight: 24

    // 固定位置(可以设置固定位置，top:表示滚动到最顶部时固定在顶部，bottom:表示滚动到最底部时固定在底部，其它值则不做固定操作)
    property string fixPosition: 'top'

    property var focusItem

    property var focusItemData

    readonly property int showCount: Math.floor(height / minRowHeight)

    readonly property var showData: {
        if (model) {

            // TODO 有错误的话考虑用contentY和contentHeight计算
            var index = Math.floor(_flicker.visibleArea.yPosition * model.length);
            return model.slice(index, index + showCount);
        } else {
            return [];
        }
    }

    Flickable {
        id: _flicker
        anchors.fill: parent
        contentHeight: minRowHeight * model.length
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Binding on contentY {
            when: state === 'autoscrollTop'
            value: 0
        }

        Binding on contentY {
            when: state === 'autoscrollBottom'
            value: _flicker.contentHeight - _flicker.height
        }

        onContentYChanged: {
            if (contentY >= _flicker.contentHeight - _flicker.height - 10 && root.fixPosition === 'bottom') {
                state = 'autoscrollBottom';
            } else if (contentY <= 10) {
                state = 'autoscrollTop';
            } else {
                state = '' ; // default state
            }
        }
    }

    Component {
        id: _internalItem
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: _scrollBar.visible ? true : false
            Layout.preferredHeight: _scrollBar.visible ? -1 : root.minRowHeight
            Layout.alignment: Qt.AlignTop

            color: focusItemData === showData[index] ? '#ecf2ff' : 'transparent'

            // 如果delegate组件中需要处理自己的点击事件需要设置MouseArea
            // propagateComposedEvents: true
            // 在事件处理中设置
            // mouse.accepted = false;
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.highlightOnFocus) {
                        focusItem = loader.item;
                        focusItemData = showData[index];
                    }
                }
            }

            Loader {
                id: loader
                anchors.fill: parent
                sourceComponent: root.delegate
                property var itemModelData: showData[index]
                property int itemIndex: index
            }
        }
    }

    ColumnLayout {
        id: _contentItem
        anchors.fill: _flicker
        anchors.rightMargin: _scrollBar.visible ? 8 : 0
        clip: true
        spacing: 0
        Repeater {
            model: root.showData
            delegate: _internalItem
        }

        // 用于填充剩余高度
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: _scrollBar.visible ? false : true
            Layout.preferredHeight: 0
            height: 0
        }
    }

    VScrollBar {
        id: _scrollBar
        flicker: _flicker
    }

    // 向上(没有焦点时，向上显示一个数据，有焦点时，焦点向上移动一个元素)
    function up() {
    }

    // 向上(没有焦点时，向下显示一个数据，有焦点时，焦点向下移动一个元素)
    function down() {
    }
}
