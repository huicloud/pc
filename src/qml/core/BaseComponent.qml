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
import QtQuick.Controls 1.2

import "./"
import "./common"
import "../controls"

/**
 * 基础组件
 */
FocusScope {
    id: root

    // 主题
    property var theme: ThemeManager.currentTheme
    property QtObject appConfig: ApplicationConfigure

    property bool focusAvailable: true

    property alias rightClickMouseArea: _rightClickMouseArea

    property Component contextMenuComponent

    property var contextMenuItems

    // 保证点击可以得到焦点
    MouseArea {
        propagateComposedEvents: true
        anchors.fill: parent
        onClicked: {

            // 是否可以得到焦点
            if (root.focusAvailable) {
                root.forceActiveFocus();
                mouse.accepted = true;
            } else {
                mouse.accepted = false;
            }
        }
        onPressed: {
            mouse.accepted = false;
        }
    }

    MouseArea {
        id: _rightClickMouseArea
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.RightButton
        onClicked: {
            var contextMenuComponent = root.contextMenuComponent
            if (!contextMenuComponent && root.contextMenuItems) {
                contextMenuComponent = _contextMenuComponent;
            }

            if (contextMenuComponent) {
                var menu = contextMenuComponent.createObject(root);
                menu.aboutToHide.connect(function() {
                    menu.destroy(1000);
                });
                menu.popup();
            } else {
                mouse.accepted = false;
            }
        }
    }

    Component {
        id: _contextMenuComponent
        PopMenu {
            checkableStyle: true

            Component.onCompleted: {

                // 避免数据绑定
                items = (root.contextMenuItems || []).map(function(eachItem) {

                    var props = {text: '', checkable: true, checked: false, visible: true};
                    for (var key in props) {
                        var value = eachItem[key];
                        if (value) {
                            if (typeof value === 'function') {
                                value = value.call(eachItem, eachItem, key, root);
                            }
                            props[key] = value;
                        }
                    }

                    var item = menuItem.createObject(parent, props);
                    item.triggered.connect(function() {
                        if (eachItem.triggered) {
                            eachItem.triggered(eachItem);
                        }
                    });
                    return item;
                });
            }
        }
    }

    Component {
        id: menuItem
        MenuItem {
        }
    }

//    Component { id: timerComponent; Timer {} }

//    function setTimeout(callback, timeout) {
//        var timer = timerComponent.createObject(parent);
//        timer.interval = timeout || 1;
//        timer.triggered.connect(function() {
//            timer.destroy();
//            callback();
//        });
//        timer.start();
//    }
}
