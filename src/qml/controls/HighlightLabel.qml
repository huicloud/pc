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

/**
  * @brief  HighlightLabel
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0

Rectangle {
    id: highlightRect
    border.color: "red"
    border.width: 1
    color: "transparent"

    width: 60
    height: 20

    property bool isAutoHighlight: true
    property int duration: 1000
    property color highlightColor: "blue"
    property alias labelAnchors: label.anchors
    property alias unit: label.unit              //''|'100'|'10000'|'K'|'M'|'B'|'K/M'|'K/M/B'|'万'|'亿'|'万/亿'|'%'}
    property alias precision: label.precision    //精度

    property alias value: label.value            //需要格式化的数据
    property alias hasSign: label.hasSign        //是否显示正负号
    property alias isAbs: label.isAbs            //是否显示绝对值 如-20显示为20
    property alias isAutoFormat: label.isAutoFormat //是否自动配色
    property alias baseValue: label.baseValue       //基础值
    property alias normalColor: label.normalColor   //默认颜色
    property alias upColor: label.upColor           //大于0时的值的颜色
    property alias downColor: label.downColor       //小于0时的值的颜色
    property alias hasSuffix: label.hasSuffix       //是否有↑↓箭头的后缀

    property alias defaultText: label.defaultText    //为空或者数据为0时的默认显示

    property alias fontSizeMode: label.fontSizeMode
    property alias elide: label.elide
    property alias horizontalAlignment: label.horizontalAlignment
    property alias verticalAlignment: label.verticalAlignment

    onValueChanged: {
        if (isAutoHighlight) {
            showHighlight()
        }
    }

    Label {
        id: label
        anchors.centerIn: parent
        value: 0
    }

    ColorAnimation {
        id: colorAnimation
        target: highlightRect
        property: "color"
        from: highlightRect.highlightColor
        to: highlightRect.color
        duration: highlightRect.duration
    }

    //手动激活动画
    function showHighlight(){
        colorAnimation.start()
    }
}
