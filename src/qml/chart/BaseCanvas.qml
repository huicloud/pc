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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import "./"
import "../core"
import "../js/Util.js" as Util

ContextComponent {
    id: root

    property string obj

    property var showMenuItems

    property bool crossLine: false

    property var chartContainer

    property var charts: chartContainer ? chartContainer.charts : []

    property bool forceFocus: true

    onVisibleChanged: {
        visible && forceFocus && forceActiveFocus();
    }

    function showCrossLine(position) {

        root.crossLine = true;

        // 设置charts中的XAxis和YAxis上的属性
        var handleredXAxis = [];

        Array.prototype.forEach.call(root.charts, function(eachChart) {
            var xAxis = eachChart.xAxis;
            var yAxis = eachChart.yAxis;
            if (handleredXAxis.indexOf(xAxis) < 0) {

                // position指定初始位置显示十字光标
                if (position === 'left') {
                    xAxis.moveLeft();
                } else if (position === 'right') {
                    xAxis.moveRight();
                }
                handleredXAxis.push(xAxis);

                xAxis.crossLine = true;
            }
            yAxis.crossLine = true;
        });
    }

    function hideCrossLine() {
        root.crossLine = false;

        // 设置charts中的XAxis和YAxis上的属性
        Array.prototype.forEach.call(root.charts, function(eachChart) {
            eachChart.xAxis.crossLine = false;
            eachChart.yAxis.crossLine = false;
        });
    }

    function pressEscape(event) {
        if (crossLine) {
            hideCrossLine();
            event.accepted = true;
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Left) {
            root.showCrossLine('left');
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            root.showCrossLine('right');
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            root.pressEscape(event);
        }
    }
}
