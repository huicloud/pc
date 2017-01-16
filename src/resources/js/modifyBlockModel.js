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

WorkerScript.onMessage = function(msg) {
    //使用的tableview属性
    //expandStkPos
    //expandChildCount
    //startPos
    //endPos
    //console.log("Js onMessage "+new Date().getSeconds()+":"+new Date().getMilliseconds());
    var listModelShowDataStartPos = 0;//视图中的数据从第一个element开始显示数据，因为滚动事件的原因
    var listModelShowDataIndex = 0;//
    var expandStkPos = msg.expandStkPos;
    var startPos = msg.startPos;
    var endPos = msg.endPos;
    var stkModel = msg.stkModel;
    var blockModel = msg.blockModel;
    var dataLength = msg.data.length;
    var focusObj = msg.focusObj;
    var focusObjIndex = -1;//默认取消高亮

    var child=-1;
    var childCount = 0;
    var parent = startPos;
    var expandChildCount = 0;
    var i = 0;
    var jsonRowData;
    var rowDataUpdateFlag=0;
    var updatePos = 0;


    if(startPos >expandStkPos){
        childCount = startPos - expandStkPos -1;
    }

    expandChildCount = msg.expandChildCount;

    if(startPos >= (expandStkPos+expandChildCount))
    {
        //要显示的元素从板块指数开始
        parent = startPos - expandChildCount;
    }
    //var blockTableView = msg.blockTableView;
    if (msg.action === "updateBlockData") {


        //console.log("Js onMessage updateBlockData"+expandStkPos+":"+expandChildCount);
        for(i=startPos;i<endPos;i++){
            if((i-startPos) > dataLength){
                continue;
            }

            jsonRowData = msg.data[i-startPos];
            listModelShowDataIndex = listModelShowDataStartPos + i - startPos;
            child = -1;
            if(expandStkPos> -1 && i>expandStkPos && childCount < expandChildCount){
                child = childCount;
                childCount++;
            }else{
                parent++;
            }

            stkModel.set(listModelShowDataIndex,jsonRowData);
            var rdata;
            if(child > -1 ){
                //console.log("Js onMessage child > -1 listModelShowDataIndex:"+listModelShowDataIndex);
                rdata = stkModel.get(listModelShowDataIndex);
                rdata.Head ="";
                rdata.XuHao =childCount;
                stkModel.set(listModelShowDataIndex,rdata);
                if(i === startPos){
                    //第一个元素为子节点元素
                    parent = expandStkPos + 1;
                }
            }else{
                rdata = stkModel.get(listModelShowDataIndex);
                if(i===expandStkPos){
                    rdata.Head ="-";
                    //console.log("Js onMessage expand:"+i+":"+expandStkPos+rdata.ZhongWenJianCheng);
                } else {
                    rdata.Head ="+";
                    //console.log("Js onMessage "+i+":"+expandStkPos+rdata.ZhongWenJianCheng);
                }


                rdata.XuHao =parent;
                stkModel.set(listModelShowDataIndex,rdata);
            }
            if(rdata.Obj === focusObj){
                //console.log("JS focusObjIndex:" +i);
                focusObjIndex = i-startPos;
            }
        }
    }
//    else if (msg.action === 'updateBlockChildData') {

//        //console.log("Js onMessage updateBlockChildData"+expandStkPos);
//        child=-1;

//        if(expandStkPos > -1){
//            for(i=startPos;i<endPos;i++){
//                if((i-startPos) > dataLength){
//                    continue;
//                }
//                jsonRowData = msg.data[i-startPos];
//                listModelShowDataIndex = listModelShowDataStartPos + i - startPos;
//                child = -1;
//                if(expandStkPos> -1 && i>expandStkPos && expandChildCount > 0){
//                    child = childCount;
//                    childCount++;
//                    expandChildCount--;
//                }else{
//                    parent++;
//                }

//                stkModel.set(listModelShowDataIndex,{'ZhongWenJianCheng':"", 'ZuiXinJia':0});
//                stkModel.set(listModelShowDataIndex,jsonRowData);


//                if(child > -1 ){
//                    rdata = stkModel.get(listModelShowDataIndex);
//                    rdata.Head ="";
//                    rdata.XuHao =childCount;
//                    //console.log("Js parent onMessage "+i+":"+child);
//                    stkModel.set(listModelShowDataIndex,rdata);
//                }else{
//                    rdata = stkModel.get(listModelShowDataIndex);
//                    if(i===expandStkPos){
//                        rdata.Head ="-";
//                        //console.log("Js child onMessage expand:"+i+":"+expandStkPos);
//                    } else {
//                        rdata.Head ="+";
//                        //console.log("Jschild onMessage "+i+":"+expandStkPos);
//                    }
//                    rdata.XuHao =parent;
//                    stkModel.set(listModelShowDataIndex,rdata);
//                }
//            }
//        }
//    } else if (msg.action === "updateViewData") {
//        //console.log("Js onMessage updateViewData");
//        for(i=startPos;i<endPos;i++){
//            if((i-startPos) > dataLength){
//                continue;
//            }
//            jsonRowData = msg.data[i-startPos];
//            listModelShowDataIndex = listModelShowDataStartPos + i - startPos;
//            stkModel.set(listModelShowDataIndex,jsonRowData);

//            rdata = stkModel.get(listModelShowDataIndex);
//            rdata.Head ="+";
//            rdata.XuHao =i+1;
//            stkModel.set(listModelShowDataIndex,rdata);
//        }
//    }
    //blockTableView.selection.clear();
    stkModel.sync();



    //console.log("Js onMessage "+new Date().getSeconds()+":"+new Date().getMilliseconds());
    //不往外面传消息
    WorkerScript.sendMessage({'focusObjIndexInShowView':focusObjIndex});
}
