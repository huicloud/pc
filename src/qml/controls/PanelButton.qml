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
import QtQuick.Controls 1.4
import QtQml 2.2

import "../core"
import "./"

BaseComponent {
    id: root

    property color panelButtonColor: theme.panelButtonColor
    property color panelButtonTextColor: theme.panelButtonTextColor
    property color panelButtonBorderColor: theme.panelButtonBorderColor
    property color panelButtonHoveredColor: theme.panelButtonHoveredColor
    property color panelButtonHoveredTextColor: theme.panelButtonHoveredTextColor
    property color panelButtonHoveredBorderColor: theme.panelButtonHoveredBorderColor
    property color panelButtonCheckedColor: theme.panelButtonCheckedColor
    property color panelButtonCheckedTextColor: theme.panelButtonCheckedTextColor
    property color panelButtonCheckedBorderColor: theme.panelButtonCheckedBorderColor

    property real panelButtonBorderWidth: theme.panelButtonBorderWidth
    property real panelButtonBorderRadius: theme.panelButtonBorderRadius
    property real panelButtonLeftPadding: theme.panelButtonLeftPadding
    property real panelButtonRightPadding: theme.panelButtonRightPadding
    property real panelButtonTopMargin: theme.panelButtonTopMargin
    property real panelButtonBottomMargin: theme.panelButtonBottomMargin
    property real panelButtonMenuMinWidth: theme.panelButtonMenuMinWidth

    property alias text: buttonText.text
    property alias checked: button.checked

    property var menuItems
    property var currentItem: menuItems ? menuItems[0] : null
    property bool clickOpenMenu: false

    Component {
        id: menuItem
        MenuItem {
        }
    }

    property Menu _menu: PopMenu {
        id: listMenu
        checkableStyle: true
        items: (root.menuItems || []).map(function(eachItem) {
            var item = menuItem.createObject(parent, {text: eachItem.text, checkable: true, checked: eachItem.checked || false});
            item.triggered.connect(function() {
                if (eachItem.triggered) {
                    eachItem.triggered(eachItem);
                } else {
                    currentItem = eachItem;
                    root.clickTriggered(eachItem);
                }
            });
            return item;
        })
    }
    property var menu: menuItems ? _menu : null

    signal clickTriggered(var data)

    width: button.width

    ColumnLayout {
        height: parent.height
        Button {
            id: button
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: rowLayout.width
            Layout.topMargin: panelButtonTopMargin
            Layout.bottomMargin: panelButtonBottomMargin

            Rectangle {
                height: parent.height
                border.width: panelButtonBorderWidth
                border.color: button.checked ? panelButtonCheckedBorderColor : button.hovered ? panelButtonHoveredBorderColor : panelButtonBorderColor
                radius: panelButtonBorderRadius
                color: button.checked ? panelButtonCheckedColor : button.hovered ? panelButtonHoveredColor : panelButtonColor
                width: rowLayout.width
                RowLayout {
                    id: rowLayout
                    height: parent.height
                    spacing: 0
                    Text {
                        Layout.fillHeight: true
                        id: buttonText
                        leftPadding: panelButtonLeftPadding
                        rightPadding: panelButtonRightPadding
                        color: button.checked ? panelButtonCheckedTextColor : button.hovered ? panelButtonHoveredTextColor : panelButtonTextColor
                        text: currentItem ? currentItem.text : ''
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: childrenRect.width
                        visible: !!menu
                        RowLayout {
                            height: parent.height
                            spacing: 0
//                            SeparatorLine {
//                                Layout.fillHeight: true
//                                length: parent.height
//                                color: button.checked ? panelButtonCheckedBorderColor : button.hovered ? panelButtonHoveredBorderColor : panelButtonBorderColor
//                            }

                            Image{
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                Layout.preferredWidth: theme.dropdownImageSize
                                Layout.preferredHeight: theme.dropdownImageSize
//                                Layout.leftMargin: panelButtonRightPadding / 2
                                Layout.rightMargin: panelButtonRightPadding// / 2
                                source: theme.dropdownImage
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.menu) {
                                    root.menu.__minimumWidth = panelButtonMenuMinWidth;
                                    root.menu.__popup(Qt.rect(0, root.height, 0, 0),0);
                                }
                            }
                        }
                    }
                }
            }

            onClickTriggered: {
                if (clickOpenMenu && root.menu) {
                    root.menu.__minimumWidth = panelButtonMenuMinWidth;
                    root.menu.__popup(Qt.rect(0, root.height, 0, 0),0);
                }
                root.clickTriggered(root.currentItem);
            }
        }
    }

    Binding {
        target: root.menu
        property: "__visualItem"
        value: button
    }
}
