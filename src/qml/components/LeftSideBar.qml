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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import "../core/data"
import "../controls"
import "../core"
import "../util"

ContextComponent {
    id: root
    anchors.fill: parent

    //外部传入的obj
    property alias obj: leftSideListView.obj
    property string desc: ''       //默认按正序
    property string orderBy: "ZhangFu"
    property string market: ""
    property int type: 0 //默认0表示6系列的主列表 1自选 2最近浏览 3键盘宝 4板块B$ 5板块成分股 6基金 7常用指数
    property int topButtonIndex: 1 //0表示显示短线精灵，1，下拉

    property var listView: leftSideListView

    property bool isZixuan: (type === 1 || type === 2 || type === 3) ? true : false

    Component {
        id: marketDataProvider
        MarketDataProvider {
            parent: root
            obj: root.obj
            desc: root.desc === 'false' ? false : true
            orderBy: root.orderBy
            market: root.market
            type: root.type
        }
    }

    Component {
        id: ziXuanDataProvider
        ZiXuanDataProvider {
            parent: root
            type: root.type
        }
    }

    Component {
        id: cyIndexDataProvider
        CyIndexDataProvider {
            parent: root
        }
    }

    Loader {
        id: loader
        sourceComponent: isZixuan ? ziXuanDataProvider :( type === 7 ? cyIndexDataProvider : marketDataProvider)
    }

    property var dataProvider: loader.item
    property var totalData: dataProvider.model

    property string currTitle: {
        var m = "";
        if (type === 0 || type === 6) {
            var _market = root.market;
            if (_market === "SH") _market = "61";
            if (_market === "SZ") _market = "63";

            m = appConfig.marketNameMap[_market] || "";
        } else if (type === 1 || type === 3) {
            m = "自选股";
        } else if (type === 2) {
            m = "最近浏览";
        } else if (type === 4) {
            m = "大智慧板块指数";
        } else if (type === 5) {
            BlockUtil.getBlockName(market, function(name) {
                m = name;
            });
        }else if (type === 7) {
            m = "常用指数";
        }
        return m;
    }

    Rectangle{
        id: navigation
        width: parent.width
        height: 30
        color: theme.stockListNavigationBackGroundColor

        RowLayout {
            id:btnRect
            //anchors.fill: parent
            anchors.left: navigation.left
            height: parent.height
            width: parent.width - listBtn.width


            PanelButton {
                id: dxspiritBtn
                anchors.left: parent.left
                width: 83
                height: parent.height
                panelButtonLeftPadding: 15
                panelButtonRightPadding: 15
                panelButtonTopMargin: 0
                panelButtonBottomMargin: 0
                panelButtonBorderWidth: 0
                text: "短线精灵"
                checked: root.topButtonIndex === 0
                onClickTriggered: {
                    root.topButtonIndex = 0;
                }
            }
            //分割线
            SeparatorLine {
                id: topButtonLine
                orientation: Qt.Vertical
                length: parent.height
                anchors.left: dxspiritBtn.right
            }
            MenuButton {
                id: marketBtn
                //width: parent.width - dxspiritBtn.width
                width: 83
                anchors.right: parent.right
                anchors.left: topButtonLine.right
                height: parent.height
                text: currTitle
                minimumPopMenuWidth: marketBtn.width
                menu: isZixuan ? ziXuanListMenu : marketListMenu
                color: root.topButtonIndex === 0 ? "transparent":theme.backgroundColor
                hoverEnabled: true
                isTextClickedDropDownEnable: false
                checkedColor: theme.toolbarButtonCheckedColor
                hoveredColor: theme.toolbarButtonCheckedColor
                backgroundColor: theme.stockTableNavigationBackGroundColor
                checked: root.topButtonIndex === 1
                clip: true

                PopMenu {
                    id: marketListMenu
                    checkableStyle: true


                    PopMenu {
                        id: _60_secondMenu
                        checkableStyle: true
                        title: "沪深市场"
                        ExclusiveGroup { id: _60_group }
                        MenuItem { text: "沪深A股"; checkable: true; checked: market==='60'; onTriggered: marketBtn.process("60", 0); exclusiveGroup:_60_group}
                        MenuItem { text: "上证A股"; checkable: true; checked: market==='61'; onTriggered: marketBtn.process("61", 0); exclusiveGroup:_60_group}
                        MenuItem { text: "深圳A股"; checkable: true; checked: market==='63'; onTriggered: marketBtn.process("63", 0); exclusiveGroup:_60_group}
                        MenuItem { text: "创业板"; checkable: true; checked: market==='67'; onTriggered: marketBtn.process("67", 0); exclusiveGroup:_60_group}
                        MenuItem { text: "中小企业板"; checkable: true; checked: market==='69'; onTriggered: marketBtn.process("69", 0); exclusiveGroup:_60_group}
                        MenuItem { text: "风险警示"; checkable: true; checked: market==='st'; onTriggered: marketBtn.process("st", 0); exclusiveGroup:_60_group}
                    }

                    MenuItem { text: "大智慧板块指数"; onTriggered: marketBtn.process("B$", 4);}

                    PopMenu {
                        id: _index_secondMenu
                        checkableStyle: true
                        title: "沪深指数"
                        ExclusiveGroup { id: _index_group }
                        MenuItem { text: "上证指数"; checkable: true; checked: market==='SHINX'; onTriggered: marketBtn.process("SHINX", 0); exclusiveGroup: _index_group;}
                        MenuItem { text: "深证指数"; checkable: true; checked: market==='SZINX'; onTriggered: marketBtn.process("SZINX", 0); exclusiveGroup: _index_group;}
                    }
                    MenuItem { text: "常用指数"; onTriggered: marketBtn.process("CYINX", 7);}

                    PopMenu {
                        id: _fund_secondMenu
                        checkableStyle: true
                        title: "基金"
                        ExclusiveGroup { id: _fund_group }
                        MenuItem { text: "ETF基金"; checkable: true; checked: market==='ETFFund'; onTriggered: marketBtn.process("ETFFund", 0); exclusiveGroup:_fund_group}
                        MenuItem { text: "封闭基金"; checkable: true; checked: market==='ClosedFund'; onTriggered: marketBtn.process("ClosedFund", 0); exclusiveGroup:_fund_group}
                        MenuItem { text: "LOF基金"; checkable: true; checked: market==='LofFund'; onTriggered: marketBtn.process("LofFund", 0); exclusiveGroup:_fund_group}
                        MenuItem { text: "分级基金A"; checkable: true; checked: market==='GradingFundA'; onTriggered: marketBtn.process("GradingFundA", 0); exclusiveGroup:_fund_group}
                        MenuItem { text: "分级基金B"; checkable: true; checked: market==='GradingFundB'; onTriggered: marketBtn.process("GradingFundB", 0); exclusiveGroup:_fund_group}
                        MenuItem { text: "T+0基金"; checkable: true; checked: market==='T0Fund'; onTriggered: marketBtn.process("T0Fund", 0); exclusiveGroup:_fund_group}
                    }

                }

                PopMenu {
                    id: ziXuanListMenu
                    checkableStyle: true
                    MenuItem { text: "自选股"; onTriggered: {root.type = 1;root.topButtonIndex = 1;}}
                    MenuItem { text: "最新浏览"; onTriggered: {root.type = 2;root.topButtonIndex = 1;}}
                }

                onClicked: {
                    root.topButtonIndex = 1;
                }

                function process(m, t) {
                    root.market = m;
                    root.type = t;
//                    root.obj = "";

                    leftSideListView.toTop();

                    root.topButtonIndex = 1;
                }
            }
        }

        PanelIconButton {
            id: listBtn
            anchors.right: navigation.right
            alignRight: true
            imageRes: theme.iconList
            onClickTriggered: {
                //type默认0表示6系列的主列表 1自选 2最近浏览 3键盘宝 4板块B$ 5板块成分股 6基金
                if (type === 1 || type === 2 || type === 3 ) {
                    root.context.pageNavigator.push(appConfig.routePathSelfStock);
                } else {
                    root.context.pageNavigator.push(appConfig.routePathMarketList, {'market':market, 'isSprite':'false'});
                }
            }
        }
        SeparatorLine {
            anchors.bottom: parent.bottom
            orientation: Qt.Horizontal
            length: parent.width
        }
    }

    LeftSideListView {
        id: leftSideListView
        width: root.width
        anchors.bottom: root.bottom
        anchors.top: navigation.bottom
        model: totalData
        visible: root.topButtonIndex === 1
    }

    DxSpiritListView{
        id: dxspiritLeftListView
        width: root.width
        anchors.bottom: root.bottom
        anchors.top: navigation.bottom
        visible: root.topButtonIndex === 0
        currentObjRight: leftSideListView.obj
    }
}

