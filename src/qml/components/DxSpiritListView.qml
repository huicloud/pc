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
import QtQuick.Controls.Styles 1.4
import Dzh.FileSetting 1.0
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
    property var theme: ThemeManager.currentTheme

    //当前按钮索引，0：全部；1：自选；2：个股；3：设置
    property int topButtonIndex: 0

    //通知类型映射表
    property var tongZhiArray: [
       {type:"HJFS",name:"火箭发射",checked:true,defaultState:true},
       {type:"KSFT",name:"快速反弹",checked:true,defaultState:true},
       {type:"GTTS",name:"高台跳水",checked:true,defaultState:true},
       {type:"JSXD",name:"加速下跌",checked:true,defaultState:true},
       {type:"DBMR",name:"大笔买入",checked:true,defaultState:true},
       {type:"DBMC",name:"大笔卖出",checked:true,defaultState:true},
       {type:"FZTB",name:"封涨停板",checked:true,defaultState:true},
       {type:"FDTB",name:"封跌停板",checked:true,defaultState:true},
       {type:"DKZT",name:"打开涨停",checked:true,defaultState:true},
       {type:"DKDT",name:"打开跌停",checked:true,defaultState:true},
       {type:"YDMCP",name:"有大卖盘",checked:false,defaultState:false},
       {type:"YDMRP",name:"有大买盘",checked:false,defaultState:false},
       {type:"LSZS",name:"拉升指数",checked:false,defaultState:false},
       {type:"DYZS",name:"打压指数",checked:false,defaultState:false},
       {type:"JGMRGD",name:"机构买单",checked:false,defaultState:false},
       {type:"JGMCGD",name:"机构卖单",checked:false,defaultState:false},
       //{type:"DCJMRD",name:"大笔买入",checked:false,defaultState:false},
       //{type:"DCJMCD",name:"大笔卖出",checked:false,defaultState:false},
       {type:"FDMRGD",name:"分单买单",checked:false,defaultState:false},
       {type:"FDMCGD",name:"分单卖单",checked:false,defaultState:false},
       {type:"MRCD",name:"买入撤单",checked:false,defaultState:false},
       {type:"MCCD",name:"卖出撤单",checked:false,defaultState:false},
       {type:"MRXD",name:"买入新单",checked:false,defaultState:false},
       {type:"MCXD",name:"卖出新单",checked:false,defaultState:false}
    ]


    //短线精灵需要请求的通知类型参数
    property string requestTongZhiList: ''
    //自选股数据对象，过滤自选股短线精灵使用
    property var ziXuanObject:({})
    //当前查看的股票代码，过滤当前股票短线精灵使用
    property string currentObjRight:''

    //设置对话框列表项设置
    property int rowSpacePer: 10
    property int minHeightPer: 10
    property int showCount: Math.floor((leftList.height - rowSpacePer) / (minHeightPer+rowSpacePer));
    property int showStartIndex: Math.max(0, Math.ceil(flicker.visibleArea.yPosition * tongZhiArray.length))


    //可配置设置
    //二级菜单
    property color buttonBarBackgroundColor:theme.dxspiritButtonBarBackgroundColor
    property color buttonBarBorderColor:theme.dxspiritButtonBarBorderColor
    property color buttonBarTextColor:theme.dxspiritButtonBarTextColor
    property color buttonBarCheckedTextColor:theme.dxspiritButtonBarCheckedTextColor

    //设置对话框
    property color dialogListBackgroundColor:theme.dxspiritDialogListBackgroundColor
    property color dialogListCheckBoxCheckedColor:theme.dxspiritDialogListCheckBoxCheckedColor
    property color dialogListScrollBarColor:theme.dxspiritDialogListScrollBarColor
    property color dialogListSliderColor:theme.dxspiritDialogListSliderColor

    property color dialogButtonColor:theme.dxspiritDialogButtonColor
    property color dialogButtonTextColor:theme.dxspiritDialogButtonTextColor

    property color dialogButtonHoveredColor:"#ffffff"
    property color dialogButtonHoveredTextColor:"#294683"


    //按钮控件，全部，自选，个股和设置按钮
    Rectangle{
        id:topButtonBar
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: 22
        color:buttonBarBackgroundColor
        border.width: 0
        border.color: buttonBarBorderColor

        Row{
            id:btnRow
            width: parent.width
            height: parent.height

            PanelButton {
                id: allBtn
                height: parent.height
                panelButtonBorderWidth: 0
                panelButtonTopMargin: 0
                panelButtonBottomMargin: 0
                panelButtonTextColor:buttonBarTextColor
                panelButtonCheckedTextColor: buttonBarCheckedTextColor
                panelButtonBorderRadius: 0
                text: "全部"
                checked: root.topButtonIndex === 0
                onClickTriggered: {
                    root.topButtonIndex = 0;
                    dxSpiritListView.reRequest();
                }
            }

            SeparatorLine {
                orientation: Qt.Vertical
                length: parent.height
            }

            //由于当前云平台接口为实现按obj请求数据，到1.3版本实现该功能
            /*
            PanelButton {
                id: myBtn
                //width: 43
                height: parent.height
                //anchors.left: allBtn.right
                panelButtonBorderWidth: 0
                panelButtonTopMargin: 0
                panelButtonBottomMargin: 0
                panelButtonTextColor:buttonBarTextColor
                panelButtonCheckedTextColor: buttonBarCheckedTextColor

                text: "自选"
                checked: root.topButtonIndex === 1
                onClickTriggered: {

                    PortfolioUtil.getList().forEach(function(each){
                        ziXuanObject[each.obj]=1;
                    });
                    //console.info("Zixuan:",JSON.stringify(ziXuanObject))
                    root.topButtonIndex = 1;
                    dxSpiritListView.reRequest();

                }
            }
            PanelButton {
                id: oneBtn
                //width: 43
                height: parent.height
                //anchors.left: myBtn.right
                panelButtonBorderWidth: 0
                panelButtonTopMargin: 0
                panelButtonBottomMargin: 0
                panelButtonTextColor:buttonBarTextColor
                panelButtonCheckedTextColor: buttonBarCheckedTextColor

                text: "个股"
                checked: root.topButtonIndex === 2
                onClickTriggered: {
                    root.topButtonIndex = 2;
                    dxSpiritListView.reRequest();
                }
            }
            */
        }

        //设置按钮
        Rectangle{
            height: parent.height
            width: 32
            anchors.right: parent.right
            //color: root.topButtonIndex === 3 ? theme.panelButtonCheckedColor : "transparent"
            color: "transparent"

            ImageButton {
                id: setBtn
                anchors.fill: parent
                imageRes: theme.iconDxSpiritSet
                imageSize: Qt.size(14, 14)

                onClickTriggered: {
                    //root.topButtonIndex = 3;
                    if(!setWindow.visible){
                        //读取配置文件
                        var strConfig = configFile.read();
                        if(strConfig.length > 0){
                            var objConfig = JSON.parse(strConfig);
                            if(objConfig.length === tongZhiArray.length){
                                tongZhiArray = objConfig;
                            }
                            //console.info("Read:",strConfig,objConfig.length);
                        }

                        setWindow.setX(200);
                        setWindow.setY(theme.toolbarHeight + 30);
                        setWindow.show();
                    }
                }
            }
        }
        SeparatorLine {
            anchors.bottom: parent.bottom
            orientation: Qt.Horizontal
            length: parent.width
        }
    }

    //短线精灵列表控件
    DxSpiritComponent{
        id:dxSpiritListView
        anchors.left: parent.left
        anchors.top:topButtonBar.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: false
        tongZhiList: requestTongZhiList
        ziXuanMap:ziXuanObject
        currentObj:currentObjRight
        isFilterZiXuan: root.topButtonIndex === 1
        isFilterCurrentObj:root.topButtonIndex === 2
    }

    //设置对话框
    Dialog {
        id: setWindow
        modality: Qt.NonModal
        showButton: false
        confirmType: 2
        miniTitlebar: true
        x:200
        y:theme.toolbarHeight + 30
        width: 262
        height: 292
        title: '短线精灵预警设置'
        property int clickedIndexButton: 0

        customItem: Rectangle{
            anchors.fill: parent
            Layout.margins: 10
            clip: true

            Rectangle{
                id: leftList
                anchors.left: parent.left
                width: 150
                height: parent.height
                color: dialogListBackgroundColor
                border.width: 1

                Flickable {
                    id: flicker
                    anchors.fill: parent
                    // 计算总数据高度
                    contentHeight: ((minHeightPer + rowSpacePer)* (tongZhiArray.length+1) + rowSpacePer)
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                }

                ColumnLayout{
                    anchors.fill: flicker
                    Layout.margins: 0
                    spacing: 0
                    Repeater {
                        Layout.margins: 0
                        model:tongZhiArray.slice(showStartIndex,showStartIndex+showCount)
                        RowLayout{
                            height: minHeightPer
                            Layout.topMargin: index === 0 ? rowSpacePer:0
                            Layout.bottomMargin: rowSpacePer
                            Layout.leftMargin: rowSpacePer

                            CheckBox {
                                  id:rowCheckBox
                                  anchors.fill: parent
                                  text: ""
                                  checked:modelData.checked
                                  signal textClicked

                                  style: CheckBoxStyle {
                                      indicator: Rectangle {
                                              implicitWidth: 12
                                              implicitHeight: 12
                                              //border.color: control.activeFocus ? "darkblue" : "gray"
                                              border.width: 1
                                              color: control.checked ? dialogListCheckBoxCheckedColor : "#ffffff"

                                              Text {
                                                  visible: control.checked
                                                  text:"√"
                                                  anchors.fill: parent
                                                  color: "#ffffff"
                                              }
                                      }
                                  }

                                  onClicked: {
                                      tongZhiArray[showStartIndex+index].checked = checked;

                                      setWindow.clickedIndexButton = 0;
                                  }
                                  onTextClicked: {
                                      checked = !checked;
                                      tongZhiArray[showStartIndex+index].checked = checked;
                                      setWindow.clickedIndexButton = 0;
                                  }
                            }

                            Rectangle{
                                height: minHeightPer
                                width: 80
                                color: "transparent"

                                Text{
                                     anchors.fill: parent
                                     text:modelData.name
                                     //font.pointSize:18
                                     font.pixelSize: 14
                                     color: "#222222"
                                }
                                MouseArea{
                                    anchors.fill: parent
                                    onClicked: {
                                        rowCheckBox.textClicked();
                                    }
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
                    anchors.right: parent.right
                    flicker: flicker
                    sliderColor:dialogListSliderColor
                    color:dialogListScrollBarColor
                }
            }

            Rectangle{
                id: rightOption
                anchors.right: parent.right
                anchors.left: leftList.right
                height: parent.height

                Column{
                    anchors.margins: 10
                    anchors.fill: parent
                    spacing: 10

                    PanelButton {
                        id:"allSelect"
                        text: "全部选择"
                        width: parent.width
                        height: 22
                        panelButtonColor:dialogButtonColor
                        panelButtonTextColor: dialogButtonTextColor
                        panelButtonHoveredColor:dialogButtonHoveredColor
                        panelButtonHoveredTextColor:dialogButtonHoveredTextColor
                        panelButtonTopMargin: 0
                        panelButtonBottomMargin: 0
                        panelButtonLeftPadding:12
                        panelButtonRightPadding:12
                        checked: setWindow.clickedIndexButton === 1

                        onClickTriggered: {
                            setWindow.clickedIndexButton = 1;
                            var temp = tongZhiArray;
                            temp.forEach(function(value){
                                value.checked = true;
                            });
                            tongZhiArray = temp;
                        }
                    }

                    PanelButton {
                        id:"allNoSelect"
                        text: "全部取消"
                        width: parent.width
                        height: 22
                        panelButtonColor:dialogButtonColor
                        panelButtonTextColor: dialogButtonTextColor
                        panelButtonHoveredColor:dialogButtonHoveredColor
                        panelButtonHoveredTextColor:dialogButtonHoveredTextColor
                        panelButtonTopMargin: 0
                        panelButtonBottomMargin: 0
                        panelButtonLeftPadding:12
                        panelButtonRightPadding:12
                        checked: setWindow.clickedIndexButton === 2
                        onClickTriggered: {
                            setWindow.clickedIndexButton = 2;
                            var temp = tongZhiArray;
                            temp.forEach(function(value){
                                value.checked = false;
                            });
                            tongZhiArray = temp;
                        }
                    }

                    PanelButton {
                        id:"defaultSelect"
                        text: "恢复默认"
                        width: parent.width
                        height: 22
                        panelButtonColor:dialogButtonColor
                        panelButtonTextColor: dialogButtonTextColor
                        panelButtonHoveredColor:dialogButtonHoveredColor
                        panelButtonHoveredTextColor:dialogButtonHoveredTextColor
                        panelButtonTopMargin: 0
                        panelButtonBottomMargin: 0
                        panelButtonLeftPadding:12
                        panelButtonRightPadding:12
                        checked: setWindow.clickedIndexButton === 3

                        onClickTriggered: {
                            setWindow.clickedIndexButton = 3
                            var temp = tongZhiArray;
                            temp.forEach(function(value){
                                value.checked = value.defaultState;
                            });
                            tongZhiArray = temp;
                        }
                    }

                    PanelButton {
                        id:"okBtn"
                        text: "确认"
                        width: parent.width
                        height: 22
                        panelButtonColor:dialogButtonColor
                        panelButtonTextColor: dialogButtonTextColor
                        panelButtonHoveredColor:dialogButtonHoveredColor
                        panelButtonHoveredTextColor:dialogButtonHoveredTextColor
                        panelButtonTopMargin: 0
                        panelButtonBottomMargin: 0
                        panelButtonLeftPadding:26
                        panelButtonRightPadding:26
                        checked: setWindow.clickedIndexButton === 4

                        onClickTriggered: {
                            //保存设置
                            var jsonText = JSON.stringify(tongZhiArray);
                            configFile.write(jsonText);
                            var oldLen = requestTongZhiList.length;
                            requestTongZhiList = tongZhiArray.filter(function(eachElement){return eachElement.checked;})
                            .map(function(eachElement){return eachElement.type;})
                            .join(",");

                            if(oldLen === 0 && requestTongZhiList.length > 0){
                                if(visible){
                                    dxSpiritListView.show();
                                }
                            }

                            setWindow.clickedIndexButton = 4
                            setWindow.hide();
                        }
                    }

                    PanelButton {
                        id:"cancelBtn"
                        text: "取消"
                        width: parent.width
                        height: 22
                        panelButtonColor:dialogButtonColor
                        panelButtonTextColor: dialogButtonTextColor
                        panelButtonHoveredColor:dialogButtonHoveredColor
                        panelButtonHoveredTextColor:dialogButtonHoveredTextColor
                        panelButtonTopMargin: 0
                        panelButtonBottomMargin: 0
                        panelButtonLeftPadding:26
                        panelButtonRightPadding:26

                        checked: setWindow.clickedIndexButton === 5

                        onClickTriggered: {
                            //读取配置文件
                            var strConfig = configFile.read();
                            if(strConfig.length > 0){
                                var objConfig = JSON.parse(strConfig);
                                if(objConfig.length === tongZhiArray.length){
                                    tongZhiArray = [];
                                    tongZhiArray = objConfig;
                                }
                            }
                            setWindow.clickedIndexButton = 5;
                            setWindow.hide();
                        }
                    }
                }
            }
        }

        onVisibleChanged: {
            if(!visible){
                clickedIndexButton = 0;
            }
        }
    }

    //本地落盘配置文件
    FileSetting{
         id:configFile
         source: "./config/dxspirit.txt"
         onError:{
             console.info("DxSpiritListView onError"+msg);
         }
    }

    onVisibleChanged: {
        //请求或断开数据
        if(requestTongZhiList.length > 0){
            if(visible){
                dxSpiritListView.show();
            }else{
                dxSpiritListView.hide();
            }
        }

        //记录用户行为
        if (root.visible){
            UBAUtil.sendUserBehavior(UBAUtil.duanXianJingLingTag)
        }
    }

    Component.onCompleted: {
        //读取本地配置,失败时，使用默认配置
        var strConfig = configFile.read();
        if(strConfig.length > 0){
            var objConfig = JSON.parse(strConfig);
            if(objConfig.length === tongZhiArray.length){
                tongZhiArray = objConfig;
            }
        }
        requestTongZhiList = tongZhiArray.filter(function(eachElement){return eachElement.checked;})
        .map(function(eachElement){return eachElement.type;})
        .join(",");

        //初始时，请求或断开数据
        if(visible){
            dxSpiritListView.show();
        }
    }
}
