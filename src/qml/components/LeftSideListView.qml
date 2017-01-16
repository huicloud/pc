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
import "../components"
import "../controls"
import "../js/Util.js" as Util
import QtGraphicalEffects 1.0

ContextComponent {
    id: root

    //外部传入的obj
    property string obj: ""

    property var model

    property int pageSize: Math.ceil(root.height / theme.stockListRowHeight);
    property double rowHeight: root.height / pageSize

    property var cache: ({})

    property string selectObj: stockTable.selectedObj
    property string firstObj: stockTable.model[0] ? stockTable.model[0].Obj : ""

    property int selectIndex: {
        var index = -1;
        stockTable.model.some(function(eachData, i) {
            if (eachData.Obj === selectObj) {
                index = i;
                return true;
            }
        });
        return index;
    }

    onSelectObjChanged: {
        obj = selectObj;
    }

    function nextOne() {
        if (selectIndex === -1) {
            stockTable.selectedIds = [firstObj];
        } else if (!stockTable.currentRowData && (selectIndex + 1) < stockTable.model.length) {

            // 当前选中股票没有显示时，直接选中下一个股票
            stockTable.selectedIds = [stockTable.model[selectIndex + 1].Obj];
        } else {
            stockTable.nextOne();
        }
    }

    function prevOne() {
        if (selectIndex === -1) {
            stockTable.selectedIds = [firstObj];
        } else if (!stockTable.currentRowData && selectIndex > 0) {
            stockTable.selectedIds = [stockTable.model[selectIndex - 1].Obj];
        } else {
            stockTable.prevOne();
        }
    }

    function toTop() {
        stockTable.toTop();
    }

    function positionSelectObj() {
        var inShowData = stockTable.showRowData.some(function(eachData) {
            return eachData.Obj === selectObj;
        });

        if (!inShowData) {

            if (selectIndex !== -1) {
                var length = stockTable.model.length;
                var showDataLength = stockTable.showRowData.length;
                var startIndex = selectIndex - parseInt(showDataLength / 2);
                startIndex = Math.min(length - showDataLength, Math.max(0, startIndex));
                stockTable.positionRow(startIndex);

            }
        }
    }

    onSelectIndexChanged:  {
        positionSelectObj();
    }

    onObjChanged: {
        if (root.obj && root.obj.length>0) {
            if (stockTable.selectedIds.indexOf(root.obj) < 0) {
                stockTable.selectedIds = [root.obj];
            }
        }
    }

    DataProvider {
        id: dataProvider
        parent: root
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
                    dataProvider.visible = root.visible;
                }
            }
        }

        params: ({
                     obj: _objs,
                     field: stockTable.requestFields
                 })
        onSuccess: {
            var map = {};
            data.forEach(function(eachData) {
                map[eachData.Obj] = eachData;
            });

            root.cache = Util.assign({}, root.cache, map);

        }
    }

    StockTable {
        id: stockTable
        minimumRowHeight: root.rowHeight
        anchors.fill: parent
        showTableHeader: false
        _scrollView.horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        _scrollView.verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        model: {
            return root.model.map(function(eachData, index) {
                var result = cache[eachData.Obj] || eachData;
                return result;
            });
        }

        columns: [
            StockTableColumn {field: 'ZhongWenJianCheng'; title: '名称'; },
            StockTableColumn {field: 'ZuiXinJia'; title: '最新'; },
            StockTableColumn {field: 'ZhangDie'; title: '涨跌'; },
            StockTableColumn {field: 'ZhangFu'; title: '涨幅%'; },
            StockTableColumn {field: 'XiaoShuWei'; visible: false;}
        ]

        property string selectedObj: selectedIds[0] || ''

        rowComponent: stockRowComponent

        onRightClicked: {
            mouse.accepted = true;
        }

    }

    Component {
        id: stockRowComponent

        Rectangle {
            id: stockItem
            property bool isHover: false;
            property string obj: rowData["Obj"] ? rowData["Obj"] : ""
            property real prePrice
            property real currPrice: rowData["ZuiXinJia"] ? rowData["ZuiXinJia"] : 0
            property int zhangdie: 0

            onObjChanged: {
                prePrice = 0;
            }

            onCurrPriceChanged: {
                if (prePrice !== 0) {
                    zhangdie = currPrice>prePrice ? 1 : (currPrice<prePrice ? -1 : 0);
                }
                prePrice = currPrice;
            }

            onZhangdieChanged: {
                if (zhangdie !== 0) {
                    background.color = zhangdie > 0 ? '#ffcece' : '#b1f7a8';
                    background.opacity = 1;
                }
            }

            height: rowHeight
            color: isHover ? theme.stockListRowHoverColor : selected ? theme.stockListRowSelectColor : (rowIndex%2==0?theme.stockListRowEvenColor:theme.stockListRowOddColor)
            BaseComponent {
                anchors.fill: parent;

                contextMenuItems: [
                    createMenuItem(portfolioContextMenuItem, {obj: stockItem.obj}),
                    createMenuItem(f10ContextMenuItem, {obj: stockItem.obj})
                ]

                MouseArea {
                    anchors.fill: parent;
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    propagateComposedEvents: true
                    onClicked: {
                        stockTable.selectedIds = [rowData["Obj"]];
                        root.context.pageNavigator.push(appConfig.routePathStockDetail, {'obj':rowData['Obj']});
                    }
                    onEntered: {
                        stockItem.isHover = true;
                    }
                    onExited: {
                        stockItem.isHover = false;
                    }
                }
            }

            LinearGradient {
                id: background
                property color color
                anchors.fill: parent
                opacity: 0
                start: Qt.point(0, 0)
                end: Qt.point(width, 0)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: 'white' }
                    GradientStop { position: 1.0; color: background.color }
                }

                HighlightAnimation {
                    id: highlightAnimation
                    target: background

                    // 避免数据不变情况下重复显示高亮效果，在执行结束后将数据清除
                    onRunningChanged: {
                        if (!running) {
                            zhangdie = 0;
                        }
                    }
                }

            }

            StockLabel {
                id: stockName
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: theme.stockListFontLeftMargin
                width: parent.width / 2
                height: parent.height / 2
                verticalAlignment: Text.AlignBottom
                color: theme.textColor
                text: rowData["ZhongWenJianCheng"] ? rowData["ZhongWenJianCheng"] : ""
            }

            StockLabel {
                id: stockCode
                anchors.top: stockName.bottom
                anchors.topMargin: theme.stockListFontTopMargin
                anchors.left: parent.left
                anchors.leftMargin: theme.stockListFontLeftMargin
                width: parent.width / 2
                height: parent.height / 2
                color: theme.normalColor
                verticalAlignment: Text.AlignTop
                text: rowData["Obj"] ? rowData["Obj"].substr(2) : "--"
            }

            StockLabel {
                id: stockZuiXinJia
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: theme.stockListFontRightMargin
                verticalAlignment: Text.AlignBottom
                horizontalAlignment: Text.AlignRight
                width: parent.width / 2
                height: parent.height / 2
                zhangdie: rowData["ZhangDie"] ? rowData["ZhangDie"] : 0

                property int precision: rowData.XiaoShuWei || 2
                text: rowData["ZuiXinJia"] ? rowData["ZuiXinJia"].toFixed(precision) : "--"
            }

            StockLabel {
                id: stockZhangFu
                anchors.top: stockZuiXinJia.bottom
                anchors.topMargin: theme.stockListFontTopMargin
                anchors.right: parent.right
                anchors.rightMargin: theme.stockListFontRightMargin
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                width: parent.width / 2
                height: parent.height / 2
                zhangdie: rowData["ZhangDie"] ? rowData["ZhangDie"] : 0
                text: {
                    var d = rowData["ZhangFu"];

                    if (d === 0) {
                        d = "0.00%"
                    } else if (d) {
                        d = d.toFixed(2) + '%';
                    } else {
                        d = "--"
                    }

                    return d;
                }
            }
        }
    }

}
