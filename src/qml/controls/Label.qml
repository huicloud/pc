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
  * @brief  Label
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import "./"

Text {
    id: textFormatter
    width: 60
    height: 20
    property string unit: ''  //''|'100'|'10000'|'K'|'M'|'B'|'K/M'|'K/M/B'|'万'|'亿'|'万/亿'|'%'
    property int precision: 2 //精度
    property bool isAutoPrec: false  //是否自动进行精度控制，true时 对于不到单位转换的情况时直接取整

    property real value          //需要格式化的数据
    property bool hasSign: false //是否显示正负号
    property bool isAbs: false   //是否显示绝对值 如-20显示为20

    property bool isAutoFormat: false //是否自动配色
    property real baseValue: 0        //基础值
    property color normalColor: theme.normalColor  //默认颜色
    property color upColor: theme.redColor         //大于0时的值的颜色
    property color downColor: theme.greenColor     //小于0时的值的颜色
    property bool hasSuffix: false    //是否有↑↓箭头的后缀

    property string defaultText: "--" //为空或者数据为0时的默认显示

    /*
       Text基本属性
    */
    //fontSizeMode: Text.HorizontalFit //宽度适应
    elide: Text.ElideRight
    //horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    text: {
        return formatText()
    }

    //onValueChanged: {
    //    text = formatText()
    //}

    function formatText() {

        if ((isNaN(value)) && defaultText !== "") {
            color = normalColor
            return defaultText
        }

        var sign = ''
        if (hasSign && value >= 0) {
            sign = '+'
        }

        var suffix = ''
        if (isAutoFormat) {
            if ((value - baseValue) >= 1e-6) {
                color = upColor
                if (hasSuffix){
                    suffix = '↑'
                }
            } else if ((value - baseValue) <= -(1e-6)) {
                color = downColor
                if (hasSuffix){
                    suffix = '↓'
                }
            } else {
                color = normalColor
            }
        } else {
            color = normalColor
        }

        var precision = textFormatter.precision >= 0 ? textFormatter.precision : 2

        var transformUnit = ''
        var transformValue =  value
        var absValue = Math.abs(value)
        if (unit.indexOf('B') >= 0 && absValue >= 1000 * 1000 * 1000) {
            transformUnit = 'B'
            transformValue = value / (1000 * 1000 * 1000)
        } else if (unit.indexOf('亿') >= 0 && absValue >= 10000 * 10000) {
            transformUnit = '亿'
            transformValue = value / (10000 * 10000)
        } else if (unit.indexOf('M') >= 0 && absValue >= 1000 * 1000) {
            transformUnit = 'M'
            transformValue = value / (1000 * 1000)
        } else if (unit.indexOf('万') >= 0 && absValue >= 10000) {
            transformUnit = '万'
            transformValue = value / 10000
        } else if (unit.indexOf('K') >= 0 && absValue >= 1000) {
            transformUnit = 'K'
            transformValue = value / 1000
        } else if (unit === 10000) {
            transformUnit = ''
            transformValue = value / 10000
        } else if (unit === 100) {
            transformUnit = ''
            transformValue = value / 100
        } else if (unit === '%') {
            transformUnit = unit
            transformValue = value * 100
        } else {
            transformUnit = ''
        }

        if (isAbs){
            transformValue = Math.abs(transformValue)
        }

        if (isAutoPrec && (transformValue === value)){
            //当值未被进行格式化时，不经心精度转化
            return sign + transformValue + transformUnit + suffix
        }else{
            return sign + transformValue.toFixed(precision) + transformUnit + suffix
        }
    }
}
