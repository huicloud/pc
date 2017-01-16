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

/**
 * X轴类型
 */
QtObject {
    property var chart
    property var data: chart.cache.map && chart.cache.map(function(eachData) { return eachData.ShiJian })

    property real chartWidth: chart.chartWidth - chart.leftSpace - chart.rightSpace
    property real pixelPer: chartWidth / (data && data.length || 1)

    property bool crossLine: false
    property real mouseX: -1

    readonly property real _mouseX: crossLine ? mouseX - chart.leftSpace : -1

    readonly property real _mouseIndex: _mouseX < 0 || _mouseX > chartWidth ? -1 : parseInt(_mouseX / pixelPer)

    readonly property var mouseXData: (_mouseIndex >= 0 && data && data[_mouseIndex]) ? data[_mouseIndex]: null

    readonly property real lineX: getCenterX(mouseXData)

    readonly property var ticks: {
        return chart.getXTicks(pixelPer);
    }

    function getLeftX(time) {
        return getCenterX(time) - getWidth() / 2;
    }

    function getCenterX(time) {
        if (data) {
            var index = data.indexOf(time);
            if (index >= 0) {
                return chart.leftSpace + (index + 0.5) * pixelPer;
            }
        }
        return NaN;
    }

    function getWidth() {
        return pixelPer > 1 ? (pixelPer - pixelPer / 3) : pixelPer;
    }

    function moveLeft() {
        var nextIndex;
        if (_mouseIndex < 0) {
            nextIndex = data.length - 1;
        } else {
            nextIndex = Math.max(_mouseIndex - 1, 0);
        }
        mouseX = getCenterX(data[nextIndex]);
    }

    function moveRight() {
        var nextIndex;
        if (_mouseIndex < 0) {
            nextIndex = 0;
        } else {
            nextIndex = Math.min(_mouseIndex + 1, data.length - 1);
        }
        mouseX = getCenterX(data[nextIndex]);
    }

    function getXTickLabel(time, detail) {
        return chart.getXTickLabel(time, detail);
    }
}
