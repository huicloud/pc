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
    * @brief  VScrollBar 垂直滚动条
    * @author dongwei
    * @date   2016
    */

import QtQuick 2.0
import "../../core"

Rectangle {
    id: scrollbar

    color: theme.scrollbarBackgroundColor
    width: theme.tableScrollbarSize

    property var tableViewHolder: null
    property var theme: ThemeManager.currentTheme
    property real __sliderStep; //滑块每次移动触发行数变化的值
    property bool __canChangeYAxis: false   //非拖拽事件触发X轴变化事件

    MouseArea{
        anchors.fill: parent
        onClicked: {
            __canChangeYAxis = true
            slider.y = mouse.y - slider.height/2
        }
    }

    Rectangle {
        id: slider
        width: parent.width
        height: {
            return calcSliderHeiht()
        }

        color: theme.scrollbarSliderColor
        radius: slider.width
        border {
            width: 1
            color: theme.scrollbarSliderBorderColor
        }

        MouseArea {
            id: dragger
            anchors.fill: parent
            drag {
                target: slider
                minimumX: slider.x
                maximumX: slider.x
                minimumY: 0
                maximumY: (scrollbar.height - slider.height)
                axis: Drag.YAxis
            }

            onPressed: {
                //计算可以拖动区域
                tableViewHolder.isMousePressAndHold = true
                //slider.width = calcSliderWidth()
            }

            onReleased: {
                tableViewHolder.isMousePressAndHold = false
            }
        }

        onYChanged: {
            if (dragger.drag.active || __canChangeYAxis){
                __canChangeYAxis = false
                if (slider.y < 0){
                    slider.y = 0
                }else if ((slider.y + slider.height) > parent.height){
                    slider.y = Math.max(0, parent.height - slider.height)
                }
                var newPageRowIndex = 0
                if (__sliderStep === 0)
                    newPageRowIndex = 0
                else
                    newPageRowIndex = Math.floor(slider.y / __sliderStep)

                changePageRowIndex(newPageRowIndex)
            }
        }
    }

    onHeightChanged: {
        recalcSlider()
    }

    function changePageRowIndex(index){
        if (index < 0){
            index = 0
        } else if ((index + tableViewHolder.visibleRowCount) >= tableViewHolder.rowCount){
            index = tableViewHolder.rowCount - tableViewHolder.visibleRowCount;
        }

        //更新索引
        if (tableViewHolder.currentPageRowIndex !== index){
            tableViewHolder.currentPageRowIndex = index
        }
    }

    function updateSliderPosition(tableViewCurrentPageRowIndex){
        if (!dragger.drag.active){
            var sliderPosition = tableViewCurrentPageRowIndex * __sliderStep
            if (sliderPosition > (scrollbar.height - slider.height)){
                sliderPosition = scrollbar.height - slider.height
            }
            slider.y = sliderPosition
        }
    }

    function calcSliderHeiht(){
        var sliderHeight = 0
        if (tableViewHolder.rowCount > tableViewHolder.visibleRowCount){
            sliderHeight = scrollbar.height / (tableViewHolder.rowCount - tableViewHolder.visibleRowCount)
        } else {
            sliderHeight = scrollbar.height
        }
        return Math.max(20, sliderHeight)
    }

    function recalcSlider(){

        slider.height = calcSliderHeiht()

        if (tableViewHolder.rowCount > tableViewHolder.visibleRowCount){
            __sliderStep = (scrollbar.height - slider.height) / (tableViewHolder.rowCount - tableViewHolder.visibleRowCount);
        } else {
            __sliderStep = 0
        }
        var sliderPosition = tableViewHolder.currentPageRowIndex * __sliderStep
        if (sliderPosition > (scrollbar.height - slider.height)){
            sliderPosition = scrollbar.height - slider.height
        }else if (sliderPosition < 0)
            sliderPosition = 0

        slider.y = sliderPosition
    }
}
