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
import "../core/data"
import "../controls"
import "../util"
import "../js/Util.js" as Util
import "../js/DateUtil.js" as DateUtil
import "../js/TableWorker.js" as TableWorker

/**
 * 股票详情组件, 根据类型不同，分为股票和指数板块两类
 */
ContextComponent {
    id: root

    property string obj

    property var stock: StockUtil.stock.createObject(root)

    // 默认type=-1时不显示，type=1显示股票, type=0显示指数板块, 其它显示基金
    property int type: stock.type

    // 内部子组件行情
    property var component

    property var dynaData: ({})

    property bool mini: false

    focusAvailable: false

    property DataProvider dataProvider

    // 样式相关
    property color dynaLabelColor: theme.dynaLabelColor
    property int dynaLabelFontSize: theme.dynaLabelFontSize
    property int dynaLabelFontWeight: theme.dynaLabelFontWeight
    property string dynaLabelFontFamily: theme.dynaLabelFontFamily
    property int dynaLabelPreferredWidth: theme.dynaLabelPreferredWidth
    property int dynaValuePreferredWidth: theme.dynaValuePreferredWidth

    property color dynaComponentColor: theme.dynaComponentColor
    property color dynaComponentUpColor: theme.dynaComponentUpColor
    property color dynaComponentDownColor: theme.dynaComponentDownColor
    property int dynaComponentFontSize: theme.dynaComponentFontSize
    property int dynaComponentFontWeight: theme.dynaComponentFontWeight
    property string dynaComponentFontFamily: theme.dynaComponentFontFamily

    property color dynaComponentDynaColor: theme.dynaComponentDynaColor
    property color dynaComponentFixColor: theme.dynaComponentFixColor

    property int dynaComponentLeftMargin: theme.dynaComponentLeftMargin
    property int dynaComponentRightMargin: theme.dynaComponentRightMargin
    property int dynaComponentTopMargin: theme.dynaComponentTopMargin
    property int dynaComponentBottomMargin: theme.dynaComponentBottomMargin
    property int dynaComponentRowSpace: theme.dynaComponentRowSpace
    property int dynaComponentColumnSpace: theme.dynaComponentColumnSpace
    property int dynaComponentRowPreferredHeight: theme.dynaComponentRowPreferredHeight

    height: dynaComponent.height

    // 默认数据提供者，避免重复请求
    Component {
        id: defaultDataProvider
        DataProvider {
            autoQuery: true
            serviceUrl: '/stkdata'
            sub: 1
            params: ({
                obj: obj,
                field: ([
                            'ZuiXinJia', 'JunJia', 'ZhangDie', 'HuanShou', 'ZhangFu', 'KaiPanJia', 'ChengJiaoLiang',/*总手就是总成交量*/
                            'ZuiGaoJia', 'XianShou', 'ZuiDiJia', 'ChengJiaoE', 'LiangBi', 'ZhangTing', 'DieTing', 'ZhenFu',
                            'ZongChengJiaoBiShu', 'MeiBiChengJiaoGuShu', 'NeiPan', 'WaiPan', 'ZongMaiRu', 'ZongMaiRuJunJia',
                            'ZongMaiChu', 'ZongMaiChuJunJia', 'ShiYingLv', 'ShiJingLv', 'ZongShiZhi', 'LiuTongShiZhi',
                            'ChengJiaoLiangDanWei', 'ZuoShou', 'BaoGaoQi', 'XiaoShuWei', 'WeiBi'
                        ])
            })
            function adapt(data) {
                return data[0]
            }
        }
    }

    Component.onCompleted: {

        // 初始化数据提供商，如果从外部传入了dataProvider则不创建
        dataProvider = dataProvider || defaultDataProvider.createObject(root);
    }

    Loader {
        id: dynaComponent
        width: parent.width
        height: item ? item.height : 0
        sourceComponent: {
            if (type === 1) {
                return stockComponent;
            } else if (type === 0) {
                return blockComponent;
            } else {

                // 基金
                return fundComponent;
            }
        }
    }

    onObjChanged: {

        // obj变化清理数据
        dynaData = {};
    }

    Connections {
        target: dataProvider
        onSuccess: {
            dynaData = data;
        }
    }

    // 修正数据，null或者undefined返回NaN, 其它直接返回数字
    function normalNumber(data) {
        return data == null ? NaN : data;
    }

    // 财务字段对应格式化（添加财报期标志）
    function formatFinance(value, date) {
        var formatData = Util.formatStockText(normalNumber(value));
        if (value != null && date != null) {

            // 判断报告期属于那个季度
            var month = DateUtil.moment(date, 'YYYYMMDDhhmmss').month() + 1;
            var season = parseInt(month / 4);

            return formatData + ['①', '②', '③', '④'][season];
        }
        return formatData;
    }

    property var allFields: ({
                                 ZuiXinJia: {title: '最新', updownStyle: true, compareField: 'ZuoShou'},
                                 JunJia: {title: '均价', updownStyle: true, compareField: 'ZuoShou'},
                                 ZhangDie: {title: '涨跌', updownStyle: true},
                                 ZhangFu: {title: '涨幅', updownStyle: true, unit: '%', ratio: 1 / 100, precision: 2},
                                 ZhenFu: {title: '振幅', updownStyle: true, unit: '%', textColor: dynaComponentFixColor, ratio: 1 / 100, precision: 2},
                                 HuanShou: {title: '换手', textColor: dynaComponentFixColor, unit: '%', ratio: 1 / 100, precision: 2},
                                 KaiPanJia: {title: '今开', updownStyle: true, compareField: 'ZuoShou'},
                                 ChengJiaoLiang: {title: '总手', isVolume: true, isAutoPrec: true, unit: '万/亿', textColor: dynaComponentFixColor},
                                 ZuiGaoJia: {title: '最高', updownStyle: true, compareField: 'ZuoShou'},
                                 XianShou: {title: '现手', isVolume: true, isAutoPrec: true, unit: '万/亿', updownStyle: true, relateField: 'ZuiXinJia', compareField: 'last'},
                                 ZuiDiJia: {title: '最低', updownStyle: true, compareField: 'ZuoShou'},
                                 ChengJiaoE: {title: '总额', isAutoPrec: true, unit: '万/亿', textColor: dynaComponentFixColor},
                                 LiangBi: {title: '量比', textColor: dynaComponentFixColor, precision: 2},
                                 ZhangTing: {title: '涨停', textColor: dynaComponentUpColor},
                                 DieTing: {title: '跌停', textColor: dynaComponentDownColor},
                                 ZongChengJiaoBiShu: {title: '总笔', textColor: dynaComponentFixColor, precision: 0},
                                 MeiBiChengJiaoGuShu: {title: '每笔', isVolume: true, isAutoPrec: true, unit: '万/亿', textColor: dynaComponentFixColor},
                                 NeiPan: {title: '内盘', isVolume: true, textColor: dynaComponentDownColor, precision: 0, isAbs: true},
                                 WaiPan: {title: '外盘', isVolume: true, textColor: dynaComponentUpColor, precision: 0, isAbs: true},
                                 ZongMaiChu: {title: '总卖', isVolume: true, textColor: dynaComponentFixColor, precision: 0},
                                 ZongMaiChuJunJia: {title: '均价', updownStyle: true, compareField: 'ZuoShou'},
                                 ZongMaiRu: {title: '总买', isVolume: true, textColor: dynaComponentFixColor, precision: 0},
                                 ZongMaiRuJunJia: {title: '均价', updownStyle: true, compareField: 'ZuoShou'},
                                 ShiYingLv: {title: '市盈', textColor: dynaComponentDynaColor, precision: 2, format: function(dynaData) { return formatFinance(dynaData.ShiYingLv, dynaData.BaoGaoQi) }},
                                 ShiJingLv: {title: '市净', textColor: dynaComponentDynaColor, precision: 2},
                                 ZongShiZhi: {title: '总市值', isAutoPrec: true, unit: '万/亿', ratio: 10000, textColor: dynaComponentDynaColor},
                                 LiuTongShiZhi: {title: '流通市值', isAutoPrec: true, unit: '万/亿', ratio: 10000, textColor: dynaComponentDynaColor},
                                 WeiBi: {title: '委比', updownStyle: true, unit: '%', ratio: 1 / 100, precision: 2},
                                 ZuoShou: {title: '昨收', textColor: dynaComponentColor},
                                 PingJunJingTaiShiYingLv: {title: '市盈率', textColor: dynaComponentDynaColor, precision: 2},

                                 // 基金字段
                                 JingZhi: {title: '净值', textColor: dynaComponentDynaColor}
                             })

    function getFields(fields) {
        return fields.map(function(eachField) {
            if (typeof eachField === 'string') {
                var field = allFields[eachField];
                field.field = eachField;
                return field;
            } else if (typeof eachField === 'object') {
                var fieldName = eachField.field;
                return Util.assign({}, allFields[fieldName], eachField);
            }

            return eachField;
        });
    }

    Component {
        id: dynaFieldsComponent

        GridLayout {
            id: dynaFields
            property var fields: parent.fields
            property var dynaData: ({})

            columns: 2
            rowSpacing: dynaComponentRowSpace
            columnSpacing: dynaComponentColumnSpace

            Connections {
                target: parent
                onDynaDataChanged: {
                    dynaFields.dynaData = TableWorker.formatData(parent.dynaData, dynaFields.dynaData, dynaFields.fields);
                }
            }

            // 字段变化时也应该重新计算展示数据
            onFieldsChanged: {
                dynaFields.dynaData = TableWorker.formatData(parent.dynaData, dynaFields.dynaData, dynaFields.fields);
            }

            Repeater {
                model: dynaFields.fields

                RowLayout {
                    property string field: modelData.field
                    property int updown: dynaData[field + '_updown'] || 0

                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    Layout.preferredHeight: dynaComponentRowPreferredHeight
                    spacing: 0

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: dynaLabelPreferredWidth
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        color: dynaLabelColor
                        font.pixelSize: dynaLabelFontSize
                        font.weight: dynaLabelFontWeight
                        font.family: dynaLabelFontFamily

                        text: modelData.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: dynaValuePreferredWidth
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment: Qt.AlignVCenter
                        elide: Text.ElideNone
                        fontSizeMode:Text.HorizontalFit

                        color: modelData.updownStyle ? (updown > 0 ? dynaComponentUpColor : updown < 0 ? dynaComponentDownColor : dynaComponentColor) : modelData.textColor
                        text: {
                            var format = allFields[field].format;
                            if (typeof format === 'function') {
                                return format(dynaData);
                            }
                            return dynaData[field + '_format'] || dynaData[field] || '--';
                        }
                    }
                }
            }
        }
    }

    // 股票类组件
    Component {
        id: stockComponent

        Rectangle {
            width: parent ? parent.width : 0
            height: layout.height

            // 嵌套Layout来设置margin
            ColumnLayout {
                id: layout
                width: parent.width

                Loader {

                    property var fields: getFields([
                        'ZuiXinJia', 'JunJia', 'ZhangDie', 'HuanShou', 'ZhangFu', 'KaiPanJia', 'ChengJiaoLiang', 'ZuiGaoJia',
                        'XianShou', 'ZuiDiJia', 'ChengJiaoE', 'LiangBi', 'ZhangTing', 'DieTing', 'ZongChengJiaoBiShu', 'MeiBiChengJiaoGuShu',
                        'NeiPan', 'WaiPan', 'ZongMaiChu', 'ZongMaiChuJunJia', 'ZongMaiRu', 'ZongMaiRuJunJia',
                        'ShiYingLv', 'ShiJingLv', 'ZongShiZhi', 'LiuTongShiZhi'
                    ].slice(0, root.mini ? 6 : 99))
                    property var dynaData: root.dynaData

                    // 避免循环计算children的preferedWidth
                    width: parent.width
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: dynaComponentLeftMargin
                    Layout.rightMargin: dynaComponentRightMargin
                    Layout.topMargin: dynaComponentTopMargin
                    Layout.bottomMargin: dynaComponentBottomMargin

                    sourceComponent: dynaFieldsComponent
                }
            }
        }
    }

    Component {
        id: blockComponent
        Rectangle {
            id: blockStat
            width: parent ? parent.width : 0
            height: layout.height

            property var block: BlockUtil.blockName.createObject(root)
            property string blockName: block.fullName
            property var blockStatData: ({})
            property DataProvider dataProvider: DataProvider {
                id:blockStatQuery
                parent: blockStat
                serviceUrl: '/blockstat'
                params: ({
                             gql: 'block=' + block.fullName,
                             field: ['PingJunJingTaiShiYingLv', 'ZongShiZhi', 'ZhangDiePing', 'ZiJinJingE']
                         })
                autoQuery: false
                onSuccess: {
                    blockStatData = data[0];
                }
                onParamsChanged: {
                    blockStatData = {};
                    if(blockStat.blockName && blockStat.blockName !== ''){
                        blockStatQuery.query();
                    }
                }
            }

            // 嵌套Layout来设置margin
            ColumnLayout {
                id: layout
                width: parent.width
                spacing: 0

                Loader {

                    property var fields: getFields([
                        'ZuiXinJia', 'ZhangDie', 'ZhangFu', 'ZhenFu', 'KaiPanJia', 'ZuoShou', 'ZuiGaoJia',
                        {field: 'XianShou', title: '现量'}, 'ZuiDiJia', {field: 'ChengJiaoLiang', title: '总量'},
                        'LiangBi', 'HuanShou', 'ChengJiaoE', 'PingJunJingTaiShiYingLv', 'ZongShiZhi',
                    ])
                    property var dynaData: Util.assign({}, root.dynaData, blockStatData)

                    // 避免循环计算children的preferedWidth
                    width: parent.width
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: dynaComponentLeftMargin
                    Layout.rightMargin: dynaComponentRightMargin
                    Layout.topMargin: dynaComponentTopMargin
                    Layout.bottomMargin: dynaComponentBottomMargin

                    sourceComponent: dynaFieldsComponent
                }
                SeparatorLine {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.margins: Qt.platform.os === 'osx' ? 2 : 0
                    length: parent.width
                    orientation: Qt.Horizontal
                    color: '#EEEEEE'
                }
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.leftMargin: dynaComponentLeftMargin
                    Layout.rightMargin: dynaComponentRightMargin
                    Layout.topMargin: dynaComponentTopMargin
                    Layout.bottomMargin: dynaComponentBottomMargin
                    Text {
                        Layout.fillWidth: true
                        text: '资金'
                        color: dynaLabelColor
                        font.pixelSize: dynaLabelFontSize
                        font.weight: dynaLabelFontWeight
                        font.family: dynaLabelFontFamily
                    }
                    Text {
                        Layout.fillWidth: true
                        text: blockStatData.ZiJinJingE >= 0 ? '净流入' : '净流出'
                        color: blockStatData.ZiJinJingE >= 0 ? dynaComponentUpColor : dynaComponentDownColor
                        font.pixelSize: dynaComponentFontSize
                        font.weight: dynaComponentFontWeight
                        font.family: dynaComponentFontFamily
                    }
                    Label {
                        unit: '万/亿'
                        value: Math.abs(blockStatData.ZiJinJingE)
                        normalColor: blockStatData.ZiJinJingE >= 0 ? dynaComponentUpColor : dynaComponentDownColor
                    }
                }
                SeparatorLine {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.margins: Qt.platform.os === 'osx' ? 2 : 0
                    length: parent.width
                    orientation: Qt.Horizontal
                    color: '#EEEEEE'
                }
                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    Layout.leftMargin: dynaComponentLeftMargin
                    Layout.rightMargin: dynaComponentRightMargin
                    Layout.topMargin: dynaComponentTopMargin
                    Layout.bottomMargin: dynaComponentBottomMargin
                    Text {
                        text: '涨'
                        color: dynaLabelColor
                        font.pixelSize: dynaLabelFontSize
                        font.weight: dynaLabelFontWeight
                        font.family: dynaLabelFontFamily
                    }
                    Label {
                        Layout.fillWidth: true
                        value: blockStatData.ZhangDiePing ? blockStatData.ZhangDiePing.ShangZhangJiaShu : NaN
                        normalColor: dynaComponentUpColor
                        precision: 0
                        font.pixelSize: dynaComponentFontSize
                        font.weight: dynaComponentFontWeight
                        font.family: dynaComponentFontFamily
                    }
                    Text {
                        text: '跌'
                        color: dynaLabelColor
                        font.pixelSize: dynaLabelFontSize
                        font.weight: dynaLabelFontWeight
                        font.family: dynaLabelFontFamily
                    }
                    Label {
                        Layout.fillWidth: true
                        value: blockStatData.ZhangDiePing ? blockStatData.ZhangDiePing.XiaDieJiaShu : NaN
                        normalColor: dynaComponentDownColor
                        precision: 0
                        font.pixelSize: dynaComponentFontSize
                        font.weight: dynaComponentFontWeight
                        font.family: dynaComponentFontFamily
                    }
                    Text {
                        text: '平'
                        color: dynaLabelColor
                        font.pixelSize: dynaLabelFontSize
                        font.weight: dynaLabelFontWeight
                        font.family: dynaLabelFontFamily
                    }
                    Label {
                        Layout.fillWidth: true
                        value: blockStatData.ZhangDiePing ? blockStatData.ZhangDiePing.PingPanJiaShu : NaN
                        normalColor: dynaComponentColor
                        precision: 0
                        font.pixelSize: dynaComponentFontSize
                        font.weight: dynaComponentFontWeight
                        font.family: dynaComponentFontFamily
                    }
                }
            }
        }
    }

    Component {
        id: fundComponent
        Rectangle {
            width: parent ? parent.width : 0
            height: layout.height

            // 嵌套Layout来设置margin
            ColumnLayout {
                id: layout
                width: parent.width
                Loader {

                    property var fields: getFields([
                        'ZuiXinJia', 'JingZhi', 'ZhangDie', 'HuanShou', 'ZhangFu', 'KaiPanJia', 'ChengJiaoLiang', 'ZuiGaoJia',
                        'XianShou', 'ZuiDiJia', 'ChengJiaoE', 'LiangBi', 'ZhenFu', 'WeiBi', 'JunJia', 'ZongShiZhi',
                        'WaiPan', 'NeiPan', 'ZhangTing', 'DieTing', 'ZongMaiChu', 'ZongMaiChuJunJia', 'ZongMaiRu', 'ZongMaiRuJunJia'
                    ].slice(0, root.mini ? 6 : 99))
                    property var dynaData: root.dynaData

                    // 避免循环计算children的preferedWidth
                    width: parent.width
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: dynaComponentLeftMargin
                    Layout.rightMargin: dynaComponentRightMargin
                    Layout.topMargin: dynaComponentTopMargin
                    Layout.bottomMargin: dynaComponentBottomMargin

                    sourceComponent: dynaFieldsComponent
                }
            }
        }
    }
}
