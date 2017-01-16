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

ContextComponent {
    id: root
    property Item floatContent: null
    property Item keyboardSprite: null
    property bool isNetworkConnecting: false
    property bool __isFirstStarted: true  //是否第一次启动的记录
    focusAvailable: false
    Rectangle {
        id: statusBar
        height: theme.statusbarHeight
        width: parent.width
        color: theme.backgroundColor
        RowLayout {
            id: statusBarLayout
            anchors.fill: parent

            Rectangle{
                height: parent.height
                Layout.preferredWidth: (theme.statusbarIndexNameWidth + theme.statusbarIndexValueWidth + theme.statusbarIndexDiffWidth + theme.statusbarIndexPersentWidth + theme.statusbarIndexAmountWidth) * 3
                Layout.maximumWidth: Layout.preferredWidth
                Layout.fillWidth: true
                ListView{
                    id: listView
                    spacing: 0
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    snapMode: ListView.SnapOneItem
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    model: model
                    delegate: componentDelegate
                    onWidthChanged: {
                        if (width < (theme.statusbarIndexNameWidth + theme.statusbarIndexValueWidth) * 3){
                            listView.visible = false
                        }else{
                            listView.visible = true
                        }
                    }
                }
            }

            Rectangle {
                color: "transparent"
                height: parent.height
                Layout.fillWidth: true
            }

            Rectangle {
                height: parent.height
                Layout.preferredWidth: theme.statusbarTimerWidth + theme.statusbarButtonWidth * 3 + 2
                Layout.maximumWidth: Layout.preferredWidth
                Layout.minimumWidth: Layout.preferredWidth
                color: "transparent"
                Row {
                    layoutDirection: Qt.RightToLeft
                    anchors.fill: parent
                    Text{
                        id: timeText
                        width: theme.statusbarTimerWidth
                        height: applicationContent.theme.statusbarHeight
                        text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                        Timer {
                            id: timer
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: {
                                timeText.text = Qt.formatDateTime(
                                            new Date(), "hh:mm:ss")
                            }
                        }
                    }
                    ImageButton {
                        id: timerButton
                        width: theme.statusbarButtonWidth
                        height: applicationContent.theme.statusbarHeight
                        imageRes: applicationContent.theme.iconTimer
                        imageSize: Qt.size(24, 24)
                    }

                    SeparatorLine {
                        y: 2
                        orientation: Qt.Vertical
                        length: applicationContent.theme.statusbarHeight - 4
                    }
                    ImageButton {
                        id: networkButton
                        width: theme.statusbarButtonWidth
                        height: applicationContent.theme.statusbarHeight
                        imageRes: isNetworkConnecting ? applicationContent.theme.iconNetwork : applicationContent.theme.iconNetworkOffline
                        imageSize: Qt.size(24, 24)

                        onHoverTriggered:{
                            //鼠标移动事件触发信号
                            hint.visible = true
                            hint.z = 90
                        }
                        onHoverExitTriggered:{
                            //鼠标移出事件触发信号
                            hint.visible = false
                            hint.z = -1
                        }

                        Rectangle {
                            id: hint
                            anchors.top: parent.top
                            anchors.topMargin: -text.height - 2
                            width: text.width + 10
                            height: text.height + 4
                            radius: theme.indicatorRadius
                            border.color:  theme.indicatorBorderColor
                            border.width: 1
                            color: theme.indicatorBackgroundColor
                            visible: false
                            Text {
                                id: text
                                anchors.centerIn: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: theme.indicatorTextColor
                                text: isNetworkConnecting ? '网络连接正常' : '网络已断开'
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onDoubleClicked: {

                                // 打开登录框
                                context.mainWindow.loginWindow.show();
                            }
                        }
                    }

                    SeparatorLine {
                        y: 2
                        orientation: Qt.Vertical
                        length: applicationContent.theme.statusbarHeight - 4
                    }

                    ImageButton {
                        id: searchButton
                        width: theme.statusbarButtonWidth
                        height: applicationContent.theme.statusbarHeight
                        imageRes: applicationContent.theme.iconSearch
                        imageSize: Qt.size(24, 24)
                        onClickTriggered: {
                            if (!keyboardSprite.visible) {
                                keyboardSprite.show("")
                            } else {
                                keyboardSprite.hide()
                            }
                        }
                    }
                }
            }
        }

    }

    Component{
        id: componentDelegate
        Rectangle {
            color: "transparent"
            height: parent.height
            width: {
                var widthTwo = theme.statusbarIndexNameWidth + theme.statusbarIndexValueWidth
                var widthThree = widthTwo + theme.statusbarIndexDiffWidth
                var widthFour = widthThree + theme.statusbarIndexPersentWidth
                var widthFive = widthFour + theme.statusbarIndexAmountWidth
                if (listView.width >= widthFive*3){
                    return widthFive
                }else if (listView.width >= widthFour * 3){
                    return widthFour
                }else if (listView.width >= widthThree * 3){
                    return widthThree
                }else{
                    return widthTwo
                }
            }
            clip: true
            Text {
                id: indexName
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                width: theme.statusbarIndexNameWidth
                text: name + ":"
            }
            Label {
                id: indexValue
                anchors.left: indexName.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                width: theme.statusbarIndexValueWidth
                value: zuiXin
                baseValue: zuoShou
                isAutoFormat: true
                hasSuffix: true
                defaultText: "--"
            }
            Label {
                id: indexDiff
                anchors.left: indexValue.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                width: theme.statusbarIndexDiffWidth
                value: zhangDie
                baseValue: 0
                hasSign: true
                isAutoFormat: true
                defaultText: "--"
            }

            Label {
                id: indexPersent
                anchors.left: indexDiff.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                width: theme.statusbarIndexPersentWidth
                value: zhangFu / 100
                baseValue: 0
                unit: "%"
                hasSign: true
                isAutoFormat: true
                defaultText: "--"
            }

            Label {
                id: indexAmount
                anchors.left: indexPersent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                width: theme.statusbarIndexAmountWidth
                precision: 2
                value: chengJiaoE
                unit: "万/亿"
                normalColor: theme.volColor
                defaultText: "--"
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (trendLoader.visible && trendLoader.item.obj === code){
                        hideTimer.stop()
                    }
                    showTimer.start()
                }
                onExited: {
                    showTimer.stop()
                    hideTimer.start()
                }
            }

            Timer{
                id: showTimer
                interval: 500
                running: false
                repeat: false
                onTriggered: {
                    if (!trendLoader.visible) {
                        var pointObj = mapToItem(floatContent, 0, 0)

                        trendLoader.x = pointObj.x + 4
                        trendLoader.y = pointObj.y - trendLoader.height
                        trendLoader.parent = floatContent
                        trendLoader.active = true
                        trendLoader.item.obj = code
                        trendLoader.visible = true
                    }
                }
            }
        }
    }

    Timer{
        id: hideTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            trendLoader.active = false
            trendLoader.visible = false
        }
    }
    ListModel{
        id: model
        ListElement{
            name: "上证指数"
            code: "SH000001"
            zhangFu: 0
            zhangDie: 0
            zuoShou: 0
            zuiXin: 0
            chengJiaoE: 0
        }
        ListElement{
            name: "深证成指"
            code: "SZ399001"
            zhangFu: 0
            zhangDie: 0
            zuoShou: 0
            zuiXin: 0
            chengJiaoE: 0
        }
        ListElement{
            name: "创业板指"
            code: "SZ399006"
            zhangFu: 0
            zhangDie: 0
            zuoShou: 0
            zuiXin: 0
            chengJiaoE: 0
        }
    }

    //指数行情请阅
    DataProvider {
        id: indexSubscribe
        serviceUrl: "/stkdata"
        sub: 1
        direct: true;
        autoQuery: false
    }

    Loader{
        id: trendLoader
        width: theme.statusbarPopRectWidth
        height: theme.statusbarPopRectHeight
        z:100
        sourceComponent: miniChart
        asynchronous: false
        visible: false
        active : false
    }

    Component{
        id: miniChart
        RectangleWithBorder{
            color: "white"
            leftBorder: 1
            rightBorder: 1
            topBorder: 1
            bottomBorder: 1
            property alias obj: miniChartCompontent.obj
            MiniChartComponent{
                id: miniChartCompontent
                anchors.fill: parent
            }
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    //点击股票跳转
                    hideTimer.start()
                    context.pageNavigator.push(appConfig.routePathStockDetail, {'market':'', 'type':2, 'obj':obj, 'chart':'min'})
                }
                onExited: {
                    hideTimer.start()
                }
                onEntered: {
                    hideTimer.stop()
                }
            }
        }
    }

    Connections {
        target: indexSubscribe
        onSuccess: {
            if(data){
                var results = data.Data;
                var itemResult = null;
                for (var index in results){
                    itemResult = results[index];
                    for (var i = 0; i < model.count; i++)
                    {
                        if ( model.get(i).code === itemResult.Obj){
                            var itemModel = model.get(i);
                            if (itemResult){
                                itemModel.zuoShou = itemResult.ZuoShou;
                                if (itemResult.ZuiXinJia){
                                    if (itemResult.ZuiXinJia === 0){
                                        //价格为0时，则全部显示为0
                                        itemModel.zuoShou = 0;
                                        itemModel.zuiXin = 0;
                                        itemModel.zhangFu = 0;
                                        itemModel.zhangDie = 0;
                                        itemModel.chengJiaoE = 0;
                                    }else{
                                        //正常状态
                                        itemModel.zuiXin = itemResult.ZuiXinJia;
                                        itemModel.zhangFu = itemResult.ZhangFu;
                                        itemModel.zhangDie = itemResult.ZhangDie;
                                        itemModel.chengJiaoE = itemResult.ChengJiaoE;
                                    }
                                }else{
                                    //最新价为null，全部显示为--
                                    itemModel.zuiXin = NaN;
                                    itemModel.zhangFu = NaN;
                                    itemModel.zhangDie = NaN;
                                    itemModel.chengJiaoE = NaN;
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        onError: {
            console.log(error);
        }
    }

    Component.onCompleted: {
        indexSubscribe.params = ({
                                     obj: "SH000001,SZ399001,SZ399006",
                                     field: "ZuiXinJia,ZhangFu,ZhangDie,ZuoShou,ChengJiaoE"
                                 })
        indexSubscribe.query()
    }

    //网络断开连接
    onDisconnect: {
        isNetworkConnecting = false
        indexSubscribe.cancel()
    }

    //网络重新连接
    onReconnect: {
        isNetworkConnecting = true
        indexSubscribe.query()
    }

    onOpen: {
        if (__isFirstStarted){
            __isFirstStarted = false
            isNetworkConnecting = true
        }
    }
}
