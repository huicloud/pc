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
 * Y轴类型
 */
QtObject {
    property var charts
    property real topSpace: charts[0].topSpace
    property real bottomSpace: charts[0].bottomSpace
    property real height: charts[0].chartHeight - charts[0].topSpace - charts[0].bottomSpace

    property int minHeightPerTick: 30

    property bool crossLine: false
    property real mouseY
    property real lineY: crossLine && mouseY > topSpace && mouseY < charts[0].chartHeight - charts[0].bottomSpace ? mouseY : -1

    property var range: {
        var max = Number.MIN_VALUE;
        var min = Number.MAX_VALUE;
        charts.forEach(function(eachChart) {
            if (eachChart.visible && eachChart.cache) {
                max = Math.max(max, eachChart.yMax);
                min = Math.min(min, eachChart.yMin);
            }
        });

        if (max !== Number.MIN_VALUE) {
            return [max, min];
        } else {
            return [0, 0];
        }
    }

    property var ticks: {
        if (typeof charts[0].getYTicks === 'function') {
            return charts[0].getYTicks(range[0], range[1], height, minHeightPerTick);
        } else {
            var count = Math.floor(height / minHeightPerTick);
            var heightPerTick = height / count;
            var _tick = [];
            var max = range[0];
            var min = range[1];
            var valuePerTick = (max - min) / count;

            for (var i = 0; i < count; i++) {
                _tick.push({
                    position: topSpace + heightPerTick * i,
                    value: max - (valuePerTick * i)
                });
            }
            return _tick;
        }
    }

    function getY(value) {
        return height * (range[0] - value) / (range[0] - range[1]) + topSpace;
    }

    function getValue(y) {
        return range[0] - (y - topSpace) * (range[0] - range[1]) / height;
    }
}
