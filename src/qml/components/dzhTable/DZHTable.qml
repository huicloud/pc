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
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "../../controls"
import "../../core/data"
import "../../core"

ContextComponent {
    id: root

    width: 800
    height: 600

    focus: true

    property alias table: table
    property Component tableViewStyleComponent: tableViewStyle
    default property alias __columns: table.data

    property bool isMousePressAndHold: false  //滚动条是否在拖拽中，暂时用不到
    property int fixedColumnCount: 3          //前3列固定
    property int rowCount: 30                 //列表数据总行数
    property int visibleRowCount: Math.floor((tableRect.height - root.headerHeight) / root.__rowMinHeight); //可见区域列表行数
    property real rowHeight: (tableRect.height - root.headerHeight) / root.visibleRowCount  //行高
    property int headerHeight: theme.stockTableHeadHeight        //表头高度
    property int currentPageRowIndex: 0;                         //当前页索引
    property int currentColumnIndex: fixedColumnCount;           //当前可移动列的索引
    property int __rowMinHeight: theme.stockTableRowHeight       //最小行高

    property ListModel tableViewModel: stockListModel            //数据存储
    property int __delta: Qt.platform.os === 'osx' ? -15 : -120  //滚轮参数

    property int focusIndex: -1;    //focusobj的索引位置


    signal setRightSideBarVisible(bool isVisible)

    signal sortedByHeaderColumn(TableViewColumn column)          //排序信号
    signal activated(int row)                                    //双击 回车
    //    signal currentRowChanged(int currentRow)                     //当前行改变
    signal clicked(int row)                                      //单击
    //signal wheel(int pageRowIndex)                               //滚轮事件
    signal processSelectedEsc()                                    //处理有选中状态的ESC按键事件
    signal processNoSelectedEsc()                                  //处理没选中状态的ESC按键事件

    signal pageVisibleRowCountChanged(var visibleRowCount)       //可见区域行数变化的信号
    signal pageRowIndexChanged(var pageRowIndex)                 //当前页面索引变化的信号

    Rectangle{
        id: tableRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: vScrollBar.right
        anchors.bottom: hScrollBar.top
        focus: true
        color: "white"

        TableView {
            id: table
            anchors.fill: parent
            focus:true

            model: tableViewModel

            clip: true
            frameVisible: false
            sortIndicatorVisible: false
            backgroundVisible: false
            alternatingRowColors: false
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

            style: tableViewStyleComponent

            Component.onCompleted: {
                //此时才有列信息
                hScrollBar.recalcSilder()
            }
        }

        MouseArea{
            anchors.fill: parent
            anchors.topMargin: root.headerHeight
            hoverEnabled: true
            focus: false
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            propagateComposedEvents: true

            onWheel: {
                var newPageRowIndex = currentPageRowIndex
                var step = wheel.angleDelta.y / __delta;

                newPageRowIndex = newPageRowIndex + step
                if (newPageRowIndex < 0){
                    newPageRowIndex = 0
                    step = 1;
                } else if ((newPageRowIndex + visibleRowCount) >= rowCount){
                    newPageRowIndex = rowCount - visibleRowCount;
                    step = -1;
                }

                if (currentPageRowIndex !== newPageRowIndex){
                    currentPageRowIndex = newPageRowIndex
                }

                wheel.accepted = true
            }

            onClicked: {
                var selectedRowRelativeIndex = root.__doClick(mouse.y)

                if (selectedRowRelativeIndex === -1) return false;

                root.clicked(selectedRowRelativeIndex)

                mouse.accepted = false
            }

            onDoubleClicked: {
                var selectedRowRelativeIndex = root.__doClick(mouse.y)
                if (selectedRowRelativeIndex === -1) return false;
                root.activated(selectedRowRelativeIndex);
                mouse.accepted = true
            }
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
        anchors.bottomMargin: hScrollBar.height
        tableViewHolder: root
    }

    /*水平滚动条*/
    TableHScrollBar{
        id: hScrollBar
        height: 10
        width: parent.width - vScrollBar.width
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        tableViewHolder: root
    }

    /*右下角填充方块*/
    Rectangle{
        id: cornerRect
        color: theme.scrollbarBackgroundColor
        height: hScrollBar.height
        width: vScrollBar.width
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    //模型
    ListModel {
        id: stockListModel

        ListElement { XuHao:0; Obj:""; ZhongWenJianCheng:""; ZuiXinJia:""; ZhangDie:""; ZhangFu:""; ChengJiaoLiang:0; HuanShou:0; XianShou:0; ChengJiaoE:0; FenZhongZhangFu5:0; ZuoShou:0; KaiPanJia:0; ZuiGaoJia:0; ZuiDiJia:0; HangYe:""; ShiYingLv:0; ShiJingLv:0; ShiXiaoLv:0; WeiTuoMaiRuJia1:0; WeiTuoMaiChuJia1:0; NeiPan:0; WaiPan:0; ZhenFu:0; LiangBi:0; JunJia:0; WeiBi:0; WeiCha:0; ChengJiaoBiShu:0; ChengJiaoFangXiang:""; ZongShiZhi:0; LiuTongShiZhi:0;}

    }

    /*表格样式*/
    Component{
        id: tableViewStyle
        TableViewStyle {
            backgroundColor : theme.stockTableBorderColor

            headerDelegate: Rectangle{
                implicitHeight: root.headerHeight
                color : theme.stockTableBackGroundColor
                border.width : 1
                border.color : styleData.selected ? theme.stockTableBackGroundColor : Qt.lighter(theme.stockTableBorderColor,1.2)
                Text {
                    anchors.centerIn: parent
                    text: styleData.value
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        var column = control.getColumn(styleData.column);
                        if(column.sort) {
                            root.__sortedByHeaderColumn(column)
                        }
                    }
                }
            }

            rowDelegate: Rectangle {
                height: rowHeight
                color : theme.stockTableBackGroundColor
            }

            itemDelegate : DZHStockRectangle{
                implicitHeight: rowHeight
                color : styleData.selected ? theme.stockTableRowSelectColor : theme.stockTableRowNoSelectColor
                border.width : 1
                border.color : styleData.selected ? theme.stockTableRowNoSelectColor : Qt.lighter(theme.stockTableBorderColor,1.2)
                labelText: styleData.value ? styleData.value : ""
                zhangdie: (model&&model.ZhangDie) ? model.ZhangDie : 0
                zuixinjia: (model&&model.ZuiXinJia) ? model.ZuiXinJia : 0
                role: table.getColumn(styleData.column).role
            }
        }
    }

    /*键盘事件*/
    Keys.onPressed: {
        //上 下 左  右 控制表格 PageDown PageUp Home End 回车 Esc
        if (event.key === Qt.Key_Down) {
            incrementCurrentSelectedRowIndex()
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Up){
            decrementCurrentSelectedRowIndex()
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Left){
            __decrementCurrentColumnIndex()
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Right){
            __incrementCurrentColumnIndex()
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_PageDown){
            tableViewDeselectAll()
            __incrementCurrentPageRowIndex(visibleRowCount)
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_PageUp){
            tableViewDeselectAll()
            __decrementCurrentPageRowIndex(visibleRowCount)
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Escape){
            if (tableViewRowIsSelected()){
                tableViewDeselectAll()
                focusIndex = -1
                root.processSelectedEsc();
                event.accepted = true
            }else{
                root.processNoSelectedEsc();
                event.accepted = false
            }

            return
        }

        //回车
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
            if (tableViewRowIsSelected()){
                root.activated(focusIndex - currentPageRowIndex)
            }else{
                root.activated(-1)
            }
            return
        }
    }

    /*鼠标变化触发的信号*/
    onCurrentPageRowIndexChanged: {
        //当前页的索引变化，需要重新请求数据，可以优化方案；增加信号则可让使用放自定义逻辑
        reqData()

        vScrollBar.updateSliderPosition(currentPageRowIndex)

        //触发信号
        root.pageRowIndexChanged(currentPageRowIndex)
    }

    onCurrentColumnIndexChanged: {
        //当前可见列位置变化，需要更新滑块位置
        hScrollBar.updateSliderPosition(currentColumnIndex)
    }

    //    onFocusIndexChanged: {
    //        //选中行变化（绝对索引）
    //        root.currentRowChanged(focusIndex - currentPageRowIndex)
    //    }

    onRowCountChanged: {
        //总的行数变化，需要重新计算滑块大小
        vScrollBar.recalcSlider()
    }

    onVisibleRowCountChanged: {
        //可视区域 行的数量 变化

        //更新滑块大小
        vScrollBar.recalcSlider()
        var count = tableViewModel.count;
        if (visibleRowCount > count){
            for (var i = 0; i < (visibleRowCount - count); i++){
                tableViewModel.append({ Sort:0, Obj:"", ZhongWenJianCheng:"", ZuiXinJia:"", ZhangDie:"", ZhangFu:"", ChengJiaoLiang:0, HuanShou:0, XianShou:0 })
            }

            if (visible){
                reqData()
            }
        }

        root.pageVisibleRowCountChanged(visibleRowCount)
    }

    //点击事件
    function __doClick(mouseY){
        root.forceActiveFocus()

        //单选的情况
        var selectedRowRelativeIndex = Math.floor((mouseY) / rowHeight)
        if (selectedRowRelativeIndex >= tableViewModel.count)
            return -1

        if ((currentPageRowIndex + selectedRowRelativeIndex) <= rowCount){
            focusIndex = currentPageRowIndex + selectedRowRelativeIndex;
            tableViewSingleSelect(selectedRowRelativeIndex)

        }else {
            focusIndex = -1
            selectedRowRelativeIndex = -1
            tableViewDeselectAll();
        }
        return selectedRowRelativeIndex
    }

    //排序
    function __sortedByHeaderColumn(column){
        clearHeaderArrow()

        column.title = column.title + (column.desc?"↑":"↓");

        root.sortedByHeaderColumn(column);
        root.setRightSideBarVisible(false)
    }

    //清除表头箭头
    function clearHeaderArrow() {
        for (var i = 0 ; i < table.columnCount; i++) {
            var item = table.getColumn(i);
            item.title = item.title.replace(/["↑","↓"]/g,"")
        }
    }

    //横向左移
    function __decrementCurrentColumnIndex(){
        var newColumnIndex = currentColumnIndex
        newColumnIndex = newColumnIndex - 1

        hScrollBar.changeColumnIndex(newColumnIndex);
    }

    //横向右移
    function __incrementCurrentColumnIndex(){
        var newColumnIndex = currentColumnIndex
        newColumnIndex = newColumnIndex + 1

        hScrollBar.changeColumnIndex(newColumnIndex);
    }

    //当前选中项上移
    function decrementCurrentSelectedRowIndex(){
        var newFocusIndex;
        var relativeIndex;
        if (focusIndex === -1){
            //本身不可见时的情况
            newFocusIndex = currentPageRowIndex + visibleRowCount - 1
            if (newFocusIndex > rowCount - 1)
            {
                newFocusIndex = rowCount - 1
            }
            relativeIndex = newFocusIndex - currentPageRowIndex  //相对可视table的索引位置
            tableViewSingleSelect(relativeIndex)
            focusIndex = newFocusIndex

        }else if (focusIndex === 0){
            //列表第一个位置 不再上移
        }else{
            newFocusIndex = focusIndex - 1  //新焦点位置
            relativeIndex = newFocusIndex - currentPageRowIndex  //相对可视table的索引位置
            if (relativeIndex >= 0){
                tableViewSingleSelect(relativeIndex)
                focusIndex = newFocusIndex
            }else{
                //上移一行(页面索引变化)
                __decrementCurrentPageRowIndex(1)
                tableViewSingleSelect(0)
            }
        }
    }

    //当前选中项下移
    function incrementCurrentSelectedRowIndex(){
        var newFocusIndex;
        var relativeIndex;
        if (focusIndex === -1){
            focusIndex = currentPageRowIndex
            tableViewSingleSelect(0)
        }else if (focusIndex === rowCount - 1){
            //列表末尾不再移动
        }else{
            newFocusIndex = focusIndex + 1
            relativeIndex = newFocusIndex - currentPageRowIndex
            if (relativeIndex <= visibleRowCount - 1){
                console.log(focusIndex, relativeIndex, newFocusIndex, currentPageRowIndex, visibleRowCount)
                tableViewSingleSelect(relativeIndex)
                focusIndex = newFocusIndex
            }else {
                //下移一行(页面索引变化)
                __incrementCurrentPageRowIndex(1)
                tableViewSingleSelect(visibleRowCount-1)
            }
        }
    }

    //索引增加
    function __decrementCurrentPageRowIndex(step){
        if (step === 0) return;

        var newPageRowIndex = currentPageRowIndex;
        newPageRowIndex = newPageRowIndex - step

        vScrollBar.changePageRowIndex(newPageRowIndex)
    }

    //索引减小
    function __incrementCurrentPageRowIndex(step){
        if (step === 0) return;

        var newPageRowIndex = currentPageRowIndex;
        newPageRowIndex = newPageRowIndex + step

        vScrollBar.changePageRowIndex(newPageRowIndex)
    }

    //单行选中
    function tableViewSingleSelect(index){
        table.selection.clear();
        table.selection.select(index);
        focusIndex = currentPageRowIndex + index;
    }

    //单行取消选中
    function tableViewSingleDeselect(index){
        table.selection.deselect(index);
    }

    //全部取消中
    function tableViewDeselectAll(){
        table.selection.clear();
    }

    //判断当前是否用行被选中(是否在可视区域中)
    function tableViewRowIsSelected(){
        if ((focusIndex !== -1) &&( focusIndex >= currentPageRowIndex  && focusIndex <= currentPageRowIndex + visibleRowCount)){
            return true
        }else {
            return false
        }
    }

    //数据请求接口
    function reqData() {
        /*do nothing 需要子列表重载处理*/
    }

    function reset(){
        currentPageRowIndex = 0
        currentColumnIndex = fixedColumnCount
        focusIndex = -1

        table.selection.clear();
    }
}
