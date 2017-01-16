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
import "../components/dzhTable"
import "../core/data"

DZHTable {

    id: root
    anchors.fill: parent

    DZHTableColumn { role: "XuHao"; title: ""; width: 50; movable:false }
    DZHTableColumn { role: "Obj"; title: "代码";  width:150; sort: true; orderBy: "JiaoYiDaiMa";movable:false}
    DZHTableColumn { role: "ZhongWenJianCheng"; title: "名称"; width:150;sort: true; movable:false;orderBy: "ZhongWenJianCheng"}

    DZHTableColumn { role: "ZuiXinJia"; title: "最新"; sort: true; orderBy: "ZuiXinJia" }
    DZHTableColumn { role: "ZhangDie"; title: "涨跌"; sort: true; orderBy: "ZhangDie" }
    DZHTableColumn { role: "ZhangFu"; title: "涨幅%↓"; sort: true; orderBy: "ZhangFu" }
    DZHTableColumn { role: "ChengJiaoLiang"; title: "总手"; sort: true; orderBy: "ChengJiaoLiang"}
    DZHTableColumn { role: "HuanShou"; title: "换手率%"; sort: true; orderBy: "HuanShou" }
    DZHTableColumn { role: "XianShou"; title: "现手"; sort: true; orderBy: "XianShou"}
    DZHTableColumn { role: "ChengJiaoE"; title: "总额"; sort: true; orderBy: "ChengJiaoE"}
    DZHTableColumn { role: "FenZhongZhangFu5"; title: "涨速"; sort: true; orderBy: "FenZhongZhangFu5"}
    DZHTableColumn { role: "ZuoShou"; title: "昨收"; sort: true; orderBy: "ZuoShou"}
    DZHTableColumn { role: "KaiPanJia"; title: "今开"; sort: true; orderBy: "KaiPanJia"}
    DZHTableColumn { role: "ZuiGaoJia"; title: "最高"; sort: true; orderBy: "ZuiGaoJia"}
    DZHTableColumn { role: "ZuiDiJia"; title: "最低"; sort: true; orderBy: "ZuiDiJia"}
    DZHTableColumn { role: "HangYe"; title: "行业"; }
    DZHTableColumn { role: "ShiYingLv"; title: "市盈率"; sort: true; orderBy: "ShiYingLv"}
    DZHTableColumn { role: "ShiJingLv"; title: "市净率"; sort: true; orderBy: "ShiJingLv"}
    DZHTableColumn { role: "ShiXiaoLv"; title: "市销率"; }
    DZHTableColumn { role: "WeiTuoMaiRuJia1"; title: "委买价"; sort: true; orderBy: "WeiTuoMaiRuJia1"}
    DZHTableColumn { role: "WeiTuoMaiChuJia1"; title: "委卖价"; sort: true; orderBy: "WeiTuoMaiChuJia1"}
    DZHTableColumn { role: "NeiPan"; title: "内盘"; sort: true; orderBy: "NeiPan"}
    DZHTableColumn { role: "WaiPan"; title: "外盘"; sort: true; orderBy: "WaiPan"}
    DZHTableColumn { role: "ZhenFu"; title: "振幅"; sort: true; orderBy: "ZhenFu"}
    DZHTableColumn { role: "LiangBi"; title: "量比"; sort: true; orderBy: "LiangBi"}
    DZHTableColumn { role: "JunJia"; title: "均价"; sort: true; orderBy: "JunJia"}
    DZHTableColumn { role: "WeiBi"; title: "委比"; sort: true; orderBy: "WeiBi"}
    DZHTableColumn { role: "WeiCha"; title: "委差"; sort: true; orderBy: "WeiCha"}
    DZHTableColumn { role: "ZongChengJiaoBiShu"; title: "成交笔数"; sort: true; orderBy: "ZongChengJiaoBiShu"}
    DZHTableColumn { role: "ChengJiaoFangXiang"; title: "成交方向"; }
    DZHTableColumn { role: "ZongShiZhi"; title: "总市值"; sort: true; orderBy: "ZongShiZhi"}
    DZHTableColumn { role: "LiuTongShiZhi"; title: "流通市值"; sort: true; orderBy: "LiuTongShiZhi"}

    property string market
    property var marketBlock: {
        return {
            "60": "block=市场\\\\沪深市场\\\\沪深A股",
            "61": "block=市场\\\\沪深市场\\\\上证A股",
            "63": "block=市场\\\\沪深市场\\\\深证A股",
            "67": "block=市场\\\\沪深市场\\\\创业板",
            "69": "block=市场\\\\沪深市场\\\\中小板块",
            "st": "block=市场\\\\沪深市场\\\\沪深ST",
            "SH": "block=市场\\\\沪深市场\\\\上证A股",
            "SZ": "block=市场\\\\沪深市场\\\\深证A股"
        }[market]
    }

    property int startParam: 0
    property int countParam: visibleRowCount>0 ? visibleRowCount : 0
    property bool descParam: true
    property string orderByParam: "ZhangFu"
    property string focusobjParam: ""

    property var dpParam: {
        return {
            gql: marketBlock,
            mode: 3, //2表示每5秒推一次 3表示每1秒推一次
            start: startParam,
            count: countParam,
            desc: descParam,
            orderby: orderByParam,
            focus: focusobjParam
        }
    }

    property bool isFirstPush: true;
    property string currObj
    property var sortData: []
    property string objsParam: {
        var arr = sortData.map(function(eachStock){
            return eachStock.Obj
        });
        return arr.join(",");
    }

    property var objIndex: {
        var o = {};
        var xuHao = 0;
        sortData.map(function(eachStock, index){
            if (index === 0) {
                xuHao = eachStock.XuHao;
            }
            o[eachStock.Obj] = {index: index, xuHao: 1+xuHao++};
        });
        return o;
    }

    function reset() {
        currentPageRowIndex = 0;
        focusIndex = 0;
        isFirstPush = true;

        startParam = 0;
        orderByParam = "ZhangFu"
        descParam = true;
        focusobjParam = "";
    }

    function reConnect() {
        quoteDp.cancel();
        dp.cancel();

        dp.query();
        quoteDp.query();
    }

    DataProvider {  //排序数据源
        id: dp
        parent: root
        serviceUrl: "/stkdata"
        params: dpParam
        sub: 1
        direct: true
        onSuccess: {

            sortData = data.Data;

            if (isFirstPush) {
                isFirstPush = false;
                rowCount = data.ObjCount;

                currObj = (sortData[0]&&sortData[0].Obj) ? sortData[0].Obj : "";
                focusobjParam = currObj;
                tableViewSingleSelect(0);
                setRightSideBarVisible(false);
            }
        }
    }

    DataProvider {
        id: quoteDp
        parent: root
        serviceUrl: "/stkdata"
        params: ({
                     obj: objsParam,
                     field: "ZhongWenJianCheng,ZuiXinJia,ZhangDie,ZhangFu,ChengJiaoLiang,HuanShou,XianShou,ChengJiaoE,FenZhongZhangFu5,ZuoShou,KaiPanJia,ZuiGaoJia,ZuiDiJia,HangYe,ShiYingLv,ShiJingLv,WeiTuoMaiRuJia1,WeiTuoMaiChuJia1,NeiPan,WaiPan,ZhenFu,LiangBi,JunJia,WeiBi,WeiCha,ZongChengJiaoBiShu,ZongShiZhi,LiuTongShiZhi"
                 })
        sub: 1
        onSuccess: {

            data.forEach(function(eachData) {
                eachData.XuHao = objIndex[eachData.Obj].xuHao;
                eachData.ZuiXinJia = eachData.ZuiXinJia.toFixed(2);
                eachData.ZhangDie = eachData.ZhangDie.toFixed(2);
                eachData.ZhangFu = eachData.ZhangFu.toFixed(2);

                eachData.ChengJiaoLiang = eachData.ChengJiaoLiang / 100;
                eachData.XianShou = eachData.XianShou / 100;
                eachData.ChengJiaoE = Math.round(eachData.ChengJiaoE / 10000);
                eachData.NeiPan = eachData.NeiPan / 100;
                eachData.WaiPan = eachData.WaiPan / 100;

                tableViewModel.set(objIndex[eachData.Obj].index, eachData)
            });

            var item = objIndex[focusobjParam];
            if (item) {
                tableViewSingleSelect(item.index)
            }

        }
    }

    onSortedByHeaderColumn:{
        column.desc = !column.desc;

        isFirstPush = true;
        currentPageRowIndex = 0;

        startParam = 0;
        orderByParam = column.orderBy;
        descParam = column.desc;
        focusobjParam = "";
    }

    onCurrentPageRowIndexChanged: {
        scrollTimer.stop();
        scrollTimer.start();
    }

    onClicked:{
        if (sortData && sortData.length>0) {
            currObj = sortData[row].Obj;
            focusobjParam = currObj;
            setRightSideBarVisible(true);
        }
    }

    onFocusIndexChanged: {
        if (focusIndex !== -1) {
            var currentRow = focusIndex - currentPageRowIndex;

            if (sortData && sortData.length>0) {
                currObj = sortData[currentRow].Obj;
                focusobjParam = currObj;
            }
        }
    }

    onActivated:{
        var obj = tableViewModel.get(row).Obj;
        root.context.pageNavigator.push(appConfig.routePathStockDetail, {'market':market, 'obj':obj, 'orderBy':orderByParam, 'desc':descParam, 'type':0});
    }

    Timer { //防止滚动过快，反复请求
        id: scrollTimer
        interval: 10
        repeat: false
        onTriggered: {
            //如果focusobj滚出了可视区域，则取消focusobj逻辑
            startParam = currentPageRowIndex + 1;
            if (focusIndex < currentPageRowIndex || focusIndex > currentPageRowIndex+countParam) {
                tableViewDeselectAll();
                focusIndex = -1;
                focusobjParam = "";
            }
        }
    }

    contextMenuItems: [
        createMenuItem(portfolioContextMenuItem, {obj: currObj}),
        createMenuItem(f10ContextMenuItem, {obj: currObj})
    ]

}
