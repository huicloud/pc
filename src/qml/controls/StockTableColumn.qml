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

import "../core"
import "../controls"

QtObject {
    id: root

    property var theme: ThemeManager.currentTheme

    // 数据字段
    property string field

    // 是否需要请求的字段
    property bool request: true

    // 是否显示的字段
    property bool visible: true

    // 表头显示名称
    property string title

    // 表头分组标题（相连的有相同分组标题的列视为统一分组）
    property string groupTitle

    // 默认显示宽度
    property real width: 90

    // 高度
    property real height: 30

    // 最小显示宽度
    property real minimumWidth: 40

    // 最大显示宽度（-1是不限制）
    property real maximumWidth: -1

    // 是否固定位置，横向拖动时不隐藏，也不能拖动表头改变顺序
    property bool fixed: false

    // 是否可以的点击排序
    property bool sortable: true

    // 排序字段名称，默认等于数据字段名称
    property string orderByFieldName: field

    // 是否是排序字段
    property bool isOrderByColumn: false

    // 排序方向
    property bool desc: true

    // 是否可以拖动改变列宽
    property bool resizable: true

    // 是否可以拖动（分组列不能拖动）
    property bool draggable: !fixed && groupTitle === ''

    // 表头组件
    property Component _headerComponent: Text {
        text: root.title + (isOrderByColumn && desc === true ? '↓' : isOrderByColumn && desc === false ? '↑' : '')
        horizontalAlignment: root.align

        elide: Text.ElideRight
    }

    // 表头拖动组件
    property Component _dragComponent: _headerComponent

    // 表格单元格项组件
    property Component _tableCellComponent: StockTableCellLabel{}

    // 表头背景颜色
    property var backgroundColors: ({hovered: '#ecf2ff', dragging: '#dde9f8', dragTarget: '#dde9f8', normal: '#f3f8ff'})

    // 数据格式化相关
    // 小数精度
    property int precision: -1

    // 是否自动进行精度控制，true时 对于不到单位转换的情况时直接取整
    property bool isAutoPrec: false

    // 单位 {''|'K'|'M'|'B'|'K/M'|'K/M/B'|'万'|'亿'|'万/亿'|'%'}
    property var unit

    // 换算比例，数据需要转换为实际数据的转换比例，百分数为0.01, 单位万数据为10000
    property real ratio: 1

    // 是否是量相关字段，需要用数据中的每手单位股数进行换算
    property bool isVolume: false

    // 是否使用默认值，当数据值为null时显示默认值
    property bool useDefault: true

    // 是否显示数字绝对值
    property bool isAbs: false

    // 数据格样式相关
    // 是否显示涨跌颜色
    property bool updownStyle: false

    // 涨跌相关数据字段，根据对应字段数据值大于小于0判断涨跌
    property string relateField

    // 涨跌比较数据字段，比较当前值和对应字段的值大小判断涨跌('last'表示和上一次值比较)
    property string compareField

    // 高亮显示策略, 'none'|'updown'|'change'
    property string highlightPolicy: 'none'

    property string fontFamily: theme.fontFamily

    property int fontSize: theme.fontSize

    property int fontWeight: theme.fontWeight

    property color textColor: theme.textColor

    property color normalColor: theme.normalColor

    property color upColor: theme.redColor

    property color downColor: theme.greenColor

    property int align: Qt.AlignRight

    // 偏移宽度，大于等于表格偏移宽度的列需要显示，否则不显示
    property real _offsetWidth

    // 根据偏移宽度计算是否显示
    function _isVisible(parentWidth, parentOffsetWidth) {
        return visible && (fixed || (_offsetWidth >= parentOffsetWidth && _offsetWidth - parentOffsetWidth < parentWidth));
    }

    function format(rowData) {
        return rowData[field + '_format'] || rowData[field] || '--';
    }
}
