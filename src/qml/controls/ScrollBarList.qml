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

import QtQuick 2.4
import QtQuick.Layouts 1.1

import './'
import '../core'
import '../core/data'
import '../components/dzhTable'
import '../js/DateUtil.js' as DateUtil

ContextComponent {
    id: root
    width: 300
    height: 100

    property bool isMousePressAndHold: false                                //滚动条是否在拖拽中，暂时用不到
    property int rowCount: model.length                                     //列表数据总行数
    property int visibleRowCount: Math.floor(root.height / root.rowHeight); //可见区域列表行数
    property int rowHeight:  30;                                 //行高
    property int currentPageRowIndex: 0;                         //当前页索引
    property int __delta: Qt.platform.os === 'osx' ? -2 : -120  //滚轮参数
    property bool canLoadMore: false                             //是否还能请求, 暂时不适用此功能
    property bool isLoading: false                               //是否在请求过程中

    property bool highlightOnFocus: false                        //获取焦点是否高亮

    property alias listView: listView

    property var focusData;                                      //当前选中项高亮

    signal itemClick(var itemData, int index)

    property var model:[]
    property Component delegate

    Rectangle{
        id: listViewRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: vScrollBar.right
        anchors.bottom: parent.bottom
        focus: true
        color: "white"

        ListView {
            id: listView
            interactive: false
            anchors.fill: parent
            anchors.rightMargin: vScrollBar.width
            currentIndex: -1

            delegate: root.delegate
            model: root.model
        }
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        focus: false
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        propagateComposedEvents: true
        property var recordTime
        onWheel: {
            if (!isLoading){

                var newPageRowIndex = currentPageRowIndex;
                var step;

                if (wheel.angleDelta.y === 0) return;
                var currentTime =  new Date().getTime();

                if (currentTime - recordTime <= 60) return;

                recordTime = currentTime;

                if (Math.abs(wheel.angleDelta.y) >=120){
                    step =  wheel.angleDelta.y / -120;
                }else{
                    step = (wheel.angleDelta.y / __delta);
                }
               if (step > 0){
                   step = Math.floor(step);
               }else{
                   step = Math.ceil(step);
               }

                newPageRowIndex = newPageRowIndex + step

                if (newPageRowIndex < 0){
                    newPageRowIndex = 0
                } else if ((newPageRowIndex + visibleRowCount) > rowCount){
                    newPageRowIndex = rowCount - visibleRowCount;
                    if (root.canLoadMore){
                        //加载更多
                        __loadMore();
                        exit;
                    }
                }

                if (currentPageRowIndex !== newPageRowIndex){
                    currentPageRowIndex = newPageRowIndex
                }
            }

            wheel.accepted = true
        }

        onClicked: {
            var selectedRowRelativeIndex = root.__doClick(mouse.y)

            listView.currentIndex = selectedRowRelativeIndex;
            //root.currentIndex = selectedRowRelativeIndex;

            if (selectedRowRelativeIndex !== -1){
                focusData = model[selectedRowRelativeIndex];
                root.itemClick(focusData, selectedRowRelativeIndex);
            }

            mouse.accepted = false
        }

        onDoubleClicked: {
            var selectedRowRelativeIndex = root.__doClick(mouse.y)

            listView.currentIndex = selectedRowRelativeIndex;
            //root.currentIndex = selectedRowRelativeIndex;

            if (selectedRowRelativeIndex !== -1){
                focusData = model[selectedRowRelativeIndex];
                root.itemClick(focusData, selectedRowRelativeIndex);
            }
            mouse.accepted = true
        }
    }


    /*垂直滚动条*/
    TableVScrollBar{
        id: vScrollBar
        height: parent.height
        width: 10
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        tableViewHolder: root
    }

    onCurrentPageRowIndexChanged: {
        listView.positionViewAtIndex(currentPageRowIndex, ListView.Beginning);
        vScrollBar.updateSliderPosition(currentPageRowIndex);
    }

    onRowCountChanged: {
        //总的行数变化，需要重新计算滑块大小
        vScrollBar.recalcSlider();
    }

    onVisibleRowCountChanged: {
        //更新滑块大小
        vScrollBar.recalcSlider()
    }

    //点击事件
    function __doClick(mouseY){

        //单选的情况
        var focusIndex = -1;
        var selectedRowRelativeIndex = Math.floor((mouseY) / rowHeight);
        if (selectedRowRelativeIndex >= model.length)
            return focusIndex;

        if ((currentPageRowIndex + selectedRowRelativeIndex) <= rowCount){
            focusIndex = currentPageRowIndex + selectedRowRelativeIndex;
        }else {
            focusIndex = -1
        }

        return focusIndex
    }

    //数据请求接口
    function reqData() {
        /*do nothing 需要子列表重载处理*/
    }

    //加载更多[暂时不使用]
    function __loadMore(){

        var loadMoreCallback = function(dataCount, hasMoreData){
            if (dataCount > 0){
                //listView.currentIndex = root.currentIndex; //先置索引，再定位
                //currentPageRowIndex = currentPageRowIndex + 1;
            }

            canLoadMore = hasMoreData;
            isLoading = false;
        }

        canLoadMore = false;
        isLoading = true;

        //具体加载逻辑
        doLoadMore(loadMoreCallback);
    }

    function doLoadMore(callback){
        /*do nothing 需要子列表重载处理*/
        /*root.model = root.model.concat([])
        if (typeof callback === 'function'){
            callback(5, false)
        }*/
    }

}
