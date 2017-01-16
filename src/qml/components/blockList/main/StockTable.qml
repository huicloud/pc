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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import QtQml.Models 2.2
import "../../../core"
import "../../../components"
import "../../../core/common"
import "../../../controls"
import "../../../core/data"
import "../../../util"
import "../../../js/Util.js" as Util

/*
 *  股票列表Table组件
 *  author: lvyue
 */
BaseComponent {
    id : blockTableView
    focus:true

    clip: true
    property var headTitle: ({})
    property QtObject appConfig:ApplicationConfigure

    property var backColor: [theme.stockTableRowNoSelectColor,theme.stockTableChildRowBackGroundColor]

    property var startPos:0;//视图展示第一行元素序号
    property var viewShowData:showCount;
    property var endPos:startPos+showCount;//视图展示最后一行序号，该行数据可能显示不全


    property string market:"31"
    property string obj: "";//板块指数obj，改变时会触发绑定的板块查询
    property string currObj: focusobjParam;//板块指数obj，改变时会触发绑定的板块查询

    property string expandObj:"";//当前展开的股票obj
    property int expandStkPos: -1; //展开股票的位置
    property int allBlockStkCount: 0; //索引板块股票的个数
    property int expandStkChengFenGuCout: 0; //展开股票成分股个数
    property int expandStkChengFenGuIsUpdate: -1; //展开股票成分股个数

    property int isUpdateObjIndex: 0; //展开股票成分股个数
    property int isFirstUpdateChengFenGu: 0; //是否是第一次更新成分股数据
    property int isUpdateViewRightNowParent: 0; //是否立刻更新视图
    property int isUpdateViewRightNowChild: 0; //是否立刻更新视图
    property int updateViewRightNowMax: 10; //是否立刻更新视图

    property var stock: BlockUtil.blockName.createObject(blockTableView);

    property var batchReq;  //批量订阅行情的请求，用于取消上一次订阅
    property var batchReqBlock;  //批量订阅板块成分股行情的请求，用于取消上一次订阅
    property var quoteBlockParam : ({
                                   field: "ZhongWenJianCheng,ZuiXinJia,ZhangDie,ZhangFu,ChengJiaoLiang,HuanShou,ChengJiaoE,ShiYingLv,ShiJingLv,WeiTuoMaiRuJia1,WeiTuoMaiChuJia1,ZhenFu,LiangBi,ZongShiZhi,LiuTongShiZhi"
                               });
    property var quoteParam : ({
                                   field: "ZhongWenJianCheng,ZuiXinJia,ZhangDie,ZhangFu,ChengJiaoLiang,HuanShou,ChengJiaoE,FenZhongZhangFu5,ZuoShou,KaiPanJia,ZuiGaoJia,ZuiDiJia,ShiYingLv,ShiJingLv,WeiTuoMaiRuJia1,WeiTuoMaiChuJia1,NeiPan,WaiPan,ZhenFu,LiangBi,JunJia,WeiBi,WeiCha,ZongShiZhi,LiuTongShiZhi"
                               });
    //property var fields: "ZhongWenJianCheng,ZuiXinJia,ZhangDie,ZhangFu,ChengJiaoLiang,HuanShou,XianShou,ChengJiaoE,FenZhongZhangFu5,ZuoShou,KaiPanJia,ZuiGaoJia,ZuiDiJia,ShiYingLv,ShiJingLv,WeiTuoMaiRuJia1,WeiTuoMaiChuJia1,NeiPan,WaiPan,ZhenFu,LiangBi,JunJia,WeiBi,WeiCha,ZongShiZhi,LiuTongShiZhi";
    property var currObjIndex: ({}); //最新的code与index的映射
    property var lastObjIndex: ({}); //记录上一次的code与index的映射
    //成分股数据
    property var currBlockObjIndex: ({}); //板块成分股最新的code与index的映射
    property var lastBlockObjIndex: ({}); //板块成分股记录上一次的code与index的映射

    property int firstResponseDataIndex: 0; //返回数据中第一条的索引
    property int firstResponseDataIndexBlock: 0; //返回数据中第一条的索引

    /*start 全局的请求参数 start开始索引 orderBy排序 desc逆序或者正序*/
    property int startParam: 0;
    property int startParamChild: 0;
    property int countParam: Math.ceil((Screen.height-headHeight)/rowHeight) * 3;
    property string orderByParam: "ZhangFu";
    property bool descParam: true;
    property string focusobjParam: "";
    property int focusobjColumn: 0;
    property int focusobjRow: -1;
    property int focusobjRowLast: -1;
    /*  end 全局的请求参数 */

    //property string market: "31";
    property var blockObjData;

    property bool isAutoUpdateByTimer: false;//是否需要定时器自动刷新界面
    property bool isUpdateCacheLast: true;//滚动，键盘操作时，设置为true，此时数据变化不高亮显示

    function getGqlByMarket(m) {
        var gqlParam = "B$";
        switch(m) {
        case "31": { gqlParam = "B$"; break; }
        }

        return gqlParam;
    }

    //板块数据请求模块
    property DataProvider dp: DataProvider {  //排序数据源
        serviceUrl: "/stkdata"
        params: ({
                     //gql: "block=股票\\\\市场分类\\\\全部A股",
                     market:getGqlByMarket(market),
                     mode: 2, //2表示每5秒推一次
                     //start: startParam,
                     //count: countParam,
                     field: "ZhongWenJianCheng,ZhangFu",
                     //field: fields,
                     desc: descParam,
                     orderby: orderByParam,
                     //focus: blockTableView.focusobjParam
                 });
        sub: 1;
        direct: true;
        autoQuery: false;
    }

    //板块成分股数据请求模块
    property DataProvider dpBlock: DataProvider {  //排序数据源
        serviceUrl: "/stkdata"
        params: ({
                     //gql: "block=股票\\\\市场分类\\\\全部A股",
                     gql: 'block=' + stock.fullName,
                     mode: 2, //2表示每5秒推一次
                     //start: startParam,
                     //count: showCount,
                     //field: "ZhongWenJianCheng,ZhangFu",
                     field: quoteParam,
                     desc: descParam,
                     orderby: orderByParam,
                     //focus: focusobjParam
                 });
        sub: 1;
        direct: true;
        autoQuery: true;

        onSuccess: {
            console.log("收到成分股数据："+printTime()+stock.fullName);

            reqBlockData(data);
            blockObjData = data;
        }
    }

    property int rowHeight: theme.stockTableRowHeight
    property int headHeight: theme.stockTableHeadHeight

    signal sortedByHeaderColumn(int column)
    signal setRightSideBarVisible(bool isVisible)
    signal rowClicked(int row)
    signal activePage()
    signal deActivePage()
    signal activatedToDetail(int row,int column)
    signal clickedRow(int row,int column)

    function createColumn(field, title, width, fixed,desc) {
        return {field: field, title: title, width: width || 100, fixed: fixed || false,desc:desc};
    }
    // 全部要显示的字段
    property var _columns: [
        createColumn('Head', '', 30, true, false),
        createColumn('XuHao', '序号', 50, true, false),
        createColumn('Obj', '代码', null, true, false),
        createColumn('ZhongWenJianCheng', '名称', 100, true, false),
        createColumn('ZuiXinJia', '最新', 100, false, false),
        createColumn('ZhangDie', '最新', 100, false, false),
        createColumn('ZhangFu', '最新', 100, false, true),
        createColumn('ChengJiaoLiang', '最新', 100, false, false),
        createColumn('HuanShou', '最新', 100, false, false),
        createColumn('XianShou', '最新', 100, false, false),
        createColumn('ChengJiaoE', '最新', 100, false, false),
        createColumn('FenZhongZhangFu5', '最新', 100, false, false),
        createColumn('ZuoShou', '最新', 100, false, false),
        createColumn('KaiPanJia', '最新', 100, false, false),
        createColumn('ZuiGaoJia', '最新', 100, false, false),
        createColumn('ZuiDiJia', '最新', 100, false, false),
        createColumn('HangYe', '最新', 100, false, false),
        createColumn('ShiYingLv', '最新', 100, false, false),
        createColumn('ShiJingLv', '最新', 100, false, false),
        createColumn('ShiXiaoLv', '最新', 100, false, false),
        createColumn('WeiTuoMaiRuJia1', '最新', 100, false, false),
        createColumn('WeiTuoMaiChuJia1', '最新', 100, false, false),
        createColumn('NeiPan', '最新', 100, false, false),
        createColumn('WaiPan', '最新', 100, false, false),
        createColumn('ZhenFu', '最新', 100, false, false),
        createColumn('LiangBi', '最新', 100, false, false),
        createColumn('JunJia', '最新', 100, false, false),
        createColumn('WeiBi', '最新', 100, false, false),
        createColumn('WeiCha', '最新', 100, false, false),
//        createColumn('ChengJiaoBiShu', '最新', 100, false, false),
//        createColumn('ChengJiaoFangXiang', '最新', 100, false, false),
        createColumn('ZongShiZhi', '最新', 100, false, false),
        createColumn('LiuTongShiZhi', '最新', 100, false, false)
    ]

    property var columnCount:_columns.length
    // 需要查询的字段
    property var fields: _columns.map(function(eachColumn) { return eachColumn.field }).filter(function(field) {return field !== 'Head' && field !== 'Obj' && field !== 'XuHao'})

    // 总宽度
    property real contentWidth: _columns.reduce(function(preValue, eachColumn){ return preValue +  eachColumn.width }, 0)

    property real contentFixedWidthInView:  _columns.reduce(function(preValue, eachColumn){ return preValue + (eachColumn.fixed ? eachColumn.width : 0) }, 0)

    // 需要展示的列，根据宽度计算出（前几列固定）
    property var columns: {
        var width = root.width + 110;
        //var offsetWidth = _flicker.visibleArea.xPosition * contentWidth;
        var offsetWidth = 0;
        console.log("columns change:",printTime());
        return _columns;
//        return _columns.filter(function(eachColumn) {
//            if (eachColumn.fixed) {
//                width -= eachColumn.width;
//                return true;
//            } else if (offsetWidth > eachColumn.width ) {
//                offsetWidth -= eachColumn.width;
//                return false;
//            }
//            width -= eachColumn.width;
//            return width >= 0;
//        });
    }

    // 最后一次请求行情数据的缓存（第一次请求到行情数据后清除并且更新数据，之后推送则只更新数据）
    property var cache: []
    property var cacheLast: []
    property var cacheHead: []
    property bool isLighterChangeItem: false

    property real contentHeight: rowHeight * (allBlockStkCount + expandStkChengFenGuCout + 1)
    property int showCount: Math.floor(height / rowHeight)

    property var modelHead: {
        if(!headTitle.hasOwnProperty("XuHao")){
            headTitle.Color = 0;
            headTitle.Head = "  ";
            headTitle.XuHao = "序号";
            headTitle.Obj = "代码";
            headTitle.ZhongWenJianCheng = "名称";
            headTitle.ZuiXinJia = "最新";
            headTitle.ZhangDie = "涨跌";
            headTitle.ZhangFu = "涨幅%↓";
            headTitle.ChengJiaoLiang = "总手";
            headTitle.HuanShou = "换手率%";
            headTitle.XianShou = "现手";
            headTitle.ChengJiaoE = "总额";
            headTitle.FenZhongZhangFu5 = "涨速";
            headTitle.ZuoShou = "昨收";
            headTitle.KaiPanJia = "今开";
            headTitle.ZuiGaoJia = "最高";
            headTitle.ZuiDiJia = "最低";
            headTitle.HangYe = "行业";
            headTitle.ShiYingLv = "市盈率";
            headTitle.ShiJingLv = "市净率";
            headTitle.ShiXiaoLv = "市销率";
            headTitle.WeiTuoMaiRuJia1 = "委买价";
            headTitle.WeiTuoMaiChuJia1 = "委卖价";
            headTitle.NeiPan = "内盘";
            headTitle.WaiPan = "外盘";
            headTitle.ZhenFu = "振幅";
            headTitle.LiangBi = "量比";
            headTitle.JunJia = "均价";
            headTitle.WeiBi = "委比";
            headTitle.WeiCha = "委差";
            headTitle.ChengJiaoBiShu = "成交笔数";
            headTitle.ChengJiaoFangXiang = "成交方向";
            headTitle.ZongShiZhi = "总市值";
            headTitle.LiuTongShiZhi = "流通市值";
        }
        return headTitle;
    }

    //行数据对应的model
    property var model: {
        // 填上行情数据
        return cache;
    }

    Flickable {
        id: _flicker
        pixelAligned:true
        anchors.fill: parent
        contentHeight: parent.contentHeight
        contentWidth: parent.contentWidth

        onContentYChanged: {
            var newPos = 0;
            if(_flicker.visibleArea.yPosition > 0){
                newPos = parseInt(_flicker.visibleArea.yPosition * (allBlockStkCount + expandStkChengFenGuCout)) + 1;
            }
            startPos = newPos;

            viewShowData = showCount;
            endPos = startPos + viewShowData;
            isUpdateCacheLast = true;
            updateShowDataInView();
        }

        onContentXChanged: {

            var lastContentX = (moveableColumnCurrent-moveableColumnStart)*moveableColumnStep;
            var direction = _flicker.contentX - lastContentX;
            var changeX = parseInt(direction/moveableColumnStep);


            console.log("onContentXChanged",moveableColumnCurrent,_flicker.contentX,changeX);
            if(direction > 0){
                //右滑动
                for(var j = 0; j < changeX; j++){
                    if(moveableColumnCurrent < moveableColumnMax){
                        for(var i = 0;i < container.children.length;i++){
                            container.children[i].children[moveableColumnCurrent].visible = false;
                        }
                        moveableColumnCurrent++;
                    }
                }
            } else {
                //左滑动
                changeX = 0 - changeX;
                for(j = 0; j < changeX; j++){
                    if(moveableColumnCurrent > moveableColumnStart){
                        moveableColumnCurrent--;
                        for(i = 0;i < container.children.length;i++){
                            container.children[i].children[moveableColumnCurrent].visible = true;
                        }
                    }
                }
            }

        }
    }

    Component {
        id: rowComponent
        RowLayout {
            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.maximumHeight: 50
            height: rowHeight
            spacing:0
            //Layout.alignment: Qt.AlignTop
            property int rowIndex
            property var isSelected:false
            property var rowData: ({})
            Repeater {
                id:rowColumns
                model: blockTableView.columns
                StockRectangle{
                    id:columnNoDealMouse
                    height: rowHeight
                    zhangdie: parseFloat(parent.rowData["ZhangDie"])
                    zuixinjia: parseFloat(parent.rowData["ZuiXinJia"])
                    column: index
                    row:parent.rowIndex
                    //implicitHeight: blockTableView.rowHeight
                    property string lastLabelText:""
                    color : {
                        changeField = 0;
                        if(parent.rowIndex !== 0 && cacheLast.length > 0 && [0,1,2,3,16].indexOf(column) < 0 && (parent.rowData["ZhongWenJianCheng"] === cacheLast[parent.rowIndex - 1]["ZhongWenJianCheng"] && cacheLast[parent.rowIndex - 1][field] !== parent.rowData[field] && parseInt(cacheLast[parent.rowIndex - 1][field]) !== 0)){
                            changeField = 1;
                            return zhangdie < 0 ? theme.greenColor : theme.redColor;
                        }else if(isSelected){
                            //console.log("Color value sel:",parent.rowIndex,column,labelText,parent.rowData[field]);
                            return theme.stockTableRowSelectColor;
                        } else {
                            //console.log("Color value normal:",parent.rowIndex,column,labelText,parent.rowData[field]);
                            return parent.rowData["Color"] === undefined ? backColor[0] : backColor[parent.rowData["Color"]];
                        }
                    }
                    border.width : 1
                    border.color : isSelected ? theme.stockTableRowNoSelectColor : Qt.lighter(theme.stockTableBorderColor,1.2)

                    property string field: modelData.field
                    property int columnIndex: index
                    Layout.fillHeight: false
                    Layout.fillWidth: false
                    Layout.preferredWidth: modelData.width
                    labelText: (index === 2 && row !== 0 && parent.rowData[field] !== undefined) ? parent.rowData[field].substr(2): parent.rowData[field] || '--'

                }
            }
        }
    }

    //创建行控件
    onShowCountChanged: {
        var count = showCount;//头占一行
        var length = container.children.length || 0;

        console.log('updateViewonShowCountChanged :',count, length);
        // 减少
        if (length > count) {
            var deleteChildren = Array.prototype.splice.call(container.children, count, length - count);
            deleteChildren.forEach(function(eachChild) {
                eachChild.destroy();
            });
        } else if (length < count) {
            var i = 0;
            if(length === 0) {
                // 创建标题行
                i = 1;
                var rowHead = rowComponent.createObject(container, {rowIndex: 0});
                rowHead.rowData = Qt.binding(function() {
                        return modelHead || {};
                });
            }

            for (; i <= count - length; i++) {
                // 创建新的行
                var row = rowComponent.createObject(container, {rowIndex: length + i});
                row.rowData = Qt.binding(function(index) {
                    return function() {
                        //console.log('UpdateRowData:',model[index]["Color"],backColor[0],model.length, index, printTime());
                        return model[index] || {};
                    }
                }(length + i - 1));
            }
        }
    }

    //页面列布局，行的容器
    ColumnLayout {
        id: container
        //anchors.fill: parent //点击头排序后，行之间出现间隙，所以注释
        spacing: 0
    }

    MouseArea{
        anchors.fill: parent
        focus: false
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: {
            rowHeight = container.height/container.children.length;
            blockTableView.clickedRow(parseInt(mouse.y/rowHeight) - 1,mouse.x);
            mouse.accepted = false;
        }

        onDoubleClicked: {
            blockTableView.activatedToDetail(parseInt(mouse.y/rowHeight) - 1,mouse.x);
        }

    }

    //双击进入详细页面
    onActivatedToDetail: {
        if(row < 0){
            return
        }
        if(column < 30){
            //展开成分股
            expandChildren(row);
            return;
        }

        console.log("onActivatedToDetail:" + row);
        var objActivate = model[row].Obj;
        console.log("onActivated:" + " blockNameT=" + stock.fullName + " obj:"+objActivate);

        var market = "31";
        var marketName = "B$";
        if(objActivate.substring(0,2) !== "B$"){
            //marketName 可能为空
            market = "99"
            marketName = stock.fullName;
        }
        root.context.pageNavigator.push(appConfig.routePathStockDetail, {"market":market, "marketName":marketName, "obj":objActivate, "orderBy":orderByParam, "desc":descParam, "type":0});
    }

    //单击某行操作
    onClickedRow:{
        if(row < 0){
            //点击头
            console.log("sortedByHeaderColumn:" ,row,column);
            sortedByHeaderColumn(column);
            return;
        }

        if(column < 30){
            //展开成分股
            expandChildren(row);
            return;
        }

        focusobjParam = model[row].Obj

        //更新选中的行
        updateSelectItem(focusobjParam);

        //显示右视图
        setRightSideBarVisible(true);
    }

    //展开收起成分股
    function expandChildren(row){
        if(model[row].Head === "+"){
            updateTimer.stop();
            blockTableView.obj = "";
            lastBlockObjIndex = {};
            isUpdateObjIndex = 1;
            blockTableView.obj = model[row].Obj;
            expandObj = model[row].Obj;

            expandStkPos = blockModel.getExpandPosition(expandObj);
            expandStkChengFenGuCout = blockModel.getExpandPositionChildCount(expandObj);

            startPos = expandStkPos - row;
            if(startPos < 0){
                startPos = 0;
            }

            endPos = startPos + showCount;
            isFirstUpdateChengFenGu = 1;
            expandStkChengFenGuIsUpdate = 0;

            if(expandStkChengFenGuCout > 0){
                updateShowDataInView();
            }
            console.log("展开成分股"+printTime());
            isUpdateViewRightNowChild = 0;

        } else if(model[row].Head === "-"){
            //console.log("收起展开项 "+printTime());
            expandStkChengFenGuIsUpdate = -1;
            isFirstUpdateChengFenGu = 0;
            isUpdateObjIndex = -1;
            blockTableView.dpBlock.cancel();
            if (blockTableView.batchReqBlock) blockTableView.batchReqBlock.cancel();
            var i=0;
            var offset = expandStkPos;
            blockTableView.expandStkPos = -1;
            blockTableView.expandStkChengFenGuCout = 0;
            blockTableView.obj = "";
            //console.log("收起展开项end "+printTime());
            updateShowDataInView();
        }
    }

    //数据更新后，更新选中的行
    function updateSelectItem(selectObj){
        //第一条是标题，所以要加1
        var cacheIndex = 0;
        for(var i=1;i<container.children.length;i++){
            cacheIndex = i - 1;
            if(cacheIndex < cache.length && cache[cacheIndex].Obj === selectObj){
                container.children[i].isSelected = true;
            }else{
                container.children[i].isSelected = false;
            }
        }
    }

    //打印格式化时间函数
    function printTime(){
        var dt  = new Date();
        var ret = "["+dt.getFullYear()+":"+dt.getMonth()+":"+dt.getDay()+" "+dt.getHours()+":"+dt.getMinutes()+":"+dt.getSeconds()+":"+dt.getMilliseconds();
        return ret;
    }

    //滚动条
    VScrollBar {
        flicker: _flicker
    }
    HScrollBar {
        flicker: _flicker
    }

    //定时器相关属性
    property int runCountInFalseMax: 100; //在无数据更新情况下，定时器连续运行最大次数
    property int runCountInFalse: 0; //在无数据更新情况下，定时器连续运行次数

    //定时器定时刷新数据
    Timer {
        id:updateTimer
             interval: 1000; running: true; repeat: true
             onTriggered: {
                updateShowDataInView();

                //检查是否需要关闭定时器
                if(isAutoUpdateByTimer){
                    runCountInFalse = 0;
                }else{
                    runCountInFalse++;
                }
                isAutoUpdateByTimer = false;
                if(runCountInFalse > runCountInFalseMax){
                    updateTimer.stop();
                    //console.log("Timer is setted stop.");
                }
             }
    }

    onVisibleChanged:{
        console.log("onVisibleChanged",visible);
        if(visible){
            blockTableView.activePage();
        }else{
            blockTableView.deActivePage();
        }
    }

    //页面激活
    onActivePage:{
        lastBlockObjIndex = {};

        if(expandStkPos > -1){
            console.log("onSortHeadChild:"+printTime());
            dpBlock.cancel();
            if (batchReqBlock) batchReqBlock.cancel();
            var newObj = obj;
            obj = "";
            obj = newObj;
        }else{
            reqData();
        }
        //showRowCountInView = (blockTableView.height - headHeight)/rowHeight + 1;
        //viewShowData = showRowCountInView;
        viewShowData = showCount;
        updateTimer.start();
    }

    //页面隐藏
    onDeActivePage:{
        console.log("onAfterDeactive dpBlock.cancel()");
        blockTableView.dp.cancel();
        if (blockTableView.batchReq) blockTableView.batchReq.cancel();
        blockTableView.dpBlock.cancel();
        if (blockTableView.batchReqBlock) blockTableView.batchReqBlock.cancel();

        updateTimer.stop();
    }

    function reConnect(){
        //console.log("onReconnect");
        // 重连后重新请求页面
        //休眠页面
        blockTableView.deActivePage();
        blockTableView.focus = false;

        //激活页面
        blockTableView.activePage();
        blockTableView.focus = true;
    }

    Component.onCompleted: {

    }

    //根据标题排序
    onSortedByHeaderColumn: {
        //添加箭头
        //console.log("onSortedByHeaderColumn headTitle.toString1:",headTitle.toString());
        var columnIndex = parseInt(column/100 + 1);
        var columnCount = _columns.length;
        var newHeadTitle = headTitle;
        for (var i = 2 ; i < columnCount; i++) {
            headTitle[_columns[i].field] = headTitle[_columns[i].field].replace(/["↑","↓"]/g,"");
        }
        newHeadTitle[_columns[columnIndex].field] = newHeadTitle[_columns[columnIndex].field] + (_columns[columnIndex].desc?"↑":"↓");

        //headTitle = {};
        headTitle = newHeadTitle;
        column -= 80;

        //重新请求
        _columns[columnIndex].desc = !_columns[columnIndex].desc;

        startParam = 0;
        //countParam = pageSize * 2;
        orderByParam = _columns[columnIndex].field;
        descParam = _columns[columnIndex].desc;

        console.log("onSortedByHeaderColumn orderby:",orderByParam);
        //滚动条重置为初识状态
        focusobjParam = "";
        setRightSideBarVisible(false);

        lastBlockObjIndex = {};

        if(expandStkPos > -1){
            console.log("onSortHeadChild:"+printTime());
            dpBlock.cancel();
            if (batchReqBlock) batchReqBlock.cancel();
            var newObj = obj;
            obj = "";
            obj = newObj;
            isUpdateViewRightNowChild = 0;
        }else{
            reqData();
            isUpdateViewRightNowParent = 0;
        }
        updateTimer.stop();
        isUpdateCacheLast = true;
    }

    //水平滚动条相关属性
    //拖动水平滚动条，可移动列的开始位置
    property int moveableColumnStart: 4
    //拖动水平滚动条，可移动列的最大位置
    property int moveableColumnMax: (_flicker.contentWidth - blockTableView.width)/100 + moveableColumnStart + 1
    //可移动列的当前位置
    property int moveableColumnCurrent: moveableColumnStart
    //可移动列的对应的步长
    property int moveableColumnStep: (_flicker.contentWidth - blockTableView.width)/(moveableColumnMax - moveableColumnStart)

    //键盘响应事件
    Keys.onPressed: {
        console.log("Key_event:",_flicker.contentWidth - blockTableView.width + (blockTableView.width - 80)%100, printTime());
        viewShowData = showCount;
        var columnCountInView = (blockTableView.width - contentFixedWidthInView)/100 - 1;
        var contentHeightInView = rowHeight*(viewShowData-1);
        var contentWidthHScroll = _flicker.visibleArea.widthRatio*blockTableView.width;
        var newContentY;
        var newContentX;

        var newContentXMax = blockTableView.width;
        switch(event.key) {
            case Qt.Key_Left:{
                console.log("Key_Left1:",_flicker.contentX);
                newContentX = _flicker.contentX - moveableColumnStep;

                if(newContentX > 0){
                    _flicker.contentX = newContentX;
                }else{
                    _flicker.contentX = 0;
                }

                event.accepted = true;
                break;
            }
            case Qt.Key_Right:{

                if(moveableColumnCurrent < moveableColumnMax){
                    _flicker.contentX = _flicker.contentX + moveableColumnStep;
                }
                console.log("Key_Right:",_flicker.contentX,_flicker.contentWidth,blockTableView.width,moveableColumnStep,moveableColumnCurrent,moveableColumnMax);
                console.log("Key_Right visiblearea:",_flicker.visibleArea.widthRatio*_flicker.contentWidth,_flicker.visibleArea.widthRatio,_flicker.visibleArea.xPosition);
                event.accepted = true;
                break;
            }
            case Qt.Key_Up:{
                newContentY = _flicker.contentY - rowHeight;
                if(newContentY > 0){
                    _flicker.contentY = newContentY;
                }else{
                    _flicker.contentY = 0;
                }

                event.accepted = true;
                break;
            }
            case Qt.Key_Down:{
                newContentY = _flicker.contentY + rowHeight;
                if(newContentY > (_flicker.contentHeight - contentHeightInView)){
                    _flicker.contentY = _flicker.contentHeight - contentHeightInView;
                }else{
                    _flicker.contentY = newContentY;
                }

                event.accepted = true;
                break;
            }
            case Qt.Key_PageDown:{
                newContentY = _flicker.contentY + contentHeightInView;
                if(newContentY > (_flicker.contentHeight - contentHeightInView)){
                    _flicker.contentY = _flicker.contentHeight - contentHeightInView;
                }else{
                    _flicker.contentY = newContentY;
                }

                event.accepted = true;
                break;
            }
            case Qt.Key_PageUp:{
                    newContentY = _flicker.contentY - contentHeightInView;
                    if(newContentY > 0){
                        _flicker.contentY = newContentY;
                    }else{
                        _flicker.contentY = 0;
                    }

                    event.accepted = true;
                    break;
            }
        }

        isUpdateCacheLast = true;
        updateShowDataInView();
    }

    //设置定时器运行状态
    function setTimerIsNeedStart(isNeedStart){
        if(isNeedStart){
            //需要定时器运行
            if(!updateTimer.running){
                //如果定时器已经停止，启动
                //console.log("setTimerIsNeedStart,Timer is setted from stop to start."+printTime());
                updateTimer.start();
            }
        }else{
            updateTimer.stop();
            //console.log("setTimerIsNeedStart,Timer is setted stop.");
        }
    }

    //请求板块指数排序数据
    function reqData() {
        //console.log("reqData time:"+printTime());
        dp.cancel();
        if (batchReq) batchReq.cancel();
        dp.query(function(result){    //因为是订阅排序，所以会重复推送
            //console.log("reqData recv data time:"+printTime());
            if (result && result.Err === 0) {
                var data = result.Data;
                var len = data.length;
                blockTableView.allBlockStkCount = len;//记录板块股票总个数

                updateBlockData(1,JSON.stringify(data));
                var objIndex = {};
                firstResponseDataIndex = 0
                for (var i = 0 ; i < len; i++) {
                    //                    objIndex[data[i].Obj] = startParam+i;
                    objIndex[data[i].Obj] = firstResponseDataIndex+i;
                }
                currObjIndex = objIndex;

                if(Object.keys(lastObjIndex).length === 0){
                    if (batchReq) batchReq.cancel();
                    quote(currObjIndex);
                }

                lastObjIndex = currObjIndex;
            }
        });
    }

    //请求板块指数行情数据
    function quote(objIndex) {
        if(Object.keys(objIndex).length > 0){
            var objs = [];
            for (var code in objIndex) {
                objs.push(code);
            }
            quoteBlockParam.obj = objs.join(",");
            console.log("quote time:"+printTime());
            batchReq = DataChannel.subscribe("/stkdata", quoteBlockParam, function(data){
                if (data) {
                    var len = data.length;
                    //console.log("quote recv data time:"+printTime()+ " len:" +len);
                    updateBlockData(0,JSON.stringify(data));
                }
            });
        }
    }

    //请求板块指数成分股排序数据
    function reqBlockData(result) {
        //console.log("请求成分股排序数据："+printTime());
        //dpBlock.cancel();
        //if (batchReqBlock) batchReqBlock.cancel();
        if (result&&result.Err ===0) {

            var data = result.Data;
            var len = data.length;
            //console.log("处理成分股排序数据："+len+" "+printTime());
            expandStkChengFenGuCout = len;//记录板块股票总个数

            firstResponseDataIndexBlock = 0
            var objIndex = {};
            for (var i = 0 ; i < len; i++) {
                objIndex[data[i].Obj] = firstResponseDataIndexBlock+i;
            }

            updateBlockChildData(1,expandStkPos,JSON.stringify(data));

            currBlockObjIndex = objIndex;

            if(Object.keys(lastBlockObjIndex).length === 0){
                if (batchReqBlock) batchReqBlock.cancel();
                quoteBlock(objIndex);
            }
            //console.log("处理成分股数据 end"+printTime());
            lastBlockObjIndex = currBlockObjIndex;
        }else{
            console.log("成分股数据错误："+printTime() + result.data);
        }
    }

    //请求板块指数成分股行情数据
    function quoteBlock(objIndex) {
        //console.log("请求成分股行情:" +printTime());
        if(Object.keys(objIndex).length > 0){
            var objs = [];
            for (var code in objIndex) {
                objs.push(code);
            }
            quoteParam.obj = objs.join(",");

            batchReqBlock = DataChannel.subscribe("/stkdata", quoteParam, function(data){
                //console.log("收到成分股行情"+printTime());
                if (data) {
                    var len = data.length;
                    //console.log("收到成分股行情:" +printTime());
                    updateBlockChildData(0,expandStkPos,JSON.stringify(data));
                }
            });
        }
    }

    //更新视图中显示数据
    function updateShowDataInView(){
        //console.log("updateShowDataInView"+printTime());
        //获取jsondata
        if(expandStkPos > -1){
            expandStkPos = blockModel.getExpandPosition(expandObj);
            expandStkChengFenGuCout = blockModel.getExpandPositionChildCount(expandObj);
        }
        //console.log("updateShowDataInView1"+printTime());
        var expandParent = expandStkPos;
        var expandParentChildCount = expandStkChengFenGuCout;
        if(expandParentChildCount === 0){
            //请求展开数据，但数据还没来或本地无数据
            expandParent = -1;
            expandParentChildCount = 0;
            //console.log("请求展开数据，但数据还没来 "+new Date().getTime());
        }
        //console.log("updateShowDataInView2"+printTime());
        cacheLast = cache.slice(0);//效率低于循环
//        cacheLast = [];
//        cache.forEach(function(e){
//            cacheLast.push(e);
//        })
        //console.log("updateShowDataInView3"+printTime());
        cache = blockModel.getShowRowData(startPos,endPos,expandParent);
        //console.log("updateShowDataInView4"+printTime());
        if(isUpdateCacheLast){
            cacheLast = cache;
            isUpdateCacheLast = false;
        }
        isLighterChangeItem = true;

        if(focusobjParam.length === 0 && cache.length > 0 && model[0].Obj !== undefined){
            //默认选中第一行
            focusobjParam = model[0].Obj;
            //console.log("默认选中第一行：",focusobjParam);
        }
        //console.log("updateShowDataInView5"+printTime());
        updateSelectItem(focusobjParam);
        //console.log("updateShowDataInView return len:",cache.length,printTime());
    }

    //更新板块指数数据
    function updateBlockData(isSortFlag,data){
        //console.log("updateBlockData model update start"+printTime());

        //更新model数据
        //blockModel.updateData(isSortFlag,data);
        blockModel.updateBlockDataSlots(isSortFlag,data);

        //console.log("updateBlockData model update  end"+printTime());

//        //获取jsondata
//        var jsonDatas = blockModel.getShowRowData(startPos,endPos,expandStkPos);

//        var expandChildCount = 0;
//        if(expandStkPos > -1 ){
//           expandStkPos = blockModel.getExpandPosition(expandObj);
//           expandChildCount = blockModel.getParentChildsCount(expandStkPos);
//        }

//        console.log("updateBlockData get model data  end"+printTime());

//        var msg = {'action': 'updateBlockData','data':jsonDatas,'stkModel':stkModel,'blockModel':blockModel,'startPos':startPos,'endPos':endPos,'expandStkPos':expandStkPos,'expandChildCount':expandChildCount};
//        worker.sendMessage(msg);
    }

    //更新板块指数成分股数据
    function updateBlockChildData(isSortFlag,parent,data){
        //console.log("updateBlockChildData model update start"+printTime());

        //blockModel.updateChildData(isSortFlag,parent,data);
        if(parent === -1){
            return;
        }

        blockModel.updateBlockChildDataSlots(isSortFlag,parent,data);

        //console.log("updateBlockChildData model update end"+printTime());

//        //获取jsondata
//        var jsonDatas = blockModel.getShowRowData(startPos,endPos,expandStkPos);
//        var expandChildCount = 0;
//        if(expandStkPos > -1 ){
//           expandStkPos = blockModel.getExpandPosition(expandObj);
//           expandChildCount = blockModel.getParentChildsCount(expandStkPos);
//        }
//        console.log("updateBlockChildData get model data end"+printTime());

//        var msg = {'action': 'updateBlockChildData','start':s,'data':jsonDatas,'stkModel':stkModel,'blockModel':blockModel,'startPos':startPos,'endPos':endPos,'expandStkPos':expandStkPos,'expandChildCount':expandChildCount};
//        worker.sendMessage(msg);
    }

    function reset() {

    }

    contextMenuItems: [
        createMenuItem(portfolioContextMenuItem, {obj: currObj}),
        createMenuItem(f10ContextMenuItem, {obj: currObj})
    ]

    Connections {
        //c++树形model
        target: blockModel

        //板块指数数据更新后触发信号，响应函数
        onUpdateBlockDataSignal:{

            isAutoUpdateByTimer = true;
            setTimerIsNeedStart(true);

            //console.log("onUpdateBlockDataSignal");
            if(isUpdateViewRightNowParent < updateViewRightNowMax){
                updateShowDataInView();
                isUpdateViewRightNowParent++;
            }
        }

        //板块指数成分股数据更新后触发信号，响应函数
        onUpdateBlockChildDataSignal:{
            isAutoUpdateByTimer = true;
            setTimerIsNeedStart(true);
            //console.log("onUpdateBlockChildDataSignal start "+updateParentObj+" obj "+obj);
            if(updateParentObj === obj){
                //console.log("onUpdateBlockChildDataSignal equal updateParentObj:"+updateParentObj+" expand:"+obj);
                expandStkChengFenGuIsUpdate = 1;
            }
            if(isUpdateViewRightNowChild < updateViewRightNowMax){
                updateShowDataInView();
                isUpdateViewRightNowChild++;
            }
        }
    }
}



