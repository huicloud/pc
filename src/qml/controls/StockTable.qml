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
import QtQuick.Controls 1.4 as Controls
import QtQuick.Layouts 1.1

import "../core"
import "../controls"
import "../js/Util.js" as Util
import "../js/TableWorker.js" as TableWorker

BaseComponent {
    id: root

    property bool draggable: false //自选股界面 且为未排序情况下，才可拖动
    property string __sourceId: '';
    property string __targetId: ''
    property bool __isUpperTarget: false; //是否在目标股票的上方
    property alias controlVisible: _scrollView.controlVisible
    // 传入的数据数组（所有行）
    property var model: []

    // 传入的列定义（所有列）
    property list<StockTableColumn> columns

    // 内部用
    property var _columns: []

    signal stockDragSorted(var srcObj, var destObj, var isFront);  //股票拖动排序信号

    // 请求字段数组
    // 延时处理，避免qml的list赋值问题
    property var requestFields//: Array.prototype.filter.call(columns, function(eachColumn) { return eachColumn.request }).map(function(eachColumn) { return eachColumn.field })

    onColumnsChanged: {
        //        _columns = Array.prototype.map.call(columns, function(eachColumn) { return eachColumn });
        // 延时处理，避免qml的list赋值问题
        _columnChangedTimer.stop();
        _columnChangedTimer.start();
    }

    Timer {
        id: _columnChangedTimer
        interval: 1
        onTriggered: {
            var fields = [];
            _columns = Array.prototype.map.call(columns, function(eachColumn) {
                if (eachColumn.request) {
                    fields.push(eachColumn.field);
                }
                return eachColumn;
            });
            requestFields = fields;
        }
    }

    // 避免初始化时重复执行
    // 列变化时重新计算所有列的偏移宽度
    function __columnsChanged() {
        var offsetWidth = 0;
        _columns.forEach(function(eachColumns) {
            if (eachColumns.visible === false) {
                eachColumns._offsetWidth = -1;
            } else if (eachColumns.fixed) {
                eachColumns._offsetWidth = 9999;
            } else {
                offsetWidth += eachColumns.width;
                eachColumns._offsetWidth = offsetWidth;
            }
        });
    }

    Component.onCompleted: {
        __columnsChanged();
        _columnsChanged.connect(__columnsChanged);
    }

    //    // 列变化时重新计算所有列的偏移宽度
    //    on_ColumnsChanged: {
    //        var offsetWidth = 0;
    //        _columns.forEach(function(eachColumns) {
    //            if (eachColumns.visible === false) {
    //                eachColumns._offsetWidth = -1;
    //            } else if (eachColumns.fixed) {
    //                eachColumns._offsetWidth = 9999;
    //            } else {
    //                offsetWidth += eachColumns.width;
    //                eachColumns._offsetWidth = offsetWidth;
    //            }
    //        });
    //        ws.columns = JSON.parse(JSON.stringify(root._columns));
    //    }

    readonly property alias _flicker: _scrollView.flickableItem

    readonly property alias _scrollView: _scrollView

    readonly property alias tableHeader: tableHeader

    readonly property alias tableBody: tableBody

    // 最小行高
    property real minimumRowHeight: 30

    // 最大行高
    property real maximumRowHeight: 40

    // 计算用总数据条数，每页最多显示条数调整后数据（用于滚动时计算开始位置）
    property int contentCount: model.length + Math.ceil((height - tableBody.height) / minimumRowHeight)

    // 总宽度
    property real contentWidth: _columns.reduce(function(preValue, eachColumn){ return preValue + (eachColumn.visible ? eachColumn.width : 0) }, 100)

    // 总高度
    property real contentHeight: minimumRowHeight * contentCount

    // 显示行数
    property int showRowCount: Math.floor(tableBody.height / minimumRowHeight)

    readonly property int startIndex: Math.max(Math.min(model.length - showRowCount, Math.round(_flicker.contentY / minimumRowHeight)), 0)

    // 显示的行数据
    property var showRowData: {
        //        var index = _flicker.visibleArea.yPosition * model.length;
        return model.slice(startIndex, startIndex + showRowCount);
    }

    // 内部用
    property var _showRowData: []

    // 表头高度
    property real tableHeaderHeight: _columns.reduce(function(preValue, eachColumn) {return Math.max(preValue, eachColumn.height)}, 0)

    // 表格偏移宽度
    property real offsetWidth: _flicker.visibleArea.xPosition * contentWidth

    property var showColumns: {
        return _columns.filter(function(eachColumn) {
            return eachColumn._offsetWidth >= root.offsetWidth && eachColumn._offsetWidth - root.offsetWidth < root.width;
        });
    }

    // 排序字段
    property StockTableColumn orderByColumn

    // 指定数据唯一性字段（Obj）
    property string idField: 'Obj'

    // 表格是否横向拉伸
    property bool fillWidth: contentWidth < root.width

    // 是否需要改变排序字段后滚动到顶部
    property bool changeOrderByToTop: true

    // 是否显示表头
    property bool showTableHeader: true

    //    WorkerScript {
    //        id: ws
    //        source: '../js/TableWorker.js'
    //        property var columns//: JSON.parse(JSON.stringify(root._columns))
    //        onMessage: {
    //            _showRowData = messageObject;
    //        }
    //    }

    //    Component.onCompleted: {
    //        ws.columns = Qt.binding(function() {
    //            return JSON.parse(JSON.stringify(root._columns));
    //        });
    //    }

    onShowRowDataChanged: {
        //        ws.sendMessage({
        //                           columns: ws.columns,
        //                           lastData: _showRowData,
        //                           currentData: showRowData,
        //                           idField: root.idField
        //                       })

        // 使用定时器延时处理数据，减轻程序占用的cpu资源
        if (!timer.running && visible) {
            timer.start();
        }
    }

    property alias timer: timer

    // 定时器延时处理数据
    Timer {
        id: timer
        interval: 1
        property int maxInterval: 1000
        property int addStep: 50

        // 使得前几次直接触发
        triggeredOnStart: interval < 100
        onTriggered: {
            //            ws.sendMessage({
            //                               columns: ws.columns,
            //                               lastData: _showRowData,
            //                               currentData: showRowData,
            //                               idField: root.idField
            //                           });
            _showRowData = TableWorker.handleData({
                                                      columns: root._columns,
                                                      lastData: _showRowData,
                                                      currentData: showRowData,
                                                      idField: root.idField
                                                  });

            // 每次执行定时后增加下次执行的间隔，不超过最大值
            timer.interval = Math.min(timer.maxInterval, timer.interval + timer.addStep);
        }
    }

    // 当startIndex变化时将定时器延时时间重置回1（翻页或其它操作引起数据更新时）
    onStartIndexChanged: {
        timer.interval = 1;
    }

    property var selectedIds: []

    // 仅有显示数据中的选中数据
    property var selectedRowData: {
        var dataMap = _showRowData.reduce(function(map, currentData) {
            map[currentData[idField]] = currentData;
            return map;
        }, {});
        return selectedIds.map(function(id) {return dataMap[id]}).filter(function(eachData) {
            return eachData != null;
        });
    }
    property var currentRowData: selectedRowData[0]

    signal clicked(var mouse, var row)
    signal rightClicked(var mouse, var row)
    signal doubleClicked(var mouse, var row)

    ScrollView {
        id: _scrollView

        anchors.fill: parent
        anchors.rightMargin: -1

        verticalScrollBarStep: minimumRowHeight

        // 默认横向拉伸时不显示横向滚动条
        horizontalScrollBarPolicy: root.fillWidth ? Qt.ScrollBarAlwaysOff : Qt.ScrollBarAlwaysOn
        verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

        // 横向步进取左右下一个列的宽度的最大值
        horizontalScrollBarStep: {
            var step = 100;
            if (visible) {
                if (leftColumn) {
                    step = Math.max(step, leftColumn.width);
                }
                if (rightColumn) {
                    step = Math.max(step, rightColumn.width);
                }
            }
            return step;
        }

        Item {
            width: contentWidth
            height: contentHeight
        }
    }

    ColumnLayout {
        id: tableContainer

        //        anchors.fill: parent
        //        anchors.rightMargin: theme.tableScrollbarSize
        //        anchors.bottomMargin: theme.tableScrollbarSize
        anchors.top: parent.top
        anchors.left: parent.left

        // 避免滚动区的滚动条在显示和不显示时宽度变化引起数据重计算
        width: _scrollView.viewport.width - (_scrollView.visible ? 0 : theme.tableScrollbarSize)
        height: _scrollView.viewport.height - (_scrollView.visible ? 0 : theme.tableScrollbarSize)

        clip: true
        spacing: 0

        Item {
            id: tableHeader

            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.preferredHeight: tableHeaderHeight

            visible: showTableHeader

            property int dragIndex: -1
            property int targetIndex: -1

            RowLayout {
                id: rowLayout
                anchors.fill: parent
                spacing: 0
                Repeater {
                    model: (root._columns || []).length

                    Rectangle {
                        id: tableHeaderColumn
                        property var column: root._columns[index]
                        property real columnWidth: column.width
                        property string groupTitle: column.groupTitle
                        Layout.fillHeight: true
                        Layout.fillWidth: root.fillWidth
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: columnWidth
                        visible: column._isVisible(root.width, root.offsetWidth)
                        //                        visible: column.fixed || (column._offsetWidth >= root.offsetWidth && column._offsetWidth - root.offsetWidth < root.width)

                        Binding {
                            target: column
                            property: 'isOrderByColumn'
                            value: column === root.orderByColumn
                        }

                        property var tableHeaderColumnState: {
                            if (tableHeader.dragIndex === index) {
                                return 'dragging';
                            } else if (tableHeader.targetIndex === index) {
                                return 'dragTarget';
                            } else if (dragArea.containsMouse) {
                                return 'hovered';
                            }
                            return 'normal';
                        }

                        color: column.backgroundColors[tableHeaderColumnState] || 'transparent'

                        Rectangle {
                            id: groupTitle
                            color: column.backgroundColors['normal']
                            parent: tableHeader
                            x: tableHeaderColumn.x + tableHeaderColumn.width - width - 1
                            anchors.top: tableHeaderColumn.top
                            width: {
                                var width = 0;
                                Array.prototype.some.call(rowLayout.children, function(eachChild) {
                                    width += eachChild.groupTitle === column.groupTitle && eachChild.visible ? eachChild.width - 1: 0;
                                    if (eachChild.column === column) {
                                        return true;
                                    }
                                });
                                return width;
                            }
                            height: tableHeaderColumn.height / 2
                            z: index
                            visible: tableHeaderColumn.visible && column.groupTitle !== ''
                            Text {
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                text: column.groupTitle
                            }
                            SeparatorLine {
                                anchors.bottom: parent.bottom
                                orientation: Qt.Horizontal
                                width: parent.width
                                length: parent.width
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            anchors.margins: 4
                            anchors.topMargin: column.groupTitle !== '' ? tableHeaderColumn.height / 2 + (tableHeaderColumn.height / 2 - column.fontSize) / 2 : 4
                            sourceComponent: column._headerComponent
                        }

                        Rectangle {
                            id: dragItem
                            color: '#ecf2ff'
                            parent: Drag.active ? tableHeader : tableHeaderColumn
                            anchors.top: parent.top
                            height: tableHeaderColumn.height
                            width: tableHeaderColumn.width
                            visible: Drag.active
                            opacity: 0.6
                            Drag.active: column.draggable && dragArea.drag.active
                            Loader {
                                anchors.fill: parent
                                anchors.margins: 4
                                sourceComponent: column._dragComponent
                            }
                        }
                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            drag.target: dragItem
                            hoverEnabled: true
                            drag.onActiveChanged: {
                                if (column.draggable && drag.active) {
                                    tableHeader.dragIndex = index;
                                }
                            }

                            onReleased: {
                                var dragIndex = tableHeader.dragIndex;
                                var targetIndex = tableHeader.targetIndex;

                                dragItem.x = 0;
                                tableHeader.dragIndex = -1;
                                tableHeader.targetIndex = -1;

                                if (dragIndex !== -1 && targetIndex !== -1) {
                                    var dragColumn = root._columns[dragIndex];
                                    var targetColumn = root._columns[targetIndex];

                                    var dragColumnIndex = root._columns.indexOf(dragColumn);
                                    root._columns.splice(dragColumnIndex, 1);
                                    var targetColumnIndex = root._columns.indexOf(targetColumn);
                                    root._columns.splice(dragIndex > targetIndex ? targetColumnIndex : targetColumnIndex + 1, 0, dragColumn);
                                    root._columns = root._columns.concat([]);
                                }
                            }

                            onPositionChanged: {
                                if (column.draggable && drag.active) {
                                    var mouseX = mouse.x;
                                    var i = index;
                                    var currColumn;
                                    if (mouseX < 0) {
                                        for (i--;i >= 0;i--) {
                                            currColumn = root._columns[i];
                                            if (!currColumn._isVisible(root.width, root.offsetWidth)) {
                                                continue;
                                            }

                                            mouseX += currColumn.width;
                                            if (currColumn.draggable && mouseX >= 0) {
                                                tableHeader.targetIndex = i;
                                                return;
                                            }
                                        }
                                    } else if (mouseX - modelData.width > 0) {
                                        for (i;i < root._columns.length;i++) {
                                            currColumn = root._columns[i];
                                            if (!currColumn._isVisible(root.width, root.offsetWidth)) {
                                                continue;
                                            }
                                            mouseX -= currColumn.width;
                                            if (currColumn.draggable && mouseX < 0) {
                                                tableHeader.targetIndex = i;
                                                return;
                                            }
                                        }
                                    }
                                    tableHeader.targetIndex = -1;
                                }
                            }
                            onClicked: {
                                var column = tableHeaderColumn.column;
                                if (column.sortable === true) {
                                    timer.interval = 1;
                                    if (root.orderByColumn === column) {
                                        if (column.desc === true) {
                                            column.desc = false;
                                        } else {
                                            var defaultoderColumn = root.orderByColumn; //避免触发二次变化
                                            root.orderByColumn = null;
                                            defaultoderColumn.desc = true;

                                        }
                                    } else {
                                        column.desc = true;
                                        root.orderByColumn = column;
                                    }
                                }

                                // 重新选中排序字段是表格回到顶部
                                if (root.changeOrderByToTop) {
                                    root.toTop();
                                }
                            }
                        }

                        MouseArea {
                            id: spliter
                            height: parent.height
                            width: 4
                            anchors.right: parent.right
                            cursorShape: column.resizable && !root.fillWidth ? Qt.SplitHCursor : Qt.ArrowCursor

                            // 拉伸状态不能拉动重置宽度
                            enabled: column.resizable && !root.fillWidth

                            SeparatorLine {
                                anchors.right: parent.right
                                height: parent.height
                                length: parent.height
                            }
                            onPositionChanged: {
                                var maximumWidth = column.maximumWidth;
                                var minimumWidth = column.minimumWidth;
                                tableHeaderColumn.columnWidth = Math.min(maximumWidth !== -1 ? maximumWidth : Number.MAX_VALUE, Math.max(minimumWidth, tableHeaderColumn.columnWidth + mouse.x));
                            }
                            onReleased: {
                                root._columns[index].width = tableHeaderColumn.columnWidth;
                                root._columns = root._columns.concat([]);
                            }
                        }
                    }

                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                }
            }
        }

        SeparatorLine {
            Layout.fillHeight: false
            Layout.fillWidth: true
            length: parent.width
            orientation: Qt.Horizontal
            visible: showTableHeader
        }

        Item {
            id: tableContentRegion
            Layout.fillHeight: true
            Layout.fillWidth: true
            Column {
                id: tableBody
                anchors.fill: parent
            }

            SeparatorLine {
                id: dragHighlightLine
                Layout.fillHeight: false
                Layout.fillWidth: true
                length: parent.width
                orientation: Qt.Horizontal
                visible: false
                color: theme.selfStockDragLineColor
            }
        }
    }

    // 空白列，避免找不到列时绑定报错
    property StockTableColumn _emptyColumn: StockTableColumn{visible: false}

    property Component _cellComponent: Component {
        Item {
            id: cellContainer
            property int columnIndex
            property var column: root._columns[columnIndex] || _emptyColumn;

            property int rowIndex
            property var rowData: _showRowData[rowIndex] || {}
            property bool _visible: column._isVisible(root.width, root.offsetWidth)

            Layout.fillHeight: true
            Layout.fillWidth: root.fillWidth
            Layout.preferredWidth: column.width || -1
            visible: _visible

            Loader {

                property int rowIndex: parent.rowIndex
                property var rowData: parent.rowData
                property int columnIndex: parent.columnIndex
                property var column: parent.column
                property string field: column.field || ''

                property string id: rowData[idField] || ''

                anchors.fill: parent

//                sourceComponent: parent._visible ? column._tableCellComponent : null
                sourceComponent: column._tableCellComponent
            }
            SeparatorLine {
                anchors.right: parent.right
                height: parent.height
                length: parent.height + 1
                color: '#dfe4ea'
            }
        }

    }

    //    property Component cellComponent: Component {
    //        Item {
    //            id: cellContainer

    //            StockTableCellLabel{
    //                anchors.fill: parent
    //            }

    //            SeparatorLine {
    //                anchors.right: parent.right
    //                height: parent.height
    //                length: parent.height
    //            }
    //        }
    //    }

    property Component _rowComponent: Component {
        Loader {
            id: rowLoader
            property int rowIndex
            property var rowData: _showRowData[rowIndex] || {}

            property string id: rowData[idField] || ''

            property bool selected: root.selectedIds.indexOf(id) >= 0

            property bool hovered: mouseArea.enabled && mouseArea.containsMouse

            //            Layout.fillHeight: false
            //            Layout.fillWidth: true
            //            Layout.maximumHeight: 50
            //            Layout.preferredHeight: parent.height / root.showRowCount

            //            Layout.alignment: Qt.AlignTop
            height: _showRowData.length >= showRowCount ? parent.height / root.showRowCount : root.minimumRowHeight
            width: parent.width
            sourceComponent: rowIndex < _showRowData.length ? rowComponent : null
            //            sourceComponent: rowComponent

            Rectangle {
                id: background
                state: selected ? 'selected' : hovered ? 'hovered' : ''
                color: getRowBackground(state, rowData, rowIndex)
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: parent.height + 1
            }

            Rectangle{
                id: dragRowItem
                parent: tableContentRegion  //parent指向为列表内容区
                width: parent.width
                height: background.height
                color: theme.selfStockDragItemColor
                visible: Drag.active
                opacity: 0.7
                z: 9
                Drag.active: root.draggable && mouseArea.drag.active
                Drag.source: rowLoader

                Text{
                   id: dragRowItemText
                   height: parent.height
                   anchors.left: parent.left
                   anchors.leftMargin: 40
                   anchors.right: parent.right
                   text: ""
                }
            }

            //接收区域
            DropArea{
                id: dropContainer
                anchors.fill: parent
                z: -1;
                property var dropPos:{x:0; y:0}
                property int dragOrigin: 0
                property int dragOffset: 2
                onEntered: {

                    root.__sourceId = drag.source.id;
                    root.__targetId = id;

                    dropPos =  mapToItem(tableContentRegion, dropContainer.x, dropContainer.y);

                    dragHighlightLine.visible = true;
                    /**if(drag.y > dropContainer.height / 2){
                       dragOrigin = dropContainer.height
                    }else{
                       dragOrigin = 0
                    }*/
                }

                onExited: {
                    /*dragOrigin = 0*/
                }

                onDropped: {

                }

                onPositionChanged: {
                    drag.accepted = true

                    if (id !== '') {

                        /**root.__isUpperTarget = false;
                        if(drag.y < dragOrigin){
                            //向上移动
                            if(drag.y < dragOffset){
                                root.__isUpperTarget = true;   //上边缘
                                dragHighlightLine.x = 0;
                                dragHighlightLine.y = dropPos.y;
                            }else{
                                root.__isUpperTarget = false;  //下边缘
                                dragHighlightLine.x = 0;
                                dragHighlightLine.y = dropPos.y + dropContainer.height;
                            }
                        } else {
                            //向下移动
                            if(drag.y > dragOffset){
                                root.__isUpperTarget = false;  //下边缘
                                dragHighlightLine.x = 0;
                                dragHighlightLine.y = dropPos.y + dropContainer.height;
                            }else{
                                root.__isUpperTarget = true;   //上边缘
                                dragHighlightLine.x = 0;
                                dragHighlightLine.y = dropPos.y;
                            }
                        }**/

                        //简化逻辑如下
                        root.__isUpperTarget =  drag.y < dragOffset
                        if(root.__isUpperTarget){
                            //上边缘[目前只有拖到列表第一个股票会出现]
                            dragHighlightLine.x = 0;
                            dragHighlightLine.y = dropPos.y;
                        }else{//下边缘
                            dragHighlightLine.x = 0;
                            dragHighlightLine.y = dropPos.y + dropContainer.height;
                        }

                       /*dragOrigin = drag.y;*/
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                propagateComposedEvents: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                enabled: rowIndex < _showRowData.length
                hoverEnabled: true

                drag.target: dragRowItem
                drag.axis: Drag.YAxis

                onReleased: {

                    dragHighlightLine.visible = false;
                    //console.info('333333333333333','当前obj:', root.__targetId, '被拖动obj:', root.__sourceId, '是否在上边框', root.__isUpperTarget);
                    //进行拖拽排序的信号
                    if (root.__targetId !== '' && root.__sourceId !== '' && root.__targetId !== root.__sourceId){
                       root.stockDragSorted(root.__sourceId, root.__targetId, root.__isUpperTarget);
                    }

                    root.__targetId = '';
                    root.__sourceId = '';
                }

                onPositionChanged: {

                    if ( dragRowItem.y < 0){
                        dragRowItem.y = 0;
                        return;
                    }

                    if((dragRowItem.y + dragRowItem.height)> tableContentRegion.height){
                        dragRowItem.y = tableContentRegion.height - dragRowItem.height;
                    }
                }

                onPressed: {
                    dragRowItemText.text = id + '  ' + rowData['ZhongWenJianCheng'] || '';
                    var posInParent = mapToItem(tableContentRegion, background.x, background.y);
                    dragRowItem.y = posInParent.y;
                    dragHighlightLine.y = posInParent.y;

                    mouse.accepted = false;
                    if (mouse.button === Qt.LeftButton) {
                        root.clicked(mouse, rowData);
                    } else if (mouse.button === Qt.RightButton) {
                        root.rightClicked(mouse, rowData);
                    }

                    // 触发信号处理后，accepted变成true，则不做默认处理
                    if (mouse.accepted === false) {
                        var index = root.selectedIds.indexOf(id);
                        if (mouse.button === Qt.RightButton && index >= 0) {
                            // do nothing
                        } else if (mouse.modifiers & Qt.ControlModifier) {
                            if (index >= 0 && mouse.button === Qt.LeftButton) {
                                root.selectedIds.splice(index, 1);
                                root.selectedIds = root.selectedIds.concat([]);
                            } else {
                                root.selectedIds = root.selectedIds.concat([id]);
                            }
                        } else if (mouse.modifiers & Qt.ShiftModifier) {

                            // 最后一个选中行在当前可见数据中时，将最后一个和当前选中的行之间的数据都选中
                            var lastId = root.selectedIds[root.selectedIds.length - 1];
                            var showIds = root.showRowData.map(function(eachData) { return eachData[root.idField]} );
                            var startIndex = showIds.indexOf(lastId);
                            if (startIndex >= 0) {
                                var endIndex = showIds.indexOf(id);
                                showIds.slice(Math.min(startIndex, endIndex), Math.max(startIndex, endIndex) + 1)
                                .forEach(function(eachId) {
                                    if (root.selectedIds.indexOf(eachId) < 0) {
                                        root.selectedIds.push(eachId);
                                    }
                                });
                                root.selectedIds = root.selectedIds.concat([]);
                            } else {

                                // 最后一条选中已经滚出去的时候，直接将选中对象改为当前选中id
                                root.selectedIds = [id];
                            }
                        } else {
                            root.selectedIds = [id];
                        }
                        mouse.accepted = true;
                    }
                }

                onDoubleClicked: {
                    root.doubleClicked(mouse, rowData);
                }
            }

            SeparatorLine {
                anchors.top: parent.top
                width: parent.width
                length: parent.width
                orientation: Qt.Horizontal
                color: '#dfe4ea'
                z: 100
                visible: rowIndex !== 0 && rowIndex < _showRowData.length
            }
            SeparatorLine {
                anchors.bottom: parent.bottom
                width: parent.width
                length: parent.width
                orientation: Qt.Horizontal
                color: '#dfe4ea'
                z: 100
                visible: rowIndex === _showRowData.length - 1
            }
        }
    }

    // row背景颜色hacker
    function getRowBackground(state, rowData, rowIndex) {
        return {'selected': '#d0e1f1', 'hovered': '#ecf2ff'}[state] || 'transparent';
    }

    property Component rowComponent: Component {
        RowLayout {
            id: row
            anchors.fill: parent
            spacing: 0
            property int columnCount: root._columns.length
            property int _rowIndex: rowIndex

            property var cells
            onColumnCountChanged: {

                var count = columnCount;
                var length = cells ? cells.length : 0;

                // 减少
                if (length > count) {
                    // TODO qml destroy 只会销毁本身对象，对象上的绑定和子组件对象都销毁不掉
                    //                        var deleteChildren = cells.splice(count, length - count);
                    //                        deleteChildren.forEach(function(eachChild) {
                    //                            eachChild.destroy();
                    //                        });
                    return;
                } else if (length < count) {

                    var c = [];
                    for (var i = 0; i < count - length; i++) {

                        var cell = _cellComponent.createObject(row, {columnIndex: length + i, rowIndex: rowIndex});
                        c.push(cell);
                    }
                    cells = c;
                }
                row.children = cells.concat([lastChild]);
            }
            Item {
                id: lastChild
                Layout.fillWidth: true
                Layout.preferredWidth: 0
            }
        }
    }

    onShowRowCountChanged: {

        var count = showRowCount;
        var length = tableBody.children.length || 0;

        // 数据延时处理重置
        timer.interval =  1;

        // 减少
        if (length > count) {
            //            var deleteChildren = Array.prototype.splice.call(tableBody.children, count, length - count);
            //            deleteChildren.forEach(function(eachChild) {
            //                eachChild.destroy();
            //            });
        } else if (length < count) {

            for (var i = 0; i < count - length; i++) {

                // 创建新的行
                var row = _rowComponent.createObject(tableBody, {rowIndex: length + i});
            }
        }
    }

    property var leftColumn: _columns[_columns.indexOf(showColumns[0]) - 1];
    property var rightColumn: _columns[_columns.indexOf(showColumns[showColumns.length - 1]) + 1];

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_PageDown) {
            nextPage();
            event.accepted = true;
        } else if (event.key === Qt.Key_PageUp) {
            prevPage();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            nextOne();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            prevOne();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            prevColumn()
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            nextColumn()
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {

            // 取消选中
            root.selectedIds = [];
            event.accepted = true;
        }
    }

    // 下一页
    function nextPage() {
        //        _flicker.contentY = Math.min(_flicker.contentHeight - tableBody.height, (startIndex + showRowCount) / model.length * contentHeight + 5);
        positionRow(startIndex + showRowCount);
    }

    // 上一页
    function prevPage() {
        //        _flicker.contentY = Math.max(0, (startIndex - showRowCount) / model.length * contentHeight + 5);
        positionRow(startIndex - showRowCount);
    }

    // 向上一条数据
    function nextOne() {

        var index = currentRowData ? _showRowData.indexOf(currentRowData) : -1;
        if (index === -1 || index === _showRowData.length - 1) {
            positionRow(startIndex + 1);
            //            _flicker.contentY = Math.min(_flicker.contentHeight - tableBody.height, (startIndex + 1) / model.length * contentHeight + 5);
            if (index > 0) {

                // 选中股票切换到下一个（_showRowData是延时处理得到的，所以直接取showRowData中的id）
                selectedIds = [showRowData[index][idField]];
            }
        } else {
            selectedIds = [_showRowData[index + 1][idField]];
        }
    }

    // 向下一条数据
    function prevOne() {
        var index = currentRowData ? _showRowData.indexOf(currentRowData) : -1;
        if (index === -1 || index === 0) {
            positionRow(startIndex - 1);
            //            _flicker.contentY = Math.max(0, (startIndex - 1) / model.length * contentHeight + 5);
            if (index === 0) {
                selectedIds = [showRowData[index][idField]];
            }
        } else {
            selectedIds = [_showRowData[index - 1][idField]];
        }
    }

    function nextColumn() {
        //        _flicker.contentX
        if (rightColumn) {
            _flicker.contentX = Math.min(contentWidth - width, _flicker.contentX + rightColumn.width + 5);
        }
    }

    function prevColumn() {
        if (leftColumn) {
            _flicker.contentX = Math.max(0, _flicker.contentX - (leftColumn.width + 5));
        }
    }

    // 定位到指定行号的位置
    function positionRow(rowIndex) {
        _flicker.contentY = Math.min(contentHeight - height, Math.max(0, rowIndex / contentCount * contentHeight));
    }

    // 回到表格顶部
    function toTop() {
        positionRow(0);
    }

    // 表格横向滚动到最左边
    function toLeft() {
        _flicker.contentX = 0;
    }
}
