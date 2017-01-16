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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "../core"
import "../core/data"
import "../chart"
import "../controls"
import "../components"
import "../util"
import "../newChart"
BasePage {
    id: root;

    property var list: [{obj: 'SH000001'}, {obj: 'SH600000'}, {obj: 'SH601519'}];
    property int index: root.list.map(function(item) { return item.obj }).indexOf(root.obj);
    property var stock: StockUtil.stock.createObject(root);

    property alias obj: leftSideBar.obj
    property alias orderBy: leftSideBar.orderBy
    property alias desc: leftSideBar.desc
    property alias market: leftSideBar.market
    property alias type: leftSideBar.type

    property color titleTextColor: '#294683'

    property string chart: 'min'
    property string period: '1day'

    property bool showLeftSideBar: true
    property bool showRightSideBar: true
    property bool showBottomPanel: true

    //F10的界面控制逻辑
    property bool showF10RightSideBar: false
    property bool showF10BottomPanel: false

    property var historyMinParams

    title: '${stock[' + root.obj + '].name}'

    RowLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: leftRec
            Layout.fillHeight: true
            Layout.preferredWidth: showLeftSideBar ? 200 : 0
//            visible: showLeftSideBar

            LeftSideBar {
                id: leftSideBar
                anchors.fill: parent
            }
        }

        RectangleWithBorder {
            leftBorder: showLeftSideBar ? 1 : 0
            rightBorder: showRightSideBar ? 1 : 0
            border.color: '#aec1da'
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                Panel {
                    id: mainPanel
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    closeButtonEnable: false
                    bottomBorder: 1

                    property var showMenuItems: mainPanel.contentItem ? mainPanel.contentItem.showMenuItems : null
                    property var customButtons: mainPanel.contentItem ? mainPanel.contentItem.customButtons : null

                    header: RowLayout {
                        spacing: 2
                        PanelIconButton {
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft
                            exitedWhenClicked: true
                            alignLeft: true
                            imageRes: theme.iconLeftHide
                            onClickTriggered: {
                                showLeftSideBar = !showLeftSideBar
                            }
                        }
                        Text {
                            id: text
                            property var stock: StockUtil.stock.createObject(root);

                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: 150
                            Layout.leftMargin: 6
                            verticalAlignment: Qt.AlignVCenter
                            text: stock.name + ' ' + stock.code
                            color: titleTextColor
                        }
                        Repeater {
                            model: [
                                {chart: 'min', text: '分时'},
                                {chart: 'kline', text: '日K', period: '1day'},
                            ]

                            PanelButton {
                                Layout.fillHeight: true
                                Layout.preferredWidth: width
                                text: modelData.text
                                checked: root.chart === modelData.chart && root.period === (modelData.period || root.period)
                                onClickTriggered: {
                                    root.chart = modelData.chart;
                                    if (modelData.period) {
                                        root.period = modelData.period;
                                    }
                                }
                            }
                        }
                        PanelButton {
                            id: _klinePeriodButton
                            Layout.fillHeight: true
                            Layout.preferredWidth: width
                            checked: root.chart === currentItem.chart && root.period === (currentItem.period || root.period)
                            onClickTriggered: {
                                root.period = data.period;
                                root.chart = data.chart;
                            }
                            currentItem: menuItems[2]
                            function changeCurrentItem() {
                                if (root.chart === 'kline') {
                                    menuItems.some(function(eachItem) {
                                        if (eachItem.period === root.period) {
                                            _klinePeriodButton.currentItem = eachItem;
                                            return true;
                                        }
                                    });
                                }
                            }
                            Connections {
                                target: root
                                onChartChanged: {
                                    _klinePeriodButton.changeCurrentItem();
                                }

                                onPeriodChanged: {
                                    _klinePeriodButton.changeCurrentItem();
                                }
                            }

//                            property var _lastChosedItem: {
//                                console.log(222222, JSON.stringify(menuItems[2]))
//                                return [menuItems[2]];
//                            }
//                            currentItem: {
//                                var _currentItem;
//                                if (root.chart === 'kline') {
//                                    menuItems.some(function(eachItem) {
//                                        if (eachItem.period === root.period) {
//                                            _currentItem = eachItem;
//                                            return true;
//                                        }
//                                    });
//                                }
//                                console.log(111111, JSON.stringify(_lastChosedItem[0]));
//                                return _lastChosedItem[0] = (_currentItem || _lastChosedItem[0]);
//                            }
                            menuItems: [
                                ['1分钟', '1min'],
                                ['5分钟', '5min'],
                                ['15分钟', '15min'],
                                ['30分钟', '30min'],
                                ['60分钟', '60min'],
                                ['周K', 'week'],
                                ['月K', 'month'],
                                ['季K', 'season'],
                                ['半年K', 'halfyear'],
                                ['年K', 'year']
                            ].map(function(eachData) {
                                return {
                                    chart: 'kline',
                                    text: eachData[0],
                                    period: eachData[1],
                                    checked: root.chart === 'kline' && root.period === eachData[1]
                                }
                            })
                        }
                        PanelButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: width
                            text: '个股资料'
                            checked: root.chart === 'f10'
                            onClickTriggered: {
                                root.chart = 'f10';
//                                context.pageNavigator.push('/f10?obj=' + root.obj);
                            }
                            property bool __visible: [1, 2, 10, 11].indexOf(stock.type) !== -1
                            visible: __visible
                            onVisibleChanged: {

                                // 切换股票到指数时，隐藏F10按钮，当前如果选中的是F10则切换到分时
                                if (!__visible && root.chart === 'f10') {
                                    root.chart = 'min';
                                }
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Repeater {
                            model: (mainPanel.customButtons || []).length
                            PanelButton {
                                property var buttonData: mainPanel.customButtons[modelData]
                                Layout.fillHeight: true
                                Layout.alignment: Qt.AlignRight
                                Layout.preferredWidth: width
                                text: buttonData.text
                                onClickTriggered: {
                                    buttonData.triggered(data);
                                }
                            }
                        }
                        PanelButton {
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: width
                            text: '显示'
                            clickOpenMenu: true
                            visible: !!mainPanel.showMenuItems
                            menuItems: mainPanel.showMenuItems
                        }
                        PanelIconButton {
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignRight
                            alignRight: true
                            imageRes: theme.iconRightHide
                            exitedWhenClicked: true
                            onClickTriggered: {
                                if (chart === 'f10'){
                                    showF10RightSideBar = !showF10RightSideBar
                                }else{
                                    showRightSideBar = !showRightSideBar
                                }
                            }
                        }
                    }
                    content: ContextComponent {
                        property var showChild: Array.prototype.filter.call(children, function(children) {return children.visible && children.toString().indexOf('MouseArea') < 0})[0]

                        property var showMenuItems: showChild ? showChild.showMenuItems : undefined
                        property var customButtons: showChild ? showChild.customButtons : undefined

                        contextMenuItems: [
                            createMenuItem(portfolioContextMenuItem, {obj: root.obj}),
                            createMenuItem(f10ContextMenuItem, {obj: root.obj})
                        ].concat(showMenuItems || [])

                        MouseArea {
                            anchors.fill: parent
                            onWheel: {
                                if (!timer.running) {
                                    timer.start();
                                    if (wheel.angleDelta.y > 5) {
                                        leftSideBar.listView.prevOne();
                                    } else if (wheel.angleDelta.y < -5) {
                                        leftSideBar.listView.nextOne();
                                    }
                                }
                            }

                            onDoubleClicked: {
                                root.switchMinKline();
                                mouse.accepted = true;
                            }

                            Timer {
                                id: timer
                                interval: 500
                            }
                        }

                        MouseArea{
                            //F10右键屏蔽问题处理
                            id: forbidRightClick
                            anchors.fill: parent
                            hoverEnabled: f10.visible
                            enabled: f10.visible

                            onEntered: {
                                if (f10.visible){
                                    root.context.mainWindow.isSelectedWebViewState = true;
                                }
                            }

                            onExited: {
                                if (f10.visible){
                                    root.context.mainWindow.isSelectedWebViewState = false;
                                }
                            }

                            F10 {
                                id: f10
                                anchors.fill: parent
                                visible: root.chart === 'f10'
                                obj: root.obj

                                onVisibleChanged: {
                                    if (visible) {
//                                        root.context.mainWindow.isSelectedWebViewState = true;
                                        bottomPanel.showContent = showF10BottomPanel
                                    }else{
                                        root.context.mainWindow.isSelectedWebViewState = false;
                                        bottomPanel.showContent = showBottomPanel
                                    }
                                }

                            }
                        }
                        KlineCanvas {
                            id: klineCanvas
                            anchors.fill: parent
                            visible: root.chart === 'kline'
                            obj: root.obj
                            period: root.period

                            Component.onCompleted: {
                                root.historyMinParams = Qt.binding(function() {
                                    return klineCanvas.historyMinParams;
                                });
                            }
                        }
                        MinCanvas {
                            id: minCanvas
                            anchors.fill: parent
                            visible: root.chart === 'min'
                            obj: root.obj
                        }
                    }
                }
                TabPanel {
                    id: bottomPanel
                    Layout.fillWidth: true
                    Layout.preferredHeight: height
                    fixedHeight: 150
                    // 基金(板块以及普通指数)底部没有可以显示的内容因此不显示底部区域
                    visible:  !(stock.isFund || (stock.type === 0 && (['SH000001', 'SZ399001', 'SZ399006'].indexOf(stock.obj) === -1)))                    

                    Tab {

                        // Level2行情的股票才能查看买卖队列
                        title: stock.type === 1 && UserService.isLevel2 ? "买卖队列" : ''
                        active: true
                        Rectangle{
                            color: theme.backgroundColor
                            anchors.fill: parent
                            BuySellQueueComponent {
                                obj: root.obj
                                //buySellDataProvider: rightSideBar.dataProvider
                                anchors.fill: parent
                            }
                        }
                    }

                    Tab {
                        title: "资讯"
                        Rectangle{
                            color: theme.backgroundColor
                            anchors.fill: parent
                            NewsComponent {
                                obj: root.obj
                                anchors.fill: parent
                            }
                        }
                    }

                    Tab{
                        title:  stock.type === 1 ? '关联报价' : ''
                        Rectangle{
                            color: theme.backgroundColor
                            anchors.fill: parent
                            RelatedQuoteComponent {
                                obj: root.obj
                                anchors.fill: parent
                            }
                        }

                    }

                    onContentVisibleChanged: {
                        //记录当前页面的底部布局状态
                        if(chart === 'f10'){
                            showF10BottomPanel = contentVisible
                        }else{
                            showBottomPanel = contentVisible
                        }
                    }
                }
            }

        }

        RightSideBar {
            id: rightSideBar
            Layout.fillHeight: true
            Layout.preferredWidth: 260
            visible: chart === 'f10' ? showF10RightSideBar : showRightSideBar
            obj: root.obj
            sideBarType: 2
            market: root.market
            marketType:leftSideBar.type
        }
    }

    // 历史分时框
    HistoryMinCanvas {
        historyMinParams: root.historyMinParams
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 600
        height: 400
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_PageDown) {
            leftSideBar.listView.nextOne();
            event.accepted = true;
        } else if (event.key === Qt.Key_PageUp) {
            leftSideBar.listView.prevOne();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_F5) {
            if (root.chart === 'f10'){
                root.chart = 'min';
            }else{
                switchMinKline();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_F8) {
            if (root.chart === 'min') {
                root.period = '1min';
                root.chart = 'kline';
            } else if (root.chart === 'kline' && root.period !== 'year') {
                var periods = ['1min', '5min', '15min', '30min',
                               '60min', '1day', 'week', 'month',
                               'season', 'halfyear', 'year'];
                var currentPeriodIndex = periods.indexOf(root.period);
                root.period = periods[currentPeriodIndex + 1];
            } else {
                root.chart = 'min';
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_F10){
            context.pageNavigator.push(appConfig.routePathStockDetail, {'chart':'f10', 'obj':root.obj});
        }
    }

    function switchMinKline() {
        if (root.chart === 'kline') {
            root.chart = 'min';
        } else {
            root.chart = 'kline';
        }
    }

    // 当obj变化时，记录查看股票历史
    onObjChanged: {
        if (root.obj) {
            HistoryUtil.add({obj: root.obj});
        }
    }

    onReconnect: {
        // 重连后设置页面可见状态，使页面重新中组件重新请求
        root.visible = false;
        root.visible = true;
    }

    onAfterActive: {
        //进入没有F1O页面的商品是的特殊处理        
        if ((root.chart === 'f10') && ([1, 2, 10, 11].indexOf(stock.type) === -1)){
            root.chart = 'min';
        }
    }
}
