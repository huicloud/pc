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

/**
 * k线和分时的画图区域，包含最底层的图形画板（Canvas），上层的光标画板(Canvas)以及最上层的标题栏(Item)和顶部标签页(Item)和图上的提示框(Item)
 */
ColumnLayout {
    id: root

    property var charts: {
        var charts = Array.prototype.filter.call(children, function(eachChild) {
            if (eachChild.objectName === 'chart' && eachChild.visible) {
                eachChild.showXAxis = false;
                return true;
            }
            return false
        });
        var lastChart = charts[charts.length - 1];
        if (lastChart) {
            lastChart.showXAxis = true;
        }
        return charts;
    }
    property int chartCount: root.charts.length
    property real chartHeightPer: root.height / (chartCount + 1)

    spacing: 0
}
