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
import QtQuick.Layouts 1.3
import "../../../util"
import "../../../core"
import "../../../core/common"
import "../../../core/data"
import "../../../controls"

/**
 *  板块 指数 成分股列表组件
 *  author: lvyue
 */
ContextComponent {
    id: root
    property QtObject appConfig: ApplicationConfigure
    property string market: ""
    property string obj: "";
    property int type: 0;  //0现价 1涨速
    property int marketType: -1
    property var block: BlockUtil.blockName.createObject(root)
    property string blockMarket: BlockUtil.getBlockFullName(market) ? BlockUtil.getBlockFullName(market):""
    property int titleHeight: 30
    property int rowHeight: 30
    property var gglParam: block.fullName.length > 0 ? "block=" + block.fullName:( blockMarket.length > 0 ? "block=" + blockMarket:undefined)

    property var objParam: {
        if(market === "CYINX"){
            //常用指数，marketType === 7也可判断
            return appConfig.requestObjsCyinx;
        } else if( marketType === 1 || marketType === 3 ){
            //自选股 键盘宝
            return PortfolioUtil.getList().map(function(eachData) {
                                           return eachData.obj
                                       });
        } else if(marketType === 2){
            //最近浏览
            return HistoryUtil.getList().map(function(eachData) {
                return eachData.obj
            });
        } else {
            return undefined;
        }
    }


    property var dpParam: ({
                               gql: gglParam,
                               mode: 3,
                               obj: objParam,
                               field: "ZhongWenJianCheng,ZhangFu,ZuiXinJia",
                               desc: stockTable.orderByColumn ? stockTable.orderByColumn.desc : undefined,
                               orderby: stockTable.orderByColumn ? stockTable.orderByColumn.orderByFieldName : undefined,
                               start: stockTable.startIndex,
                               count: stockTable.showRowCount+10
                           });

    property var stockList: []

    DataProvider {  //排序数据源
        id: dp
        parent: root
        serviceUrl: "/stkdata"
        params: dpParam
        sub: 1
        direct: true
        onSuccess: {
            var result = data.Data;

            var arr = [];
            for (var i = 0 ; i < data.ObjCount; i++) {
                arr.push({});
            }

            for (var i = 0; i < result.length; i++) {
                arr[stockTable.startIndex+i] = result[i];
            }

            stockList = arr;
        }
    }

    ColumnLayout {
        anchors.fill: root
        spacing: 0

        Rectangle {
            id: titleRec
            Layout.preferredHeight: titleHeight
            Layout.fillWidth: true
            color: theme.stockTableHeadBackGroundColor
            visible: obj.substring(0,2) === "B$" ? true :(block.fullName.length > 0 ? true : false)
            Text {
                id: text
                text: type ? "涨速榜" : "全部成分股"
                anchors.centerIn: titleRec
            }
        }

        SeparatorLine {
            Layout.fillWidth: true
            orientation: Qt.Horizontal
            length: parent.width
            color: theme.rightSideBarBorderColor
            visible: obj.substring(0,2) === "B$" ? true :(block.fullName.length > 0 ? true : false)
        }

        StockTable {
            id: stockTable
            Layout.fillHeight: true
            Layout.fillWidth: true

            fillWidth: true
            minimumRowHeight: rowHeight
            model: stockList

            property list<StockTableColumn> zuiXinJiaColumn: [
                StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; align: Qt.AlignCenter; fixed: true; resizable: false; height: rowHeight; width: root.width/3-2 },
                StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; align: Qt.AlignCenter; updownStyle: true; highlightPolicy: 'updown'; fixed: true; resizable: false; height: rowHeight; width: root.width/3-2},
                StockTableColumn {field: 'ZuiXinJia'; title: '最新'; align: Qt.AlignCenter; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown'; fixed: true; resizable: false; height: rowHeight; width: root.width/3-2},
                StockTableColumn {field: 'XiaoShuWei'; visible: false;}
            ]


            property list<StockTableColumn> zhangSuColumn: [
                StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; align: Qt.AlignCenter; fixed: true; resizable: false; height: rowHeight; width: root.width/3-2},
                StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; align: Qt.AlignCenter; updownStyle: true; highlightPolicy: 'updown'; fixed: true; resizable: false; height: rowHeight; width: root.width/3-2},
                StockTableColumn {field: 'FenZhongZhangFu5'; title: '涨速%'; align: Qt.AlignCenter; updownStyle: true; highlightPolicy: 'updown'; fixed: true; resizable: false; height: rowHeight; width: root.width/3-2},
                StockTableColumn {field: 'XiaoShuWei'; visible: false;}
            ]

            columns: type ? zhangSuColumn : zuiXinJiaColumn

            //默认排序字段
            orderByColumn: type ? (columns[2]?columns[2]:null) :  (columns[1]?columns[1]:null)

            property string selectedObj: selectedIds[0] || ''


            onDoubleClicked: {
                root.context.pageNavigator.push(appConfig.routePathStockDetail, {"obj":row.Obj, "orderBy":(stockTable.orderByColumn ? stockTable.orderByColumn.orderByFieldName : undefined), "desc":(stockTable.orderByColumn ? stockTable.orderByColumn.desc : undefined), "type":1});
            }


            Keys.onPressed: {
                if (selectedObj && selectedObj.length>0) {

                    if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
                        root.context.pageNavigator.push(appConfig.routePathStockDetail, {"obj": selectedObj, "orderBy":(stockTable.orderByColumn ? stockTable.orderByColumn.orderByFieldName : undefined), "desc":(stockTable.orderByColumn ? stockTable.orderByColumn.desc : undefined), "type":1});
                        event.accepted = true;
                    } else if (event.key === Qt.Key_F10){
                        StockUtil.getStockType(selectedObj, function(type) {
                            if ([1, 2, 10, 11].indexOf(type) !== -1) {
                                root.context.pageNavigator.push(appConfig.routePathStockDetail, {'chart':'f10', 'obj':selectedObj});
                            }
                        });
                        event.accepted = true;
                    }

                }
            }

            contextMenuItems: {
                return [
                {
                    visible: function() {
                        return stockTable.selectedIds.length > 0;
                    },

                    // 多个选中添加或者删除自选股
                    text: function(item) {

                        // 有一个不在自选股中则显示添加，否则显示删除
                        item.add = stockTable.selectedIds.some(function(obj) {
                            return !PortfolioUtil.inPortfolios(obj);
                        });
                        return item.add ? '添加自选股' : '删除自选股';
                    },
                    add: true,
                    triggered: function(item) {
                        var selectedIds = [].concat(stockTable.selectedIds);
                        var add = item.add;
                        selectedIds.forEach(function(obj) {
                            if (add) {
                                PortfolioUtil.add({obj: obj});
                            } else {
                                PortfolioUtil.remove({obj: obj});
                                stockTable.selectedIds = [];
                            }
                        });
                    }
                },
//                createMenuItem(f10ContextMenuItem, {
//                                   visible: function(item) {
//                                       return stockTable.selectedIds.length > 0 && StockUtil.getStockType(item.obj) === 1;
//                                   },
//                                   triggered: function(item) {
//                                       root.context.pageNavigator.push(stockTable.getDetailUrl(item.obj) + '&chart=f10');
//                                   },
//                                   obj: stockTable.selectedIds[0]
//                               })
            ]}
        }

    }
}
