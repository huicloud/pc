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

pragma Singleton

import QtQuick 2.0
import QtQuick.Window 2.0

import "../core"

ContextComponent {
    property bool inited: false
    property var stockSelectionWindow;
    function openWindow(options) {
        if (!stockSelectionWindow) {
            var component = Qt.createComponent("StockSelectionWindow.qml");
            if (component.status === Component.Ready) {
                stockSelectionWindow = component.createObject(context.mainWindow);
                stockSelectionWindow.open(options);
            } else {
                component.statusChanged.connect(function() {
                    if (component.status === Component.Ready) {
                        stockSelectionWindow = windowComponent.createObject(context.mainWindow);
                        stockSelectionWindow.open(options);
                    }
                });
            }
        } else {
            if (stockSelectionWindow.visibility === Window.Minimized) {
                // 如果窗口当前状态为最小化时，将窗体还原(最小化还原后窗口看不见了)
                stockSelectionWindow.visibility = Window.Windowed;
            }
            stockSelectionWindow.open(options);
        }
    }
    Component.onCompleted: {
        var component = Qt.createComponent("StockSelectionWindow.qml");
        if (component.status === Component.Ready) {
            stockSelectionWindow = component.createObject(context.mainWindow);
        } else {
            component.statusChanged.connect(function() {
                if (component.status === Component.Ready) {
                    stockSelectionWindow = windowComponent.createObject(context.mainWindow);
                }
            });
        }
        inited = true;
    }
}
