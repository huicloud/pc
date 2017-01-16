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
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import "../controls"

Item {
    id: root

    property int updown: rowData[field + '_updown'] || 0
    property string position: [rowIndex, columnIndex].join('_');
    property int highlight: position === rowData[field + '_position'] ? (rowData[field + '_highlight'] || 0) : 0

    property string rowId: id

    Rectangle {
        id: background
        opacity: 0
        anchors.fill: parent
    }

    Text {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        horizontalAlignment: column.align
        text: column.format(rowData)
        color: column.updownStyle ? (root.updown > 0 ? column.upColor : root.updown < 0 ? column.downColor : column.normalColor) : column.textColor

        elide: Text.ElideRight

        font {
            family: column.fontFamily
            pixelSize: column.fontSize
            weight: column.fontWeight
        }
    }

    onHighlightChanged: {
        state = '';
        background.color = 'transparent';
        background.opacity = 0;
        if (column.highlightPolicy === 'change' && highlight > 0) {
            // do nothing
        } else if (column.highlightPolicy === 'updown' && highlight !== 0) {
            background.color = highlight > 0 ? '#ffcece' : '#b1f7a8';
            background.opacity = 1;
        }
    }

    HighlightAnimation {
        id: highlightAnimation
        target: background

        // 避免数据不变情况下重复显示高亮效果，在执行结束后将数据清除
        onRunningChanged: {
            if (!running) {
                rowData[field + '_highlight'] = 0;
            }
        }
    }
}
