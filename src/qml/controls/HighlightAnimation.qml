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

import "../js/venders/bezier-easing.js" as BezierEasing

/**
 * 用于显示显示股票变化的高亮效果控件（使用定时器控制透明度变化）
 */
Timer {

    // 帧数（默认每秒16帧）
    property int frame: 16

    // 设置目标
    property var target

    // 动画渐变类型
    property int easingType: Easing.OutQuint

    property var easing: {
        switch(easingType) {
            case Easing.Linear: return BezierEasing.bezier(0, 0, 1, 1);
            case Easing.InQuint: return BezierEasing.bezier(0.755,  0.050, 0.855, 0.060);
            case Easing.OutQuint: return BezierEasing.bezier(0.230,  1.000, 0.320, 1.000);
            case Easing.InOutQuart: return BezierEasing.bezier(0.770,  0.000, 0.175, 1.000);
            case Easing.InOutQuint: return BezierEasing.bezier(0.860,  0.000, 0.070, 1.000);
            case Easing.InOutCirc: return BezierEasing.bezier(0.785,  0.135, 0.150, 0.860);
            case Easing.InOutBack: return BezierEasing.bezier(0.680, -0.550, 0.265, 1.550);

//                in-quad:      cubic-bezier(0.550,  0.085, 0.680, 0.530),
//                  in-cubic:     cubic-bezier(0.550,  0.055, 0.675, 0.190),
//                  in-quart:     cubic-bezier(0.895,  0.030, 0.685, 0.220),
//                  in-quint:     cubic-bezier(0.755,  0.050, 0.855, 0.060),
//                  in-sine:      cubic-bezier(0.470,  0.000, 0.745, 0.715),
//                  in-expo:      cubic-bezier(0.950,  0.050, 0.795, 0.035),
//                  in-circ:      cubic-bezier(0.600,  0.040, 0.980, 0.335),
//                  in-back:      cubic-bezier(0.600, -0.280, 0.735, 0.045),
//                  out-quad:     cubic-bezier(0.250,  0.460, 0.450, 0.940),
//                  out-cubic:    cubic-bezier(0.215,  0.610, 0.355, 1.000),
//                  out-quart:    cubic-bezier(0.165,  0.840, 0.440, 1.000),
//                  out-quint:    cubic-bezier(0.230,  1.000, 0.320, 1.000),
//                  out-sine:     cubic-bezier(0.390,  0.575, 0.565, 1.000),
//                  out-expo:     cubic-bezier(0.190,  1.000, 0.220, 1.000),
//                  out-circ:     cubic-bezier(0.075,  0.820, 0.165, 1.000),
//                  out-back:     cubic-bezier(0.175,  0.885, 0.320, 1.275),
//                  in-out-quad:  cubic-bezier(0.455,  0.030, 0.515, 0.955),
//                  in-out-cubic: cubic-bezier(0.645,  0.045, 0.355, 1.000),
//                  in-out-quart: cubic-bezier(0.770,  0.000, 0.175, 1.000),
//                  in-out-quint: cubic-bezier(0.860,  0.000, 0.070, 1.000),
//                  in-out-sine:  cubic-bezier(0.445,  0.050, 0.550, 0.950),
//                  in-out-expo:  cubic-bezier(1.000,  0.000, 0.000, 1.000),
//                  in-out-circ:  cubic-bezier(0.785,  0.135, 0.150, 0.860),
//                  in-out-back:  cubic-bezier(0.680, -0.550, 0.265, 1.550)
        }
    }

    // 动画时间（默认1秒）
    property int duration: 1000

    property real _linearOpacity: 0
    property real _fromOpacity: 1
    property real _toOpacity: 0
    property real _changeOpacityPer: (_toOpacity - _fromOpacity) * interval / duration

    running: target && target.visible ? target.opacity > 0 : false
    repeat: true

    interval: 1000 / frame

    onTriggered: {
        _linearOpacity = Math.max(0, _linearOpacity + _changeOpacityPer);
        target.opacity = easing(_linearOpacity);
    }

    onRunningChanged: {
        if (running === true) {
            _linearOpacity = target.opacity;
            _fromOpacity = target.opacity;
        }
    }

    function start() {
        if (target && target.visible) {
            target.opacity = _fromOpacity;
        }
    }

    function stop() {
        if (target) {
            target.opacity = _toOpacity;
        }
    }
}
