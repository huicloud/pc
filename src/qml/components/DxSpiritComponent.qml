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
import QtQuick.Window 2.2
import "../core"
import "../core/data"
import "../controls"
import "../util"
import "../js/DateUtil.js" as DateUtil

/**
 * 短线精灵数据组件
 *
 */
ContextComponent {
    id: root
    width: 350
    height: 300

    property var context: ApplicationContext
    //弹出窗口数据列表
    property var showData: []
    property var tickData: []
    property var lastData: ({})

    property bool hasMoreData: true

    //请求的通知类型参数
    property var tongZhiList: "*"
    //是否只显示自选股股票
    property bool isFilterZiXuan: false
    //是否只显示当前股票
    property bool isFilterCurrentObj: false

    //自选股对象，属性为自选股代码
    property var ziXuanMap:({})
    //页面当前股票代码
    property string currentObj:''

    //股票映射表，现在只是用于获取股票中文简称
    property var stockMap:({})

    property color upColor: theme.dxspiritUpColor
    property color downColor: theme.dxspiritDownColor
    property color ddColor: theme.dxspiritDdColor
    property color jgUpColor: theme.dxspiritJgUpColor
    property color jgDownColor: theme.dxspiritJgDownColor

    //通知类型映射表
    property var tongZhiMap: {
        "HJFS":{name:"火箭发射",chart:"↑",color:upColor,fontsize:rowFontSize},
        "KSFT":{name:"快速反弹",chart:"▲",color:upColor,fontsize:rowFontSize},
        "GTTS":{name:"高台跳水",chart:"↓",color:downColor,fontsize:rowFontSize},
        "JSXD":{name:"加速下跌",chart:"▼",color:downColor,fontsize:rowFontSize},
        "DBMR":{name:"大笔买入",chart:"▲",color:upColor,fontsize:rowFontSize},
        "DBMC":{name:"大笔卖出",chart:"▼",color:downColor,fontsize:rowFontSize},
        "FZTB":{name:"封涨停板",chart:"▲",color:upColor,fontsize:rowFontSize},
        "FDTB":{name:"封跌停板",chart:"▼",color:downColor,fontsize:rowFontSize},
        "DKZT":{name:"打开涨停",chart:"▼",color:upColor,fontsize:rowFontSize},
        "DKDT":{name:"打开跌停",chart:"▲",color:downColor,fontsize:rowFontSize},
        "YDMCP":{name:"有大卖盘",chart:"▼",color:ddColor,fontsize:rowFontSize},
        "YDMRP":{name:"有大买盘",chart:"▲",color:ddColor,fontsize:rowFontSize},
        "LSZS":{name:"拉升指数",chart:"▲",color:upColor,fontsize:rowFontSize},
        "DYZS":{name:"打压指数",chart:"▼",color:downColor,fontsize:rowFontSize},
        "JGMRGD":{name:"机构买单",chart:"▲",color:jgUpColor,fontsize:rowFontSize},
        "JGMCGD":{name:"机构卖单",chart:"▼",color:jgDownColor,fontsize:rowFontSize},
        //"DCJMRD":{name:"大笔买入",chart:"▲",color:upColor,fontsize:rowFontSize},
        //"DCJMCD":{name:"大笔卖出",chart:"▼",color:downColor,fontsize:rowFontSize},
        "FDMRGD":{name:"分单买单",chart:"▲",color:upColor,fontsize:rowFontSize},
        "FDMCGD":{name:"分单卖单",chart:"▼",color:downColor,fontsize:rowFontSize},
        "MRCD":{name:"买入撤单",chart:"▼",color:downColor,fontsize:rowFontSize},
        "MCCD":{name:"卖出撤单",chart:"▲",color:upColor,fontsize:rowFontSize},
        "MRXD":{name:"买入新单",chart:"▲",color:jgUpColor,fontsize:rowFontSize},
        "MCXD":{name:"卖出新单",chart:"▼",color:jgDownColor,fontsize:rowFontSize}
    }

    //过滤tongZhiMap中没有的通知类型
    function isExistInTongZhiMap(element, index, array) {
        return tongZhiMap[element.TongZhi];
    }
    //过滤不在自选股中的股票
    function isExistInZiXuanMap(element, index, array) {
        //console.info("Com:",element.Obj,ziXuanMap.hasOwnProperty(element.Obj));
        return ziXuanMap.hasOwnProperty(element.Obj);
    }

    //过滤不等于当前的股票
    function isEqualCurrentObj(element, index, array) {
        console.info("isEqualCurrentObj:",currentObj,element.Obj,element.Obj === currentObj);
        return element.Obj === currentObj;
    }

    onIsFilterZiXuanChanged: {
        if(isFilterZiXuan){
            tickData = filterData(tickData);
        }
    }
    onIsFilterCurrentObjChanged: {
        if(isFilterCurrentObj){
            tickData = filterData(tickData);
        }
    }

    // 弹出窗口，用作请求更多数据
    property DataProvider requestDataProvider: DataProvider {
        serviceUrl: '/dxspirit'
        params: ({
            count: 100,
            notice: tongZhiList,
            'gql': 'block=股票/市场分类/全部A股'
        })
        autoQuery: false
        function adapt(nextData) {
            //return nextData[0].Data;
            return nextData;
        }

        onSuccess: {
            data = filterData(data);
            // 合并数据
            var lastLength = tickData.length;
            var lastTime = tickData[0].ShiJian;
            if (data.length !== 100) {
                // 请求到重复时间数据表示不再有更多数据
                hasMoreData = false;
            }
            var eachData;
            for (var i = data.length - 1; i >= 0; i--) {
                eachData = data[i];
                tickData.unshift(eachData);
            }

            tickData = tickData.concat([]);
            var yPosition = (showStartIndex + (tickData.length - lastLength)) / tickData.length;
            flicker.contentY = yPosition * flicker.contentHeight;

            updateShowData();
        }
    }

    // 弹出窗口，用作订阅最新数据
    property DataProvider subscribeDataProvider: DataProvider {
        parent: root
        serviceUrl: '/dxspirit'
        params: ({
            notice: tongZhiList,
            'gql': 'block=股票/市场分类/全部A股',
            start: -100
        })
        sub: 1

        function adapt(nextData) {
            return nextData;
        }

        onSuccess: {
            data = filterData(data);
            //判断当前滚动条位置
            if(flicker.state === 'autoscroll'){
                //本地只保存100条数据
                var tempData = tickData;
                tempData = counter > 1 ? tempData.concat(data) : data;
                if(tempData.length > 100){
                    tempData.splice(0,tempData.length - 100);
                }
                tickData = tempData;

            }else{
                tickData = counter > 1 ? tickData.concat(data) : data;
            }

            updateShowData();

            //console.info("DxCompenent sub:",flicker.state,data.length,flicker.contentY,flicker.contentHeight)
            // 追加最新的数据
            //tickData = counter > 1 ? tickData.concat(data) : data;
        }
    }

    function updateShowData(){
        if (showStartIndex >= 0 && showCount > 0 && tickData.length > 0) {
            // 需要显示的数据
            var arr = tickData.slice(showStartIndex, showStartIndex + showCount);
            var lastLabel, currentLabel, volume, tick, label, showSecond, updown, currentPrice, lastPrice;
            showData = arr.map(function(eachData, index) {
                currentLabel = DateUtil.moment.unix(eachData.ShiJian).format('HH:mm:ss');
                if(!stockMap[eachData.Obj]){
                    var stockCom = stockComponent.createObject(root,{obj:eachData.Obj});
                    var stock = StockUtil.stock.createObject(stockCom);
                    stockMap[eachData.Obj] = stock;
                }else{
                    //console.log("DxSpirit find:",eachData.Obj,stockMap[eachData.Obj].name)
                }

                return {
                    id: [eachData.ShiJian, eachData.Obj,index].join('_'),
                    obj:eachData.Obj,
                    time: eachData.ShiJian,
                    label: currentLabel,
                    name: stockMap[eachData.Obj].name,
                    tongzhi: eachData.TongZhi,
                    volume: eachData.ShuJu,
                }
            });
        } else {
            showData = [];
        }
    }

    property int rowFontSize: theme.tickLabelFontSize
    property int rowFontWeight: theme.tickLabelFontWeight
    property string rowFontFamily: theme.tickLabelFontFamily
    property int volumePreferredWidth: theme.tickVolumePreferredWidth

    //行边距信息
    property int rowLeftMargin: 0
    property int rowRightMargin: 0
    property int rowTopMargin: 0
    property int rowBottomMargin: 0
    property int rowHeight: 26


    property int minHeightPer: rowHeight
    property int showCount: Math.floor(height / minHeightPer);
    property int showStartIndex: Math.max(0, Math.ceil(flicker.visibleArea.yPosition * tickData.length))

    //当前选中的行
    property string selected

    //滚动条滚动时保存上次ContentY值
    property real lastContentY: 0


    onShowCountChanged: {
        //更新showData
        updateShowData();
    }


    Rectangle {
        anchors.fill: parent
        color: theme.backgroundColor
        clip: true

        Flickable {
            id: flicker
            anchors.fill: parent

            // 计算总数据高度
            contentHeight: minHeightPer * tickData.length
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Binding {
                target: flicker
                property: 'contentY'
                when: flicker.state === 'autoscroll'
                value: flicker.contentHeight - flicker.height;
            }

            onContentYChanged: {
                if (contentY >= flicker.contentHeight - flicker.height - 10) {
                    state = 'autoscroll';
                } else if (contentY !== 0) {
                    state = ''; // default state
                }
                //console.info("ContentY:",contentY,lastContentY,showStartIndex,showCount,showData.length,hasMoreData,tickData.length );
                // 滚动条到达最顶部，请求更多历史数据
                if (showStartIndex < showCount && hasMoreData && showData.length > 0) {
                //if ((contentY - lastContentY < 0) && contentY < minHeightPer && hasMoreData) {
                    requestDataProvider.params.start = -(tickData.length + 100);
                    requestDataProvider.query();
                }
                //lastContentY = contentY;

                if(state !== 'autoscroll'){
                    updateShowData();
                }
            }
        }
        ColumnLayout {
            id: layout
            anchors.fill: flicker
            anchors.rightMargin: scrollbar.visible ? 8 : 0
            anchors.leftMargin: 2
            spacing: 0
            clip: true
            Repeater {
                  model:showCount
//                model: {
//                    //console.log("DxSpirit Model:",showStartIndex,showCount,tickData.length);
//                    // TODO 考虑使用WorkerScript处理，避免数据过多时处理数据阻塞UI响应
//                    if (showStartIndex >= 0 && showCount > 0 && tickData.length > 0) {

//                        // 需要显示的数据
//                        var arr = tickData.slice(showStartIndex, showStartIndex + showCount);
//                        //console.log("DxSpirit Model:len",arr.length);
//                        var lastLabel, currentLabel, volume, tick, label, showSecond, updown, currentPrice, lastPrice;
//                        return arr.map(function(eachData, index) {
//                            //volume = eachData.DanCiChengJiaoLiang / stockCountUnit;
//                            currentLabel = DateUtil.moment.unix(eachData.ShiJian).format('HH:mm:ss');
//                            //console.log("DxSpirit:",currentLabel,eachData)
//                            if(!stockMap[eachData.Obj]){
//                                //console.log("DxSpirit no find:",eachData.Obj)
//                                var stockCom = stockComponent.createObject(root,{obj:eachData.Obj});
//                                //console.log("DxSpirit no find qml obj:",stockCom.obj)
//                                var stock = StockUtil.stock.createObject(stockCom);
//                                stockMap[eachData.Obj] = stock;
//                            }else{
//                                //console.log("DxSpirit find:",eachData.Obj,stockMap[eachData.Obj].name)
//                            }

//                            return {
//                                id: [eachData.ShiJian, eachData.Obj,index].join('_'),
//                                obj:eachData.Obj,
//                                time: eachData.ShiJian,
//                                label: currentLabel,
//                                name: stockMap[eachData.Obj].name,
//                                tongzhi: eachData.TongZhi,
//                                volume: eachData.ShuJu,
//                                updown:1
//                            }
//                        });
//                    } else {
//                        return [];
//                    }
//                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: scrollbar.visible ? true : false
                    Layout.preferredHeight: scrollbar.visible ? -1 : minHeightPer
                    color: showData.length > 0 ? (selected === showData[index].id || (!selected && modelData.last) ? '#ecf2ff' : 'transparent'):'transparent'
                    RowLayout {
                        spacing: 0
                        anchors.fill: parent
                        anchors.leftMargin: rowLeftMargin
                        anchors.rightMargin: rowRightMargin
                        anchors.topMargin: rowTopMargin
                        anchors.bottomMargin: rowBottomMargin
                        Text {
                            horizontalAlignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            //Layout.fillWidth: true
                            Layout.preferredWidth: 60
                            color: index  < showData.length ? tongZhiMap[showData[index].tongzhi].color:upColor
                            font.pixelSize: rowFontSize
                            font.weight: rowFontWeight
                            font.family: rowFontFamily
                            text: index  < showData.length ? showData[index].label:""
                        }
                        Text {
                            horizontalAlignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            //Layout.fillWidth: true
                            Layout.preferredWidth: 60
                            color: index  < showData.length ? tongZhiMap[showData[index].tongzhi].color:upColor
                            font.pixelSize: rowFontSize
                            font.weight: rowFontWeight
                            font.family: rowFontFamily
                            text:index  < showData.length ? stockMap[showData[index].obj].name : ""
                        }
                        Text {
                            horizontalAlignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            //Layout.fillWidth: true
                            Layout.preferredWidth: 60
                            color: index  < showData.length ? tongZhiMap[showData[index].tongzhi].color:upColor
                            font.pixelSize: index  < showData.length ? tongZhiMap[showData[index].tongzhi].fontsize : rowFontSize
                            font.weight: rowFontWeight
                            font.family: rowFontFamily
                            //fontSizeMode: Text.Fit
                            text: index  < showData.length ? tongZhiMap[showData[index].tongzhi].name : ""
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.last) {
                                selected = '';
                            } else {
                                selected = showData[index].id;
                            }
                        }
                        onEntered: {
                             root.focus = true;
                        }
                        onExited: {
                            root.focus = false;
                        }
                        onDoubleClicked: {
                            //路由跳转
                            var currentItem = {};
                            currentItem.Type = 0;
                            currentItem.Params = {'type':3, 'obj':showData[index].obj};
                            currentItem.DaiMa = showData[index].obj;
                            //UBAUtil.sendUserBehavior(UBAUtil.jianPanBaoTag, currentItem.DaiMa);
                            context.pageNavigator.kbspritePush(currentItem);
                        }
                    }
                }
            }

            // 用于填充剩余高度
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: scrollbar.visible ? false : true
                Layout.preferredHeight: 0
                height: 0
            }
        }
        VScrollBar {
            id: scrollbar
            flicker: flicker
        }
    }


    //创建股票时关联的组件
    Component{
        id:stockComponent
        Rectangle {
           property string obj
        }
    }

    function filterData(data){
        if(isFilterZiXuan){
            data = data.filter(isExistInZiXuanMap);
        }else if(isFilterCurrentObj){
            data = data.filter(isEqualCurrentObj);
        }

        return data;
    }

    // 清理方法，还原初始值，取消当前请求
    function clear() {
        subscribeDataProvider.cancel();
        hasMoreData = false;
        selected = "";
        tickData = [];
    }

    function show() {
        subscribeDataProvider.query();
        root.visible = true;
        flicker.state = 'autoscroll';
    }

    function hide() {
        root.visible = false;
        clear()
    }

    function reRequest(){
        subscribeDataProvider.cancel();
        subscribeDataProvider.query();
    }
}
