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

import "./"
import "../core"
import "../controls"

ContextComponent {
    id: root

    focusAvailable: false

    property int fontSize: theme.chartFontSize
    property string fontFamily: theme.chartFontFamily
    property string fontStyle: [fontSize, 'px ', '"', fontFamily, '"'].join('')
    property color upColor: theme.chartUpColor
    property color downColor: theme.chartDownColor
    property color textColor: theme.chartTextColor
    property int defaultLineWidth: theme.chartDefaultLineWidth

    property int gridLineWidth: theme.chartGridLineWidth
    property color gridLineColor: theme.chartGridLineColor
    property color tickColor: theme.chartTickColor
    property string tickFontFamily: theme.chartTickFontFamily
    property int tickFontSize: theme.chartTickFontSize
    property string tickFontStyle: [tickFontSize, 'px ', '"', tickFontFamily, '"'].join('')

    // 直接引用到外层的Canvas
    property var canvas: _canvas

    // 由外部数据处理后用于画图用数据（画图使用对应的点和颜色数据，每次重绘时判断是否需要重新计算）
    property var figureData: []

    property bool isDirty: false

    property int redrawCount: 0

    function redraw() {
        if (!visible || redrawCount === canvas.redrawCount) {
            return;
        }
        redrawCount = canvas.redrawCount;

        if (isDirty) {
            _redraw();
            isDirty = false;
        } else {

            // 将chartData中对应数据按顺序画到画板上
            figureData.forEach(function(eachFigure) {

                // 使用canvas（在外部作用范围中能找到的画板对象，注意从Chart到Canvas的范围中不要重定义canvas这个id的对象）
                canvas.draw(eachFigure);
            });
        }
    }

    // 计算对应的图形的数据，缓存后画出来
    function _redraw() {}
}
