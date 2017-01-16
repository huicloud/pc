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
import "../controls"

BaseComponent {
    id: root
    property var model

    visible: model && model.length > 0

    Rectangle {
        width: parent.width
        height: layout.height
        border.width: 1
        border.color: theme.chartTooltipBorderColor
        ColumnLayout {
            id: layout
            width: parent.width
            spacing: 0
            Repeater {
                id: repeater
                model: root.model.length
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.leftMargin: 4
                    Layout.rightMargin:4
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    spacing: 2
                    visible: root.model[modelData].visible !== false
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 15
                        text: root.model[modelData].label
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.model[modelData].height || 15
                        horizontalAlignment: Qt.AlignRight
                        elide: Text.ElideNone
//                        fontSizeMode: Text.HorizontalFit
                        wrapMode: Text.WordWrap

                        precision: root.model[modelData].precision !== undefined ? root.model[modelData].precision : 2
                        isAutoPrec: root.model[modelData].isAutoPrec || false
                        unit: root.model[modelData].unit || ''
                        isAutoFormat: root.model[modelData].isAutoFormat || false
                        isAbs: root.model[modelData].isAbs || false
                        normalColor: root.model[modelData].color || theme.textColor
                        baseValue: root.model[modelData].baseValue || 0
                        value: root.model[modelData].value || NaN
                        defaultText: root.model[modelData].defaultText || '--'

                        font.pixelSize: theme.fontSize - 2
                    }
                }
            }
        }
    }
}
