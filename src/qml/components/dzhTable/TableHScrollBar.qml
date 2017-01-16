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
    * @brief  HScrollBar 水平滚动条
    * @author dongwei
    * @date   2016
    */

import QtQuick 2.0
import "../../core"

Rectangle {
    id: scrollbar

    property var tableViewHolder: null

    property real __sliderStep; //滑块每次移动触发列数变化的值
    property int __unVisibleColumnCount: 0
    property bool __canChangeXAxis: false   //非拖拽事件触发X轴变化事件
    color: theme.scrollbarBackgroundColor
    height: theme.tableScrollbarSize

    MouseArea{
        anchors.fill: parent
        onClicked: {
            __canChangeXAxis = true
            slider.x = mouse.x - slider.width / 2
        }
    }
    Rectangle {
        id: slider
        height: parent.height
        width: 20
        color: theme.scrollbarSliderColor
        radius: slider.height
        border {
            width: 1
            color: theme.scrollbarSliderBorderColor
        }

        MouseArea {
            id: dragger
            anchors.fill: parent
            drag {
                target: slider
                minimumX: 0
                maximumX: (scrollbar.width - slider.width)
                minimumY: slider.y
                maximumY: slider.y
                axis: Drag.XAxis
            }

            onPressed: {
                //计算可以拖动区域
                console.log("dddd")
                tableViewHolder.isMousePressAndHold = true
                //slider.width = calcSliderWidth()
            }

            onReleased: {
                tableViewHolder.isMousePressAndHold = false
            }
        }

        onXChanged: {
            if (dragger.drag.active || __canChangeXAxis){
                __canChangeXAxis = false
                var newColumnIndex = 0
                if (slider.x < 0)
                    slider.x = 0
                else if ((slider.x + slider.width) > parent.width)
                    slider.x = Math.max(0, parent.width - slider.width)

                if (__sliderStep === 0){
                    newColumnIndex  = tableViewHolder.fixedColumnCount
                }else{
                    newColumnIndex = tableViewHolder.fixedColumnCount + Math.floor(slider.x / __sliderStep)
                }

                changeColumnIndex(newColumnIndex)
            }
        }
    }
    onWidthChanged: {
        if (tableViewHolder.table.columnCount === 0)
            return

        recalcSilder()
    }

    function calcSliderWidth(){
        var sliderWidth = 0  //滑块的宽度
        var visibleColumnCount = 0 //完整可见的数量
        var visibleTableWidth = parent.width// - tableViews.fixedColumnsTable.width //可见区域总宽度
        var visibleColumnWidth = 0  //可见列累计宽度

        for(var i = 0; i < tableViewHolder.table.columnCount; i++){
            visibleColumnWidth = visibleColumnWidth + tableViewHolder.table.getColumn(i).width
            if (visibleColumnWidth > visibleTableWidth){
                break;
            }
            visibleColumnCount = i + 1;
        }

        //不可见数量
        __unVisibleColumnCount  = tableViewHolder.table.columnCount - visibleColumnCount
        console.log('__unVisibleColumnCount', __unVisibleColumnCount)
        if (__unVisibleColumnCount > 0){
            sliderWidth = scrollbar.width / __unVisibleColumnCount
        } else {
            sliderWidth = scrollbar.width
        }

        return Math.max(20, sliderWidth)
    }

    function updateSliderPosition(tableViewCurrentColumenIndex){
        if (!dragger.drag.active){
            var sliderPosition = (tableViewCurrentColumenIndex - tableViewHolder.fixedColumnCount)* __sliderStep  //可见列累计宽度
            if (sliderPosition > (scrollbar.width - slider.width)){
                sliderPosition = scrollbar.width - slider.width
            }
            slider.x = sliderPosition
        }
    }

    function changeColumnIndex(index){
        if (index < tableViewHolder.fixedColumnCount)
            index = tableViewHolder.fixedColumnCount

        if (index > tableViewHolder.fixedColumnCount + hScrollBar.__unVisibleColumnCount)
            index = tableViewHolder.fixedColumnCount + hScrollBar.__unVisibleColumnCount

        if ( tableViewHolder.currentColumnIndex !== index){
            tableViewHolder.currentColumnIndex = index;

            //var moveX = 0
            for (var i = fixedColumnCount; i < index; i++)
            {
                tableViewHolder.table.getColumn(i).visible = false;
            }
            for (var i = index; i < tableViewHolder.table.columnCount; i++){
                tableViewHolder.table.getColumn(i).visible = true;
            }

            //tableViews.table.__listView.contentX = moveX
        }
    }

    function recalcSilder(){
        slider.width = calcSliderWidth()

        if (__unVisibleColumnCount > 0){
            __sliderStep = (scrollbar.width - slider.width) / __unVisibleColumnCount
        } else {
            __sliderStep = 0
        }

        var sliderPostion = (tableViewHolder.currentColumnIndex - tableViewHolder.fixedColumnCount) * __sliderStep
        if (sliderPostion > (scrollbar.width - slider.width)){
            sliderPostion = (scrollbar.width - slider.width)
        } else if (sliderPostion < 0){
            sliderPostion = 0
        }
        slider.x = sliderPostion
    }
}
