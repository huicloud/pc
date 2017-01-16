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
import "../core"
import "../core/data"
import "../controls"


/**
 * 关联报价组件 dongw
 */
ContextComponent {
    id: root
    property string obj

    // 排序方向
    property bool desc: true

    property var plankStockList: []
    property var fundStockList: []

    property bool hasFundData: false  //是否有关联基金
    // 全部要显示的字段
    property list<StockTableColumn> plankTableColumns: [
        StockTableColumn {height: 24; field: 'ZhongWenJianCheng'; title: '板块名称'; fixed: true; align: Qt.AlignHCenter;},
        StockTableColumn {height: 24; field: 'ZhangFu'; title: '涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
        StockTableColumn {height: 24; field: 'LingZhangGu'; title: '领涨股'; sortable: false;
            _tableCellComponent:Item{
                anchors.fill: parent
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    height: parent.height
                    text: {(rowData.LingZhangGu && rowData.LingZhangGu.ZhongWenJianCheng) ? rowData.LingZhangGu.ZhongWenJianCheng : '--'}
                    color: {
                        if (rowData.LingZhangGu){
                            if (rowData.LingZhangGu.ZhangFu > 0){
                                theme.redColor
                            }else if (rowData.LingZhangGu.ZhangFu < 0){
                                theme.greenColor
                            }else{
                                theme.normalColor
                            }

                        }else{
                            theme.normalColor
                        }
                    }
                }
            }
        },
        StockTableColumn {height: 24; width: 105; field: 'ZhangDiePing'; title: '涨平跌'; sortable: false;
            _tableCellComponent:Item{
                anchors.fill: parent
                Text {
                    anchors.right: center.left
                    height: parent.height
                    text: rowData && rowData.ShangZhangJiaShu ? rowData.ShangZhangJiaShu : '-'
                    color: theme.redColor
                }
                Text {
                    id: center
                    anchors.right: right.left
                    height: parent.height
                    text: '/' + (rowData && rowData.PingPanJiaShu ? rowData.PingPanJiaShu : '-') + '/'
                    color: theme.normalColor
                }
                Text{
                    id: right
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    height: parent.height
                    text: rowData && rowData.XiaDieJiaShu ? rowData.XiaDieJiaShu : '-'
                    color: theme.greenColor
                }
            }
        },
        StockTableColumn {height: 24; field: 'FenZhongZhangFu5'; title: '涨速%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
        StockTableColumn {height: 24; field: 'ChengJiaoLiang'; title: '总手'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.volColor;},
        StockTableColumn {height: 24; field: 'ChengJiaoE'; title: '成交额'; isAutoPrec: true; unit: '万/亿'; textColor: theme.volColor;},
        StockTableColumn {height: 24; field: 'ZhenFu'; title: '振幅%'; textColor: theme.volColor; precision: 2;},
        StockTableColumn {height: 24; field: 'LiangBi'; title: '量比'; textColor: theme.volColor; precision: 2;},

        StockTableColumn {height: 24; field: 'Obj'; title: '代码';request: false; visible: false}
    ]

    property list<StockTableColumn> fundTableColumns: [
        StockTableColumn {height: 24; field: 'ZhongWenJianCheng'; title: 'ETF基金'; fixed: true; align: Qt.AlignHCenter;},
        StockTableColumn {height: 24; field: 'ZuiXinJia'; title: '现价'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
        StockTableColumn {height: 24; field: 'ZhangFu'; title: '涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
        StockTableColumn {height: 24; field: 'ZhangDie'; title: '涨跌'; updownStyle: true; highlightPolicy: 'updown';},
        StockTableColumn {height: 24; field: 'ZhangJingZhiBi'; title: '占净值比%'; request: false;  textColor: theme.normalColor; precision: 2;},
        StockTableColumn {height: 24; width: 120; field: 'ChiGuLiang'; title: '持股量（万股）'; request: false;  textColor: theme.normalColor; isAutoPrec: true;},

        StockTableColumn {height: 24; field: 'ZuoShou'; title: '昨收'; visible: false},
        StockTableColumn {height: 24; field: 'XiaoShuWei'; visible: false;},
        StockTableColumn {height: 24; field: 'Obj'; title: '代码'; request: false; visible: false}
    ]


    StockTable{
        id: plankTable
        anchors.left: parent.left
        anchors.top: parent.top
        width: hasFundData ? parent.width / 2 : parent.width
        height: parent.height
        minimumRowHeight: 20
        maximumRowHeight: 26
        controlVisible: false
        orderByColumn: columns[1]
        columns: root.plankTableColumns
        onDoubleClicked: {
            if (row.Obj){
                root.context.pageNavigator.push(appConfig.routePathStockDetail, {'obj': row.Obj});
            }
        }
    }

    SeparatorLine {
        id: line
        visible: hasFundData
        anchors.left: plankTable.right
        length: parent.height
    }

    StockTable{
        id: fundTable
        visible: hasFundData
        anchors.left: line.right
        anchors.right: parent.right
        height: parent.height
        minimumRowHeight: 20
        maximumRowHeight: 26
        controlVisible: false
        columns: root.fundTableColumns
        orderByColumn: columns[2]
        property string orderBy: fundTable.orderByColumn ? (fundTable.orderByColumn.field + fundTable.orderByColumn.desc) : ''
        onOrderByChanged: {
            if (fundTable.orderByColumn){
                //有排序的情况下
                var datas = fundTable.model;
                fundTable.model = sortFundData(datas);
            }else{
                //无排序的情况下
            }
        }

        onDoubleClicked: {
            if (row.Obj){
                root.context.pageNavigator.push(appConfig.routePathStockDetail, {'obj':row.Obj});
            }
        }
    }

    onObjChanged: {
        plankStockList = [];
        fundStockList = [];

        //列表置位
        reset(fundTable, 2);
        reset(plankTable, 1);
    }

    function reset(table, defaultOrderIndex) {
        table.selectedIds = [];
        table.orderByColumn = table.columns[defaultOrderIndex];
        table.orderByColumn.desc = root.desc;
        table.toTop();
        table.toLeft();
    }

    function processStockListData(data){
        var hasJiJinLeiXing = false;

        if (data && data[0].JieGuo) {
            data[0].JieGuo.forEach(function(dataList){
                if (dataList){
                    if (dataList.LeiXing === 8){
                        //板块
                        if(dataList || dataList.ShuJu){
                            dataList.ShuJu.forEach(function(eachData){
                                plankStockList.push(eachData.DaiMa);
                            });
                        }
                    }else if (dataList.LeiXing === 7){
                        //基金
                        if(dataList || dataList.ShuJu){
                            hasJiJinLeiXing = dataList.ShuJu.length > 0;  //显示基金
                            dataList.ShuJu.forEach(function(eachData){
                                var cgl = '';
                                var zjzb = '';
                                if (eachData.KuoZhan){
                                    var kuoZhanData = JSON.parse(eachData.KuoZhan);
                                    if (kuoZhanData.head && kuoZhanData.data && kuoZhanData.data[0]){
                                        var cglIndex = kuoZhanData.head.indexOf('Cgl');
                                        var zjzbIndex = kuoZhanData.head.indexOf('Zjzb');
                                        cgl = kuoZhanData.data[0][cglIndex];
                                        zjzb = kuoZhanData.data[0][zjzbIndex];
                                    }
                                }
                                fundStockList.push({'Obj':eachData.DaiMa, 'cgl': cgl, 'zjzb':zjzb});
                            });
                        }
                    }
                }
            });

            //进行数据订阅
            if (plankStockList.length > 0){
                plankDataProvider.objs = plankStockList.join(',');
                plankDataProvider.autoQuery = true;
                plankDataProvider.query();
            }

            if (fundStockList.length > 0){
                fundDataProvider.objs = fundStockList.map(function(eachData){return eachData.Obj}).join(',');
                fundDataProvider.autoQuery = true;
                fundDataProvider.query();
            }
        }
        root.hasFundData = hasJiJinLeiXing;
    }

    /*请求关联版块基金数据*/
    DataProvider {
        id: dataProvider
        serviceUrl: '/kbspirit'
        params: ({
                     input: root.obj,
                     type: '7,8',
                     kuozhan: 1
                 })

        onSuccess: {
            if (data[0].GuanJianZi !== root.obj){
                reset();
            }else{
                //处理返回数据
                processStockListData(data);
            }
        }
    }

    /*关联板块的行情数据*/
    DataProvider {
        id: plankDataProvider

        property string objs
        property string fields: Array.prototype.filter.call(plankTableColumns, function(eachColumn){
            return eachColumn.request
        }).map(function(eachColumn){
            return eachColumn.field;
        }).join(',')

        serviceUrl: '/stkdata'
        sub: 1
        autoQuery: false
        params: ({
                     obj: objs,
                     field: fields,
                     mode: 2,
                     orderBy: plankTable.orderByColumn ? plankTable.orderByColumn.orderByFieldName : /*!objs ? 'JiaoYiDaiMa' :*/ undefined,
                                                         desc: plankTable.orderByColumn ? plankTable.orderByColumn.desc : undefined
                 })

        onSuccess: {
            plankTable.model = data.map(function(eachData){
                return eachData;
            })
        }

        onError:{
            plankTable.model = []
        }
    }

    /*关联基金的行情数据*/
    DataProvider {
        id: fundDataProvider
        property string objs
        property string fields: Array.prototype.filter.call(fundTableColumns, function(eachColumn){
            return eachColumn.request
        }).map(function(eachColumn){
            return eachColumn.field;
        }).join(',')

        serviceUrl: '/stkdata'
        sub: 1
        autoQuery: false

        property string orderByField: fundTable.orderByColumn ? (fundTable.orderByColumn.orderByFieldName === 'ZhangJingZhiBi' || fundTable.orderByColumn.orderByFieldName === 'ChiGuLiang' ? undefined : fundTable.orderByColumn.orderByFieldName) : undefined


        params: ({
                     obj: objs,
                     field: fields,
                     mode: 2,
                     orderBy: fundTable.orderByColumn ? (['ZhangJingZhiBi', 'ChiGuLiang'].indexOf(fundTable.orderByColumn.orderByFieldName) !== -1 ? undefined : fundTable.orderByColumn.orderByFieldName) : undefined,
                     desc: fundTable.orderByColumn ? (['ZhangJingZhiBi', 'ChiGuLiang'].indexOf(fundTable.orderByColumn.orderByFieldName) !== -1 ? true : fundTable.orderByColumn.desc) : undefined
                 })

        onSuccess: {
            var showDatas = [];
            showDatas = data.map(function(eachData){
                var matchItem = fundStockList.filter(function(eachItem){
                    return eachItem.Obj === eachData.Obj;
                });
                if (matchItem.length > 0){
                    eachData.ZhangJingZhiBi = matchItem[0].zjzb;
                    eachData.ChiGuLiang = matchItem[0].cgl;
                }
                return eachData;
            });

            fundTable.model = sortFundData(showDatas);
        }

        onError: {
            fundTable.model = [];
        }
    }

    function sortFundData(datas){
        if (fundTable.orderByColumn){
            if (fundTable.orderByColumn.orderByFieldName === 'ZhangJingZhiBi'){
                if (fundTable.orderByColumn.desc){
                    datas.sort(function(a, b){
                        return a.ZhangJingZhiBi > b.ZhangJingZhiBi ? -1 : 1
                    })
                }else{
                    datas.sort(function(a, b){
                        return a.ZhangJingZhiBi > b.ZhangJingZhiBi ? 1 : -1
                    })
                }
            }else if (fundTable.orderByColumn.orderByFieldName === 'ChiGuLiang'){
                if (fundTable.orderByColumn.desc){
                    datas.sort(function(a, b){
                        return a.ChiGuLiang > b.ChiGuLiang ? -1 : 1
                    })
                }else{
                    datas.sort(function(a, b){
                        return a.ChiGuLiang > b.ChiGuLiang ? 1 : -1
                    })
                }
            }
        }
        return datas;
    }
}
