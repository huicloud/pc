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
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

import "../../core"
import "../../core/data"
import "../../controls"
import "../"
import "../../util"
import "../../js/Util.js" as Util
import "../../js/DateUtil.js" as DateUtil

ContextComponent {
    id: root

    // 1：自选股 2：最近浏览 默认0表示6系列的主列表
    property int type: 0

    // 1：基本行情 2：资金分析 3:基金 三套表头 4：常用指数
    property int tableHeaderType: 1

    // 外部需传入的market参数
    property var market

    // 板块名称，默认根据market而定
    property var blockFullName

    // 单独设置的请求的obj，用于自选股，可以是一个字符串或者一个字符串数组
    property var requestObj

    // 是否板块相关（可以展开成分股）
    property bool isBlockType: market === '31'

    // 请求的market参数字段
    property var requestMarket: market === '31' ? 'B$' : undefined

    property var cache: StockUtil.stockCache
    property var stockList: []

    property alias currentRowData: stockTable.currentRowData

    property alias selectedObj: stockTable.selectedObj

    property alias stockTable: stockTable

    property alias draggable: stockTable.draggable

    property alias stockListDataProvider: stockListDataProvider

    property alias dataProvider: dataProvider

    property bool showRightSideBar: true

    // 使能焦点股票
    property bool focusObjEnable: true

    // 焦点股票obj，默认selectedObj
    property string focusObj

    property bool _focusObjPostion: false

    // 是否使用初始请求优化，第一次请求时只请求一页数据，以提高数据响应速度，以加快数据初始渲染速度(默认板块相关表格设置为false避免收起成份股时重新请求第一页数据时造成页面跳动)
    property bool firstRequestOpimizeEnabled: isBlockType ? false : true

    // 是否使用缓存加载优化，冗余请求当前页上一页和下一页的数据后做缓存
    property bool cacheLoadOpimizeEnabled: true

    signal stockDragSorted(var srcObj, var destObj, var isFront);  //股票拖动排序信号

    Connections {
        target: stockTable
        onSelectedRowDataChanged: {
            if (!_focusObjPostion) {
                if (focusObjEnable && stockTable.selectedIds.length === 1 && stockTable.selectedRowData.length === 1) {
                    focusObj = stockTable.selectedIds[0];
                } else {
                    focusObj = '';
                }
            }
        }
    }

    onRequestObjChanged: {
        if (!requestObj || requestObj === '' || requestObj.length === 0) {
            stockList = [];
        }
    }

    onFocusObjChanged: {
        if (focusObjEnable && focusObj !== '') {
            positionFocusObj();
            if (stockTable.selectedIds[0] !== focusObj) {
                stockTable.selectedIds = [focusObj];
            }
        }
    }

    onMarketChanged: {

        // market变化时将表格恢复默认状态
        stockTable.reset();

        if (market && market !== '31' && market !== 'CYINX') {
            BlockUtil.getBlockFullName(market, function(name) {
                blockFullName = name;
            });
        }

        if(market === 'CYINX'){
            blockFullName = undefined;
        }
    }

    // 定位focusObj，判断是否在当前显示区域，是则不移动，否则移动到focusObj所在位置（居中）
    function positionFocusObj() {
        if (focusObjEnable && focusObj !== '') {
            var inShowData = stockTable.showRowData.some(function(eachData) {
                return eachData.Obj === root.focusObj;
            });
            if (!inShowData) {
                var index = -1;
                stockTable.model.some(function(eachData, i) {
                    if (eachData.Obj === root.focusObj) {
                        index = i;
                        return true;
                    }
                });
                if (index !== -1) {
                    var length = stockTable.model.length;
                    var showDataLength = stockTable.showRowData.length;
                    var startIndex = index - parseInt(showDataLength / 2);
                    startIndex = Math.min(length - showDataLength, Math.max(0, startIndex));
                    stockTable.positionRow(startIndex);
                }
            }
        }
    }

    property var stockListOrderByColumn: stockTable.orderByColumn
    property bool stockListOrderByDesc: stockListOrderByColumn ? stockListOrderByColumn.desc : false

    DataProvider {
        id: stockListDataProvider
        serviceUrl: '/stkdata'
        sub: 1

        // 第一次请求限制请求数据条数以能快速响应数据
        property bool first: root.firstRequestOpimizeEnabled
        property var _params: ({
                     gql: blockFullName ? 'block=' + blockFullName : undefined,
                     obj: requestObj,
                     market: root.requestMarket,
                     mode: 2,
//                     field: ['ZhongWenJianCheng'],
                     orderBy: stockListOrderByColumn ? stockListOrderByColumn.orderByFieldName : !requestObj ? 'JiaoYiDaiMa' : undefined,
                     desc: stockListOrderByColumn ? stockListOrderByColumn.desc : undefined
                 })

        on_ParamsChanged: {
            if (root.firstRequestOpimizeEnabled) {
                stockListDataProvider.first = true;
                stockListDataProvider._params.count = stockTable.showRowCount || parseInt(Screen.height / stockTable.minimumRowHeight);
            }
            stockListDataProvider.params = stockListDataProvider._params;
        }

        onSuccess: {

            // 如果是第一次请求数据，则将参数中count去掉后再次订阅全部数据
            if (stockListDataProvider.first) {
                stockListDataProvider.first = false;
                delete stockListDataProvider.params.count;
                stockListDataProvider.params = Util.assign({}, stockListDataProvider.params);
            }

            // 板块展开时不再更新指数列表，表格选中复数条数据时也不更新列表了
            if (!extendedObj && (stockTable.selectedIds.length < 2 || root.orderByChanged)) {

                root._focusObjPostion = true;

                // 排序状态变化后重新定位
                if (root.orderByChanged) {
                    stockTable.toTop();
                    root.orderByChanged = false;
                }

                root.stockList = data;
                stockTable.updateModel();

                root.positionFocusObj();
                root._focusObjPostion = false;

                // 选中多个股票时（只有重新排序后才会满足条件）
                if (stockTable.selectedIds.length >= 2) {
                    stockTable.selectedIds = stockTable.selectedIds.slice(0, 1);
                }
            }
        }
    }

    DataProvider {
        id: dataProvider
        serviceUrl: '/stkdata'
        sub: 1

        // 延时修改objs,使得请求频率降低
        property string _objs
        property string objs: stockTable.showRowData.map(function(eachStock) {return eachStock.Obj}).join(',')

        // 初始避免obj为空时的错误请求
        visible: false

        onObjsChanged: {
            if (dataProviderTimer.running) {
                dataProviderTimer.stop();
                dataProviderTimer.triggeredOnStart = false;
                dataProviderTimer.start();
            } else {
                dataProviderTimer.triggeredOnStart = true;
                dataProviderTimer.start();
            }
        }

        Timer {
            id: dataProviderTimer
            interval: 100
            triggeredOnStart: true
            onTriggered: {
                if (!!dataProvider.objs) {
                    dataProvider._objs = dataProvider.objs;
                    if (root.visible) {
                        dataProvider.visible = root.visible;
                    }
                }
            }
        }

        params: ({
                     obj: _objs,
                     field: stockTable.requestFields
                 })

        onSuccess: {

            // 当页数据响应回来后缓加载冗余数据
            root.cacheLoad();

            // 更新缓存
            data.forEach(function(eachData) {
                root.cache[eachData.Obj] = eachData;
            });
            stockTable.updateModel();
        }
    }

    function cacheLoad() {
        if (root.cacheLoadOpimizeEnabled) {

            // 计算当前页上一页和下一页中尚未缓存的数据Obj，一次性请求后做缓存
            var start = stockTable.startIndex;
            var count = stockTable.showRowCount;

            var objs = stockTable.model
            .slice(Math.max(0, start - count), start)
            .concat(stockTable.model.slice(start + count, start + count * 2))
            .filter(function(eachData) { return !root.cache[eachData.Obj] })
            .map(function(eachData) { return eachData.Obj })
            if (objs.length > 0) {
                var params = Util.assign({}, dataProvider.params);
                params.obj = objs;
                DataChannel.query(dataProvider.serviceUrl, params, function(data) {

                    if (data && !(data instanceof Error)) {

                        // 更新缓存
                        data.forEach(function(eachData) {
                            root.cache[eachData.Obj] = eachData;
                        });
                        stockTable.updateModel();
                    }
                });
            }
        }
    }

    // 指数板块相关
    // 展开的板块的obj
    property var extendedObj

    // 用于记录板块的obj在整个指数列表中的位置
    property int extendedIndex

    // 板块成分股对应的列表
    property var blockStockList: []

    DataProvider {
        id: blockStockListDataProvider
        property string blockFullName
        serviceUrl: '/stkdata'
        sub: 1
        autoQuery: false
        params: ({
                     gql: 'block=' + blockFullName,
                     mode: 2,
//                     field: ['ZhongWenJianCheng'],
                     orderBy: stockTable.orderByColumn ? stockTable.orderByColumn.orderByFieldName : undefined,
                     desc: stockTable.orderByColumn ? stockTable.orderByColumn.desc : undefined
                 })
        onSuccess: {
            root._focusObjPostion = true;

            // 排序状态变化后重新定位
            if (root.extendedIndex !== -1 && root.orderByChanged) {
                stockTable.positionRow(root.extendedIndex);
                root.orderByChanged = false;
            }

            root.blockStockList = data;
            stockTable.updateModel();

            root.positionFocusObj();
            root._focusObjPostion = false;
        }
    }

    onExtendedObjChanged: {

        // 固定点击展开的指数板块位置
        var index = 0;
        stockList.some(function(eachData, i) {
            if (eachData.Obj === extendedObj) {
                index = i;
                return true;
            }
        });

        var lastBlockListLength = blockStockList.length;

        // 选中取消
        stockTable.selectedIds = [];

        // 展开的板块变化时，将成分股列表清空后，重新订阅查询对应的板块指数成分股
        blockStockList = [];

        // 停止板块成分股数据的订阅
        blockStockListDataProvider.cancel();
        blockStockListDataProvider.autoQuery = false;

        // 展开的板块的obj不为空时重新订阅对应板块成分股数据
        if (extendedObj) {

            // 重新定位到点击的指数板块位置
            if (index > extendedIndex) {
                stockTable.positionRow(stockTable.startIndex - lastBlockListLength);
            }
            extendedIndex = index;

            // 指数列表排序字段固定
            stockListOrderByColumn = stockListOrderByColumn;
            stockListOrderByDesc = stockListOrderByColumn ? stockListOrderByColumn.desc : false;

            // 请求到板块全路径后查询订阅
            BlockUtil.getBlockFullName(extendedObj, function(fullName) {
                blockStockListDataProvider.blockFullName = fullName;
                blockStockListDataProvider.query();
                blockStockListDataProvider.autoQuery = true;
            });
        } else {
            extendedIndex = -1;

            // 还原指数列表排序字段，并且重新绑定
            stockTable.orderByColumn = stockListOrderByColumn;
            if (stockListOrderByColumn) {
                stockTable.orderByColumn.desc = stockListOrderByDesc;
            }
            stockListOrderByColumn = Qt.binding(function() { return stockTable.orderByColumn });
            stockListOrderByDesc = Qt.binding(function() { return stockListOrderByColumn ? stockListOrderByColumn.desc : false });

            // 避免查询后跳回表头
            orderByChanged = false;
        }
        stockTable.updateModel();
    }

    property string orderBy: stockTable.orderByColumn ? stockTable.orderByColumn.field + stockTable.orderByColumn.desc : ''
    property bool orderByChanged
    onOrderByChanged: {

        // 表格排序字段变化时记录变化状态（用于更新数据后重新定位）
        orderByChanged = true;
    }

    Rectangle {
        id: container
        anchors.fill: parent
        RowLayout {
            anchors.fill: parent
            spacing: 0
            StockTable {
                id: stockTable

                Layout.fillHeight: true
                Layout.fillWidth: true

                changeOrderByToTop: false

                function updateModel() {
                    var cache = root.cache;
                    var stockList = root.stockList.map(function(eachData, index) {
//                        var result = cache[eachData.Obj] || eachData;
//                        result.XuHao = index + 1;
//                        return result;
                        return Object.create(cache[eachData.Obj] || eachData, {
                                          XuHao: {value: index + 1}
                                      });
                    });

                    if (extendedIndex >= 0) {
                        var blockStockList = root.blockStockList.map(function(eachData, index) {

                            return Object.create(cache[eachData.Obj] || eachData, {
                                              XuHao:  {value: index + 1},
                                              _blockStock:  {value: true, enumerable: true}
                                          });
                        });
                        blockStockList.unshift(extendedIndex + 1, 0);
                        Array.prototype.splice.apply(stockList, blockStockList);
                    }
                    stockTable.model = stockList;
                }

                onVisibleChanged: {
                    if (visible && root.focusAvailable) {
                        stockTable.forceActiveFocus();
                    }
                }

                property StockTableColumn _defaultOrderColumn: tableHeaderType===2 ? columns[5] : columns[6]
                property bool _defaultOrderColumnDesc: _defaultOrderColumn.desc

                Component.onCompleted: {
                    if (visible && root.focusAvailable) {
                        stockTable.forceActiveFocus();
                    }

                    // 记录默认状态
                    _defaultOrderColumn = _defaultOrderColumn;
                    _defaultOrderColumnDesc = _defaultOrderColumnDesc;
                }

                // 重置表格状态，偏序字段还原默认排序，表格滚动回原位
                function reset() {
                    timer.interval = 1;
                    orderByColumn = _defaultOrderColumn;
                    if (orderByColumn) {
                        orderByColumn.desc = _defaultOrderColumnDesc;
                    }

                    toTop();
                    toLeft();
                }

                function getRowBackground(state, rowData, rowIndex) {
                    return {'selected': '#d0e1f1', 'hovered': '#ecf2ff'}[state] || (rowData._blockStock ? '#e6f0ff' : 'transparent');
                }

                // 财务字段对应格式化（添加财报期标志）
                function formatFinance(rowData, column) {
                    var field = column.field;
                    var data = rowData[field];
                    var formatData = rowData[field + '_format'] || data || '--';
                    var date = rowData['BaoGaoQi'];
                    if (data != null && date != null) {

                        // 判断报告期属于那个季度
                        var month = DateUtil.moment(date, 'YYYYMMDDhhmmss').month() + 1;
                        var season = parseInt(month / 4);

                        return formatData + ['①', '②', '③', '④'][season];
                    }
                    return formatData;
                }

                // 全部要显示的字段
                property list<StockTableColumn> defaultColumns: [
                    StockTableColumn {
                        fixed: true
                        resizable: false
                        sortable: false
                        request: false
                        visible: root.isBlockType
                        width: 30
                        _tableCellComponent: MouseArea {
                            visible: rowData._blockStock !== true
                            Text {
                                anchors.centerIn: parent
                                text: rowData.Obj === root.extendedObj ? '-' : '+'
                            }
                            onPressed: {

                                // 避免数据延时处理，将处理数据定时器的时延重置成1
                                stockTable.timer.interval = 1;
                                if (rowData.Obj === root.extendedObj) {
                                    root.extendedObj = null;
                                } else {
                                    root.extendedObj = rowData.Obj;
                                }
                            }
                        }
                    },
                    StockTableColumn {field: 'XuHao'; title: '序号'; width: 60; fixed: true; resizable: false; sortable: false; request: false; precision: 0; useDefault: false; align: Qt.AlignHCenter; textColor: theme.normalColor;},
                    StockTableColumn {
                        field: 'Obj'; title: '代码'; width: 100; fixed: true; request: false; orderByFieldName: 'JiaoYiDaiMa'; align: Qt.AlignHCenter;
                        function format(rowData) {

                            // 格式化代码，去掉前两位的市场
                            return (rowData.Obj || '').slice(2);
                        }
                    },
                    StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; fixed: true; align: Qt.AlignHCenter;},
                    StockTableColumn {field: 'ZuiXinJia'; title: '最新'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangDie'; title: '涨跌'; updownStyle: true; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'ChengJiaoLiang'; title: '总手'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.volColor;},
                    StockTableColumn {field: 'HuanShou'; title: '换手率%'; textColor: theme.volColor; precision: 2;},
                    StockTableColumn {field: 'XianShou'; title: '现手'; isVolume: true; isAutoPrec: true; unit: '万/亿'; updownStyle: true; relateField: 'ZuiXinJia'; compareField: 'last';},
                    StockTableColumn {field: 'ChengJiaoE'; title: '成交额'; isAutoPrec: true; unit: '万/亿'; textColor: theme.volColor;},
                    StockTableColumn {field: 'FenZhongZhangFu5'; title: '涨速%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'ZuoShou'; title: '昨收';},
                    StockTableColumn {field: 'KaiPanJia'; title: '开盘'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZuiGaoJia'; title: '最高价'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZuiDiJia'; title: '最低价'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'HangYe'; title: '行业'; visible: !root.isBlockType ; request: !root.isBlockType;},
                    StockTableColumn {field: 'ShiYingLv'; title: '市盈率'; textColor: theme.dynaComponentDynaColor; precision: 2; function format(rowData) { return stockTable.formatFinance(rowData, this) }},
                    StockTableColumn {field: 'ShiJingLv'; title: '市净率'; textColor: theme.dynaComponentDynaColor; precision: 2;},
                    StockTableColumn {field: 'ShiXiaoLv'; title: '市销率'; textColor: theme.dynaComponentDynaColor; precision: 2; function format(rowData) { return stockTable.formatFinance(rowData, this) }},
                    StockTableColumn {field: 'WeiTuoMaiRuJia1'; title: '委买价'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'WeiTuoMaiChuJia1'; title: '委卖价'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'NeiPan'; title: '内盘'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.greenColor; isAbs: true;},
                    StockTableColumn {field: 'WaiPan'; title: '外盘'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.redColor; isAbs: true;},
                    StockTableColumn {field: 'ZhenFu'; title: '振幅%'; textColor: theme.volColor; precision: 2;},
                    StockTableColumn {field: 'LiangBi'; title: '量比'; textColor: theme.volColor; precision: 2;},
                    StockTableColumn {field: 'JunJia'; title: '均价'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'WeiBi'; title: '委比%'; updownStyle: true; precision: 2;},
                    StockTableColumn {field: 'WeiCha'; title: '委差'; updownStyle: true; isAutoPrec: true; unit: '万/亿';},
                    StockTableColumn {field: 'ZongShiZhi'; title: '总市值'; isAutoPrec: true; unit: '万/亿'; ratio: 10000; textColor: theme.dynaComponentDynaColor;},
                    StockTableColumn {field: 'LiuTongShiZhi'; title: '流通市值'; isAutoPrec: true; unit: '万/亿'; ratio: 10000; textColor: theme.dynaComponentDynaColor;},
                    StockTableColumn {field: 'BaoGaoQi'; visible: false;},

                    // 股票缓存需要用字段，跟着列表一起请求
                    StockTableColumn {field: 'LeiXing'; visible: false;},
                    StockTableColumn {field: 'RongZiRongQuanBiaoJi'; visible: false;},
                    StockTableColumn {field: 'LiuTongAGu'; visible: false;},
                    StockTableColumn {field: 'XiaoShuWei'; visible: false;},
                    StockTableColumn {field: 'ChengJiaoLiangDanWei'; visible: false;}
                ]

                property list<StockTableColumn> ziJinFenXiColumns: [
                    StockTableColumn {field: 'XuHao'; title: '序号'; height: 40; width: 60; fixed: true; resizable: false; sortable: false; request: false; precision: 0; useDefault: false; align: Qt.AlignHCenter;},
                    StockTableColumn {
                        field: 'Obj'; title: '代码'; width: 100; fixed: true; request: false; orderByFieldName: 'JiaoYiDaiMa'; align: Qt.AlignHCenter;
                        function format(rowData) {

                            // 格式化代码，去掉前两位的市场
                            return (rowData.Obj || '').slice(2);
                        }
                    },
                    StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; fixed: true; align: Qt.AlignHCenter;},
                    StockTableColumn {field: 'ZuiXinJia'; title: '最新'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; updownStyle: true; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'DDXJinRi'; title: 'DDX'; updownStyle: true; precision: 3; groupTitle: "当日资金流"},
                    StockTableColumn {field: 'DDXJinRi'; title: 'DDY'; updownStyle: true; precision: 3; groupTitle: "当日资金流"},
                    StockTableColumn {field: 'DDXJinRi'; title: 'DDZ'; updownStyle: true; precision: 3; groupTitle: "当日资金流"},
                    StockTableColumn {field: 'DDX5Ri'; title: '5日DDX'; updownStyle: true; precision: 3; groupTitle: "五日资金流"},
                    StockTableColumn {field: 'DDY5Ri'; title: '5日DDY'; updownStyle: true; precision: 3; groupTitle: "五日资金流"},
                    StockTableColumn {field: 'DDX60Ri'; title: '60日DDX'; updownStyle: true; precision: 3; groupTitle: "中线资金流"},
                    StockTableColumn {field: 'DDY60Ri'; title: '60日DDY'; updownStyle: true; precision: 3; groupTitle: "中线资金流"},
                    StockTableColumn {field: 'DDXPiaoHongTianShu10'; title: '10日内'; updownStyle: true; groupTitle: "DDX飘红天数"},
                    StockTableColumn {field: 'DDXLianXuPiaoHongTianShu'; title: '连续'; updownStyle: true; groupTitle: "DDX飘红天数"},
                    StockTableColumn {field: 'MaiRuTeDaDanBiLi'; title: '特大买入'; updownStyle: true;},
                    StockTableColumn {field: 'MaiChuTeDaDanBiLi'; title: '特大卖出'; updownStyle: true;},
                    StockTableColumn {field: 'MaiRuDaDanBiLi'; title: '大单买入'; updownStyle: true;},
                    StockTableColumn {field: 'MaiChuDaDanBiLi'; title: '大单卖出'; updownStyle: true;},
                    StockTableColumn {field: 'LeiXing'; visible: false;},
                    StockTableColumn {field: 'RongZiRongQuanBiaoJi'; visible: false;},
                    StockTableColumn {field: 'LiuTongAGu'; visible: false;},
                    StockTableColumn {field: 'XiaoShuWei'; visible: false;},
                    StockTableColumn {field: 'ChengJiaoLiangDanWei'; visible: false;},

                    StockTableColumn {field: 'ZuoShou'; visible: false;}
                ]

                property list<StockTableColumn> fundColumns: [
                    StockTableColumn {
                        fixed: true
                        resizable: false
                        sortable: false
                        request: false
                        visible: root.isBlockType
                        width: 30
                        _tableCellComponent: MouseArea {
                            visible: rowData._blockStock !== true
                            Text {
                                anchors.centerIn: parent
                                text: rowData.Obj === root.extendedObj ? '-' : '+'
                            }
                            onPressed: {

                                // 避免数据延时处理，将处理数据定时器的时延重置成1
                                stockTable.timer.interval = 1;
                                if (rowData.Obj === root.extendedObj) {
                                    root.extendedObj = null;
                                } else {
                                    root.extendedObj = rowData.Obj;
                                }
                            }
                        }
                    },
                    StockTableColumn {field: 'XuHao'; title: '序号'; width: 60; fixed: true; resizable: false; sortable: false; request: false; precision: 0; useDefault: false; align: Qt.AlignHCenter;},
                    StockTableColumn {
                        field: 'Obj'; title: '代码'; width: 100; fixed: true; request: false; orderByFieldName: 'JiaoYiDaiMa'; align: Qt.AlignHCenter;
                        function format(rowData) {

                            // 格式化代码，去掉前两位的市场
                            return (rowData.Obj || '').slice(2);
                        }
                    },
                    StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; fixed: true; align: Qt.AlignHCenter;},
                    StockTableColumn {field: 'ZuiXinJia'; title: '最新'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangDie'; title: '涨跌'; updownStyle: true; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'ChengJiaoLiang'; title: '总手'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.volColor;},
                    StockTableColumn {field: 'ChengJiaoE'; title: '总额'; isAutoPrec: true; unit: '万/亿'; textColor: theme.volColor;},
                    StockTableColumn {field: 'FenZhongZhangFu5'; title: '涨速%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'LiangBi'; title: '量比'; textColor: theme.volColor; precision: 2;},
                    StockTableColumn {field: 'XianShou'; title: '现手'; isVolume: true; isAutoPrec: true; unit: '万/亿'; updownStyle: true; relateField: 'ZuiXinJia'; compareField: 'last';},
                    StockTableColumn {field: 'WeiTuoMaiRuLiang1'; title: '买一量'; isAutoPrec: true; isVolume: true; textColor: theme.volColor;},
                    StockTableColumn {field: 'WeiTuoMaiRuJia1'; title: '买一价'; updownStyle: true; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'WeiTuoMaiChuJia1'; title: '卖一价'; updownStyle: true; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'WeiTuoMaiChuLiang1'; title: '卖一量'; isAutoPrec: true; isVolume: true; textColor: theme.volColor;},
                    StockTableColumn {field: 'ZuoShou'; title: '昨收';},
                    StockTableColumn {field: 'KaiPanJia'; title: '今开'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZuiGaoJia'; title: '最高'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZuiDiJia'; title: '最低'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZhenFu'; title: '振幅%'; textColor: theme.volColor; precision: 2;},
                    StockTableColumn {field: 'JunJia'; title: '均价'; updownStyle: true; compareField: 'ZuoShou'; },
                    StockTableColumn {field: 'WeiBi'; title: '委比%'; updownStyle: true; precision: 2;},
                    StockTableColumn {field: 'WeiCha'; title: '委差'; updownStyle: true; isAutoPrec: true; unit: '万/亿';},
                    StockTableColumn {field: 'WaiPan'; title: '外盘'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.redColor; isAbs: true;},
                    StockTableColumn {field: 'NeiPan'; title: '内盘'; isVolume: true; isAutoPrec: true; unit: '万/亿'; textColor: theme.greenColor; isAbs: true;},

                    // 股票缓存需要用字段，跟着列表一起请求
                    StockTableColumn {field: 'LeiXing'; visible: false;},
                    StockTableColumn {field: 'RongZiRongQuanBiaoJi'; visible: false;},
                    StockTableColumn {field: 'LiuTongAGu'; visible: false;},
                    StockTableColumn {field: 'XiaoShuWei'; visible: false;},
                    StockTableColumn {field: 'ChengJiaoLiangDanWei'; visible: false;}
                ]

                // 常用指数要显示的字段
                property list<StockTableColumn> cyinxColumns: [
                    StockTableColumn {field: 'XuHao'; title: '序号'; width: 60; fixed: true; resizable: false; sortable: false; request: false; precision: 0; useDefault: false; align: Qt.AlignHCenter; textColor: theme.normalColor;},
                    StockTableColumn {
                        field: 'Obj'; title: '代码'; width: 100; fixed: true; request: false; orderByFieldName: 'JiaoYiDaiMa'; align: Qt.AlignHCenter;
                        function format(rowData) {

                            // 格式化代码，去掉前两位的市场
                            return (rowData.Obj || '').slice(2);
                        }
                    },
                    StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; fixed: true; align: Qt.AlignHCenter;},
                    StockTableColumn {field: 'ZuiXinJia'; title: '最新'; updownStyle: true; compareField: 'ZuoShou'; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangDie'; title: '涨跌'; updownStyle: true; highlightPolicy: 'updown';},
                    StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'ZuoShou'; title: '昨收';},
                    StockTableColumn {field: 'KaiPanJia'; title: '开盘'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZuiGaoJia'; title: '最高价'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'ZuiDiJia'; title: '最低价'; updownStyle: true; compareField: 'ZuoShou';},
                    StockTableColumn {field: 'DangZhouZhangFu'; title: '本周涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'DangYueZhangFu'; title: '本月涨幅%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},
                    StockTableColumn {field: 'DangNianZhangFu'; title: '今年以来%'; updownStyle: true; highlightPolicy: 'updown'; precision: 2;},


                    // 股票缓存需要用字段，跟着列表一起请求
                    StockTableColumn {field: 'LeiXing'; visible: false;},
                    StockTableColumn {field: 'RongZiRongQuanBiaoJi'; visible: false;},
                    StockTableColumn {field: 'LiuTongAGu'; visible: false;},
                    StockTableColumn {field: 'XiaoShuWei'; visible: false;},
                    StockTableColumn {field: 'ChengJiaoLiangDanWei'; visible: false;}
                ]


                columns: {
                    if (root.tableHeaderType === 4) {
                        return cyinxColumns;
                    } else if (root.tableHeaderType === 3) {
                        return fundColumns
                    } else {
                        return tableHeaderType===2 ? ziJinFenXiColumns : defaultColumns
                    }
                }

                // 初始排序
                orderByColumn: _defaultOrderColumn

                property string selectedObj: selectedIds[0] || ''

                function getDetailUrl(obj) {
                    var params = {obj: obj};
                    if (market === '31') {

                        // 判断obj是否指数
                        if (stockList.some(function(eachData) { return eachData.Obj === obj })) {
                            params.type = 4;
                            params.market = 'B$';
                            params.orderBy = root.stockListOrderByColumn ? root.stockListOrderByColumn.orderByFieldName : 'JiaoYiDaiMa';
                            params.desc = root.stockListOrderByColumn ? root.stockListOrderByColumn.desc : false;
                        } else {
                            params.type = 5;
                            params.market = extendedObj;
                            params.orderBy = root.stockListOrderByColumn ? root.stockListOrderByColumn.orderByFieldName : 'JiaoYiDaiMa';
                            params.desc = root.stockListOrderByColumn ? root.stockListOrderByColumn.desc : false;
                        }
                    } else {

                        // 判断是否为基金
                        if (appConfig.marketTypeMap[root.market] === 5) {
                            params.type = 6;
                        } else {
                            params.type = root.type;
                        }

                        params.market = root.market;
                        params.orderBy = root.stockListOrderByColumn ? root.stockListOrderByColumn.orderByFieldName : 'JiaoYiDaiMa';
                        params.desc = root.stockListOrderByColumn ? root.stockListOrderByColumn.desc : false;
                    }

                    var val;
                    return [appConfig.routePathStockDetail, Object.keys(params)
                    .map(function(key) { return (val = params[key]) != null ? [key, val].join('=') : null })
                    .filter(function(param) { return !!param })
                    .join('&')].join('?');
                }

                onDoubleClicked: {
                    root.context.pageNavigator.push(stockTable.getDetailUrl(row.Obj));
                }

                onStockDragSorted: {
                    //排序信号
                    root.stockDragSorted(srcObj, destObj, isFront);
                }

                Keys.onPressed: {
                    if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && stockTable.selectedObj !== '') {
                        root.context.pageNavigator.push(stockTable.getDetailUrl(stockTable.selectedObj));
                        event.accepted = true;
                    } else if (event.key === Qt.Key_F10){
                        if (stockTable.selectedObj !== '') {
                            StockUtil.getStockType(stockTable.selectedObj, function(type) {
                                if ([1, 10, 11].indexOf(type) !== -1) {
                                    root.context.pageNavigator.push(stockTable.getDetailUrl(stockTable.selectedObj), {'chart':'f10'});
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
                    createMenuItem(f10ContextMenuItem, {
                                       visible: function(item) {
                                           return stockTable.selectedIds.length > 0 && ([1, 10, 11].indexOf(StockUtil.getStockType(item.obj)) !== -1);
                                       },
                                       triggered: function(item) {
                                           root.context.pageNavigator.push(stockTable.getDetailUrl(item.obj) + '&chart=f10');
                                       },
                                       obj: stockTable.selectedIds[0]
                                   })
                ]}
            }
            SeparatorLine {
                Layout.fillHeight: true
                Layout.fillWidth: false
                length: height
            }

            RightSideBar {
                id: rightSideBar
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.preferredWidth: 260
                sideBarType: 1

                obj: stockTable.selectedObj
                visible: root.showRightSideBar && selectedObj !== ''
            }
        }
    }

    onReconnect: {

        // 重连后设置页面可见状态，重新请求数据
        root.visible = false;
        root.visible = true;
    }
}
