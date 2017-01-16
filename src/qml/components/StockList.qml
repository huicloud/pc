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
import QtQuick.Controls 1.4

import "../core"
import "../core/data"
import "../controls"
import "../js/Util.js" as Util

BaseComponent {
    id: root;

//    Component {
//        id: column
//    }
    Component {
        id: stockTableColumn
        StockTableColumn {

        }
    }

    function createColumn(field, title, width, fixed, sortable, orderByFieldName) {
        return stockTableColumn.createObject(0, {field: field, title: title, width: width || 80, fixed: fixed || false, sortable: sortable !== false ? true : false, desc: null, orderByFieldName: orderByFieldName || field});
//        return {field: field, title: title, width: width || 80, fixed: fixed || false, sortable: sortable !== false ? true : false, desc: null, orderByFieldName: orderByFieldName || field};
    }

    property alias _flicker: scrollView.flickableItem

    property string blockFullName: '股票/市场分类/全部A股'

    // 全部要显示的字段
    property var _columns: [
        createColumn('XuHao', '序号', 40, true, false),
        createColumn('Obj', '代码', null, true, true, 'JiaoYiDaiMa'),
        createColumn('ZhongWenJianCheng', '名称', 100, true),
        createColumn('ZuiXinJia', '最新'),
        createColumn('ZhangDie', '涨跌'),
        createColumn('ZhangFu', '涨幅'),
        createColumn('ChengJiaoLiang', '成交价'),
        createColumn('HuanShou', '换手'),
        createColumn('XianShou', '现手'),
        createColumn('ChengJiaoE', '成交额'),
        createColumn('FenZhongZhangFu5', '涨速'),
        createColumn('ZuoShou', '最新'),
        createColumn('KaiPanJia', '最新'),
        createColumn('ZuiGaoJia', '最新'),
        createColumn('ZuiDiJia', '最新'),
        createColumn('HangYe', '最新'),
        createColumn('ShiYingLv', '最新'),
        createColumn('ShiJingLv', '最新'),
        createColumn('ShiXiaoLv', '最新'),
        createColumn('WeiTuoMaiRuJia1', '最新'),
        createColumn('WeiTuoMaiChuJia1', '最新'),
        createColumn('NeiPan', '最新'),
        createColumn('WaiPan', '最新'),
        createColumn('ZhenFu', '最新'),
        createColumn('LiangBi', '最新'),
        createColumn('JunJia', '最新'),
        createColumn('WeiBi', '最新'),
        createColumn('WeiCha', '最新'),
//        createColumn('ChengJiaoBiShu', '最新'),
//        createColumn('ChengJiaoFangXiang', '最新'),
        createColumn('ZongShiZhi', '最新'),
        createColumn('LiuTongShiZhi', '流通市值'),
    ]

    // 需要查询的字段
    property var fields: _columns.map(function(eachColumn) { return eachColumn.field }).filter(function(field) {return field !== 'Obj' && field !== 'XuHao'})

    // 总宽度
    property real contentWidth: _columns.reduce(function(preValue, eachColumn){ return preValue + eachColumn.width }, 0)

    // 需要展示的列，根据宽度计算出（前几列固定）
    property var columns: {
        var width = root.width;
        var offsetWidth = _flicker.visibleArea.xPosition * contentWidth;
        var hasLast = true;
        return _columns.filter(function(eachColumn) {
            if (eachColumn.fixed) {
                width -= eachColumn.width;
                return true;
            } else if (offsetWidth > eachColumn.width) {
                offsetWidth -= eachColumn.width;
                return false;
            }
//            offsetWidth -= eachColumn.width;
            width -= eachColumn.width;
            if (width >= 0) {
                return true;
            } else if (hasLast) {
                hasLast = false;
                return true;
            }
            return false;
        });
    }

    property var sortColumn: root._columns[5]
    property bool sortDesc: true

    onSortColumnChanged: {
        root._columns.map(function(eachColumns) {
            if (eachColumns !== root.sortColumn) {
                eachColumns.desc = null;
            }
            return eachColumns;
        });
    }

//    MouseArea {
//                id: delegateRoot

//                property int visualIndex: DelegateModel.itemsIndex

//                width: 80; height: 80
//                drag.target: icon

//                Rectangle {
//                    id: icon
//                    width: 72; height: 72
//                    anchors {
//                        horizontalCenter: parent.horizontalCenter;
//                        verticalCenter: parent.verticalCenter
//                    }
//                    color: model.color
//                    radius: 3

//                    Drag.active: delegateRoot.drag.active
//                    Drag.source: delegateRoot
//                    Drag.hotSpot.x: 36
//                    Drag.hotSpot.y: 36

//                    states: [
//                        State {
//                            when: icon.Drag.active
//                            ParentChange {
//                                target: icon
//                                parent: root
//                            }

//                            AnchorChanges {
//                                target: icon;
//                                anchors.horizontalCenter: undefined;
//                                anchors.verticalCenter: undefined
//                            }
//                        }
//                    ]
//                }

//                DropArea {
//                    anchors { fill: parent; margins: 15 }

//                    onEntered: visualModel.items.move(drag.source.visualIndex, delegateRoot.visualIndex)
//                }
//            }


    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        clip: true
        Rectangle {
            id: tableHeader
            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.preferredWidth: parent.width
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Repeater {
                    id: repeater
                    property int dragIndex: -1
                    property int targetIndex: -1
                    model: root.columns
                    Rectangle {
                        id: column
                        property real columnWidth: modelData.width
                        Layout.fillHeight: true
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: columnWidth
                        color: index === repeater.targetIndex || dragArea.containsMouse ? '#ecf2ff' : 'transparent'
                        Loader {
                            anchors.fill: parent
                            sourceComponent: modelData.__headerComponent
                        }

                        Rectangle {
                            id: dragItem
                            color: '#ecf2ff'
                            parent: Drag.active ? tableHeader : column
                            anchors.top: parent.top
                            height: column.height
                            width: column.width
                            visible: Drag.active
                            opacity: 0.6
                            Drag.active: modelData.fixed !== true && dragArea.drag.active
                            Loader {
                                anchors.fill: parent
                                sourceComponent: modelData.__dragComponent
                            }
                        }
                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            drag.target: dragItem
                            hoverEnabled: true
                            drag.onActiveChanged: {
                                if (drag.active) {
                                    repeater.dragIndex = index;
                                }
                            }

                            onReleased: {
                                var dragIndex = repeater.dragIndex;
                                var targetIndex = repeater.targetIndex;

                                dragItem.x = 0;
                                repeater.dragIndex = -1;
                                repeater.targetIndex = -1;

                                if (dragIndex !== -1 && targetIndex !== -1) {
                                    var dragColumn = root.columns[dragIndex];
                                    var targetColumn = root.columns[targetIndex];

                                    var dragColumnIndex = root._columns.indexOf(dragColumn);
                                    root._columns.splice(dragColumnIndex, 1);
                                    var targetColumnIndex = root._columns.indexOf(targetColumn);
                                    root._columns.splice(dragIndex > targetIndex ? targetColumnIndex : targetColumnIndex + 1, 0, dragColumn);
                                    root._columns = root._columns.concat([]);
                                }
                            }
                            onPositionChanged: {
                                if (!modelData.fixed) {
                                    var mouseX = mouse.x;
                                    var i = index;
                                    var column;
                                    if (mouseX < 0) {
                                        for (i--;i >= 0;i--) {
                                            column = root.columns[i];
                                            mouseX += column.width;
                                            if (!column.fixed && mouseX >= 0) {
                                                repeater.targetIndex = i;
                                                return;
                                            }
                                        }
                                    } else if (mouseX - modelData.width > 0) {
                                        for (i;i < root.columns.length;i++) {
                                            column = root.columns[i];
                                            mouseX -= column.width;
                                            if (!column.fixed && mouseX < 0) {
                                                repeater.targetIndex = i;
                                                return;
                                            }
                                        }
                                    }
                                    repeater.targetIndex = -1;
                                }
                            }
                            onClicked: {
                                var column = root.columns[index];
                                if (column.sortable === true) {
                                    if (root.sortColumn === column) {
                                        column.desc = !column.desc;
                                    } else {
                                        root.sortColumn = column;
                                        column.desc = true;
                                    }
                                    root.sortDesc = column.desc;
                                }
                            }
                        }

                        MouseArea {
                            id: spliter
                            height: parent.height
                            width: 4
                            anchors.right: parent.right
                            cursorShape: Qt.SplitHCursor

                            Rectangle {
                                id: spliterLine
                                anchors.top: parent.top
                                anchors.right: spliter.right
                                height: parent.height
                                width: 1
                                color: theme.borderColor
                            }
                            onPositionChanged: {
                                column.columnWidth += mouse.x;
                            }
                            onReleased: {
                                root.columns[index].width = column.columnWidth;
                                root._columns = root._columns.concat([]);
                            }
                        }
//                        MouseArea {
//                            id: rightSpliter
//                            height: parent.height
//                            width: 5
//                            anchors.right: parent.right
//                            cursorShape: Qt.SplitHCursor
//                            Rectangle {
//                                anchors.right: parent.right
//                                height: parent.height
//                                width: 2
//                                color: '#999'
//                            }
//                        }
                    }

                }
                Item {
                    Layout.fillWidth: true
                }
            }
        }

        Item {
            id: list
            Layout.fillHeight: true
            Layout.fillWidth: true

            property real minRowHeight: 40

            // 所有股票排序后的列表，包含obj和名称
            property var stockList: []

            property int showCount: Math.floor(height / minRowHeight)

            property var showStockList: {
                var index = _flicker.visibleArea.yPosition * stockList.length;
                return stockList.slice(index, index + showCount);
            }

            property real contentHeight: minRowHeight * stockList.length

            // 最后一次请求行情数据的缓存（第一次请求到行情数据后清除并且更新数据，之后推送则只更新数据）
            property var cache: ({})

            // 根据显示的高，计算需要展示的行数据
            property var model: {

                // 填上行情数据
                return list.showStockList.map(function(eachStock) {
                    return Util.assign(eachStock, cache[eachStock.Obj]);
                });
            }

            DataProvider {
                id: stockListDataProvider
                serviceUrl: '/stkdata'
                sub: 1
        //        direct: true
                params: ({
                             gql: 'block=' + root.blockFullName,
                             mode: 2,
                             field: ['ZhongWenJianCheng'],
                             orderBy: root.sortColumn.orderByFieldName || undefined,
                             desc: root.sortDesc
                         })
                onSuccess: {
                    list.stockList = data.map(function(eachData, index) {
                        eachData.XuHao = index + 1;
                        return eachData;
                    });
                }
            }

            DataProvider {
                id: dataProvider
                serviceUrl: '/stkdata'
                sub: 1
                property string objs: list.showStockList.map(function(eachStock) {return eachStock.Obj}).join(',')
                params: ({
                             obj: objs,
                             field: root.fields
                         })

                onSuccess: {

                    var map = {};
                    data.forEach(function(eachData) {
                        delete eachData.XuHao;
                        map[eachData.Obj] = eachData;
                    });

                    // 更新缓存
                    list.cache = Util.assign({}, list.cache, map);
                }
            }

//            Flickable {
//                id: _flicker
//                anchors.fill: parent
//                contentHeight: list.contentHeight
//                contentWidth: root.contentWidth
//                clip: true
//                boundsBehavior: Flickable.StopAtBounds
//            }


            ColumnLayout {
                id: container
                anchors.fill: parent
                anchors.bottomMargin: 16
                anchors.rightMargin: 16
                spacing: 0
            }
            ScrollView {
                id: scrollView
                anchors.fill: parent
                anchors.rightMargin: -1
                Item {
                    width: contentWidth
                    height: list.contentHeight
                }
            }

            property var selectObjs: []

            Component {
                id: rowComponent
                Rectangle {
                    id: rowContainer
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    Layout.maximumHeight: 50
                    Layout.preferredHeight: parent.height / list.showCount
//                    Layout.minimumHeight: list.minRowHeight
                    Layout.alignment: Qt.AlignTop
                    property int rowIndex
                    property var rowData: ({})
                    color: list.selectObjs.indexOf(rowData.Obj) >= 0 ? '#ecf2ff' : 'transparent'

                    Component {
                        id: cellComponent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: false
                            Layout.preferredWidth: column.width || -1

                            property int columnIndex
                            property var column: ({})
                            property string field: column.field || ''
                            color: 'transparent'

                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: rowContainer.rowData[field] || '--'
                            }
                            SeparatorLine {
                                anchors.right: parent.right
                                height: parent.height
                                length: parent.height
                            }
                        }
                    }

                    RowLayout {
                        id: row
                        anchors.fill: parent
                        spacing: 0
                        property int columnCount: root.columns.length
                        property var cells: []
                        onColumnCountChanged: {
                            var count = columnCount;
                            var length = cells.length || 0;

                            // 减少
                            if (length > count) {
                                var deleteChildren = cells.splice(count, length - count);
                                deleteChildren.forEach(function(eachChild) {
                                    eachChild.destroy();
                                });
                            } else if (length < count) {

                                for (var i = 0; i < count - length; i++) {

                                    var cell = cellComponent.createObject(row, {columnIndex: length + i});
                                    cell.column = Qt.binding(function(index) {
                                        return function() {
                                            //console.log(model.length, index, model[index]);
                                            return root.columns[index] || {};
                                        }
                                    }(length + i));
                                    cells.push(cell);
                                }
                            }
                            row.children = cells.concat([lastChild]);
                        }
                        Item {
                            id: lastChild
                            Layout.fillWidth: true
                        }

//                        Repeater {
//                            model: root.columns
//                            Text {
//                                property string field: modelData.field
//                                property int columnIndex: index
//                                Layout.fillHeight: true
//                                Layout.fillWidth: true
//                                Layout.preferredWidth: modelData.width
//                                text: rowData[field] || '--'
//                            }
//                        }
                    }
                    SeparatorLine {
                        anchors.top: parent.top
                        width: parent.width
                        length: parent.width
                        orientation: Qt.Horizontal
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            var thisObj = rowData.Obj;
                            if (mouse.modifiers & Qt.ControlModifier) {
                                var index = list.selectObjs.indexOf(thisObj);
                                if (index >= 0) {
                                    list.selectObjs.splice(index, 1);
                                    list.selectObjs = list.selectObjs.concat([]);
                                } else {
                                    list.selectObjs = list.selectObjs.concat([thisObj]);
                                }
                            } else if (mouse.modifiers & Qt.ShiftModifier) {
//                                var lastObj = list.selectObjs[]
                            } else {
                                list.selectObjs = [thisObj];
                            }
                        }
                    }
                }
            }

            onShowCountChanged: {
                var count = showCount;
                var length = container.children.length || 0;

                // 减少
                if (length > count) {
                    var deleteChildren = Array.prototype.splice.call(container.children, count, length - count);
                    deleteChildren.forEach(function(eachChild) {
                        eachChild.destroy();
                    });
                } else if (length < count) {

                    for (var i = 0; i < count - length; i++) {

                        // 创建新的行
                        var row = rowComponent.createObject(container, {rowIndex: length + i});
                        row.rowData = Qt.binding(function(index) {
                            return function() {
                                //console.log(model.length, index, model[index]);
                                return model[index] || {};
                            }
                        }(length + i));
                    }
                }
            }

//            ColumnLayout {
//                anchors.fill: parent
//                Repeater {
//                    model: list.model
//                    Rectangle {

//                        Layout.fillHeight: true
//                        Layout.fillWidth: true
//                        Layout.maximumHeight: 50
//                        Layout.alignment: Qt.AlignTop
//                        RowLayout {
//                            anchors.fill: parent
//                            property int rowIndex: index
//                            property var rowData: modelData
//                            Repeater {
//                                model: root.columns
//                                Text {
//                                    property string field: modelData.field
//                                    property int columnIndex: index
//                                    Layout.fillHeight: true
//                                    Layout.fillWidth: false
//                                    Layout.preferredWidth: modelData.width
//                                    text: parent.rowData[field] || '--'
//                                }
//                            }
//                        }
//                    }

//                }
//            }

//            HScrollBar {
//                flicker: _flicker
//                verticalScrollBarIsVisible: true
//                verticalScrollBarWidth: 10
//            }
//            VScrollBar {
//                flicker: _flicker
//                horizontalScrollBarIsVisible: true
//                horizontalScrollBarWidth: 10
//            }
        }
    }
}
