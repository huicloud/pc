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
 * 包含头部组件，内容组件的面板控件
 */
BaseComponent {
    id: root

    // 头部组件的默认背景颜色
    property color headerBackgroundColor: theme.panelHeaderBackgroundColor

    // 边框颜色, header和content之间的边框颜色
    property color borderColor: theme.panelBorderColor

    // 头部高度
    property real headerHeight: theme.panelHeaderHeight

    // 内容的背景颜色
    property color contentBackgroundColor: theme.panelContentBackgroundColor

    // 是否使能关闭按钮（点击可以显示和隐藏内容部分）
    property bool closeButtonEnable: true

    // 控制内容部分是否显示
    property bool showContent: true
    property bool showF10Content: true

    property alias leftBorder: rectangleWithBorder.leftBorder
    property alias rightBorder: rectangleWithBorder.rightBorder
    property alias topBorder: rectangleWithBorder.topBorder
    property alias bottomBorder: rectangleWithBorder.bottomBorder

    property Component header
    property Component content

    property alias headerItem: headerLoader.item
    property alias contentItem: contentLoader.item

    // 固定高度（默认 -1 则不固定高度）
    property real fixedHeight: -1

    signal contentVisibleChanged(bool contentVisible)

    // 内容显示时高度为fixedHeight，不显示时为头部高度
    height: contentContainer.visible ? fixedHeight : headerHeight

    clip: true

    focusAvailable: false

    RectangleWithBorder {
        id: rectangleWithBorder
        anchors.fill: parent
        border.color: borderColor
        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            spacing: 0
            RectangleWithBorder {
                id: headerContainer
                Layout.fillWidth: true
                Layout.preferredHeight: headerHeight
                color: headerBackgroundColor
                border.color: borderColor
                bottomBorder: 1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Loader {
                        id: headerLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: header
                    }
                    PanelIconButton {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight
                        visible: closeButtonEnable
                        alignRight: true
                        imageRes: theme.iconBottomHide
                        exitedWhenClicked: true
                        onClickTriggered: {
                            root.onClickMiniButton();
                        }
                    }
                }
            }
            Rectangle {
                id: contentContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: showContent
                color: contentBackgroundColor
                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    sourceComponent: content
                }
            }
        }
    }

    function onClickMiniButton() {
        showContent = !showContent;
        root.contentVisibleChanged(showContent)
    }
}
