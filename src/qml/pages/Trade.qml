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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import Dzh.AppLauncher 1.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0

import '../controls'
import '../components'
import '../core'
import '../core/common'

Window {
    id: root
    width: 500
    height: 304
    flags:Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    modality: Qt.WindowModal
    title: '快捷委托设置'
    property var theme: ThemeManager.currentTheme
    property var tradeList: JSON.parse(tradeControl.tradeSetting.tradeList)

    RectangleWithBorder{
        focus: true
        anchors.fill: parent
        leftBorder: 1
        rightBorder: 1
        topBorder: 1
        bottomBorder: 1
        border.color: theme.toolbarColor

        //标题区域
        TitleBar{
            id: title
            title: root.title
            width: parent.width
            height: theme.toolbarHeight
            anchors.top: parent.top
            anchors.left: parent.left
            mainWindow: root
            windowButton.showMaxButton: false
            windowButton.showMinButton: false
            windowButton.width: theme.toolbarControlButtonWidth
            textLeftMargin: height + 2

            Rectangle{
                id: icon
                width: parent.height
                height: parent.height
                color: "transparent"
                Image{
                    anchors.centerIn: parent
                    source: theme.entrustIconPath
                    width: 20
                    height: 18
                }
            }
        }

        //内容展示区
        Rectangle{
            id: content
            anchors.top: title.bottom
            anchors.left: parent.left
            anchors.right: control.left
            anchors.bottom: parent.bottom

            Text{
                id: empertyHint
                textFormat: TextEdit.RichText
                anchors.centerIn: parent
                text:"请通过<a href=\"http://www.gw.com.cn\">新增委托</a>将券商官方交易软件(可在券商官网下载)设置为快捷委托，设置后可通过“交易”及快捷键(F12)直接打开默认委托程序。"
                width: 320
                wrapMode: Text.Wrap

                onLinkActivated: {
                    addNewTrade();
                }
            }

            RectangleWithBorder{
                visible: false
                id: tradeListContent
                leftBorder: 1
                rightBorder: 1
                topBorder: 1
                bottomBorder: 1
                border.color: theme.borderColor
                anchors.fill: parent
                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 10

                ListView{
                    id: listView
                    anchors.fill: parent
                    currentIndex: 0
                    focus: true
                    clip: true
                    keyNavigationWraps: true
                    boundsBehavior: Flickable.StopAtBounds
                    snapMode: ListView.SnapToItem

                    model: listModel
                    delegate: component

                    onCurrentIndexChanged: {
                        setDefault.text = (listModel.get(listView.currentIndex) && listModel.get(listView.currentIndex).IsDefault) ? '已为默认' : '设为默认';
                        setDefault.checked = (listModel.get(listView.currentIndex) && listModel.get(listView.currentIndex).IsDefault) ? true : false;
                    }
                }

                VScrollBar {
                    id: scrollbar
                    flicker: listView
                }
            }
        }

        //右侧控制区
        ColumnLayout{
            id: control
            spacing: theme.tradeSpace
            anchors.topMargin:  theme.tradeSpace
            anchors.top: title.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: theme.tradeSpace
            width: theme.tradeSpace * 2 + theme.tradeButtonWidth

            Button{
                id: openCustiomTrade
                text:'打开委托'
                enabled: listModel.count > 0
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: theme.tradeButtonWidth
                Layout.preferredHeight: theme.tradeButtonHeight
                backgroundRadius: theme.tradeButtonRadius
                hoveredRadius: theme.tradeButtonRadius
                checkedRadius: theme.tradeButtonRadius
                borderWidth: 1

                textColor: theme.tradeButtonTextColor
                backgroundColor: theme.tradeButtonColor
                hoveredColor: theme.tradeButtonHoverColor
                checkedColor: theme.tradeButtonCheckedColor

                borderColor: theme.tradeButtonBorderColor
                borderCheckedColor: theme.tradeButtonCheckedColor
                borderHoverColor: theme.tradeButtonHoverBorderColor
                onClickTriggered: {
                    if (listModel.count > 0){
                        var index = listView.currentIndex;
                        var obj = listModel.get(index);

                        if (obj){
                            tradeControl.runTradeApp(obj.TradeName, obj.TradePath);
                        }
                    }
                }
            }

            Button{
                id: cancel
                text:'取消'

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: theme.tradeButtonWidth
                Layout.preferredHeight: theme.tradeButtonHeight
                backgroundRadius: theme.tradeButtonRadius
                hoveredRadius: theme.tradeButtonRadius
                checkedRadius: theme.tradeButtonRadius
                borderWidth: 1

                textColor: theme.tradeButtonTextColor
                backgroundColor: theme.tradeButtonColor
                hoveredColor: theme.tradeButtonHoverColor
                checkedColor: theme.tradeButtonCheckedColor

                borderColor: theme.tradeButtonBorderColor
                borderCheckedColor: theme.tradeButtonCheckedColor
                borderHoverColor: theme.tradeButtonHoverBorderColor

                onClickTriggered: {
                    root.close();
                }
            }

            SeparatorLine{
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: 84
                Layout.preferredHeight: 1
                orientation: Qt.Horizontal
                length: 84
            }

            Button{
                id: setDefault
                //text: '设为默认'
                text:  (listModel.get(listView.currentIndex) && listModel.get(listView.currentIndex).IsDefault) ? '已为默认' : '设为默认'
                enabled: listModel.count > 0
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: theme.tradeButtonWidth
                Layout.preferredHeight: theme.tradeButtonHeight
                backgroundRadius: theme.tradeButtonRadius
                hoveredRadius: theme.tradeButtonRadius
                checkedRadius: theme.tradeButtonRadius
                borderWidth: 1
                checkable: true
                isAlwaysChecked: true;
                checked: (listModel.get(listView.currentIndex) && listModel.get(listView.currentIndex).IsDefault) ? true : false
                textColor: theme.tradeButtonTextColor
                backgroundColor: theme.tradeButtonColor
                hoveredColor: theme.tradeButtonHoverColor
                checkedColor: theme.tradeButtonCheckedColor

                borderColor: theme.tradeButtonBorderColor
                borderCheckedColor: theme.tradeButtonCheckedColor
                borderHoverColor: theme.tradeButtonHoverBorderColor

                onClickTriggered: {
                    //设置默认委托
                    var name = listModel.get(listView.currentIndex).TradeName;
                    if (tradeControl.tradeSetting.defaultTradeName !== name){
                        tradeControl.tradeSetting.defaultTradeName = name;
                        refreshTradeList();
                    }
                }
            }

            Button{
                id: deleteTrade
                text:'删除'
                enabled: listModel.count > 0

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: theme.tradeButtonWidth
                Layout.preferredHeight: theme.tradeButtonHeight
                backgroundRadius: theme.tradeButtonRadius
                hoveredRadius: theme.tradeButtonRadius
                checkedRadius: theme.tradeButtonRadius
                borderWidth: 1

                textColor: theme.tradeButtonTextColor
                backgroundColor: theme.tradeButtonColor
                hoveredColor: theme.tradeButtonHoverColor
                checkedColor: theme.tradeButtonCheckedColor

                borderColor: theme.tradeButtonBorderColor
                borderCheckedColor: theme.tradeButtonCheckedColor
                borderHoverColor: theme.tradeButtonHoverBorderColor

                onClickTriggered: {
                    var name = listModel.get(listView.currentIndex).TradeName;

                    var result =  tradeList.filter(function(eachTrade){
                        return eachTrade.name !== name;
                    });

                    //修改默认委托
                    if (tradeControl.tradeSetting.defaultTradeName === name){
                        tradeControl.tradeSetting.defaultTradeName = '';
                    }

                    //更新列表信息
                    tradeControl.tradeSetting.tradeList = JSON.stringify(result);

                    refreshTradeList('del', listView.currentIndex);
                }
            }

            Button{
                id: addTrade
                text:'新增委托'

                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: theme.tradeButtonWidth
                Layout.preferredHeight: theme.tradeButtonHeight
                backgroundRadius: theme.tradeButtonRadius
                hoveredRadius: theme.tradeButtonRadius
                checkedRadius: theme.tradeButtonRadius
                borderWidth: 1

                textColor: theme.tradeButtonTextColor
                backgroundColor: theme.tradeButtonColor
                hoveredColor: theme.tradeButtonHoverColor
                checkedColor: theme.tradeButtonCheckedColor

                borderColor: theme.tradeButtonBorderColor
                borderCheckedColor: theme.tradeButtonCheckedColor
                borderHoverColor: theme.tradeButtonHoverBorderColor

                onClickTriggered: {
                    addNewTrade()
                }
            }

            Rectangle{
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: theme.tradeButtonWidth
                Layout.fillHeight: true

                Text{
                    text: '客服电话:'
                    font.pointSize: 6
                    width: parent.width
                    anchors.top: parent.top
                }
                Text{
                    text: '021-20219997'
                    font.pointSize: 6
                    font.family: '宋体'
                    width: parent.width
                    anchors.bottom: parent.bottom
                }
            }
        }

        Keys.onPressed: {
            if(event.key === Qt.Key_Escape) {
                event.accepted= true;
                root.close();
            }
        }
    }

    Component{
        id: component
        Rectangle{
            id: item
            property bool isHovered: false
            height: theme.tradeItemHeight
            width: parent.width
            color: ListView.isCurrentItem ? theme.tradeItemColor : (isHovered ?  theme.tradeItemHoverColor : 'transparent')
            Text{
                id: tradeName
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.right: tradeIsDefault.left
                anchors.rightMargin: 4
                height: parent.height

                verticalAlignment: Text.AlignVCenter
                text: TradeName
                elide: Text.ElideRight
            }
            Text{
                id: tradeIsDefault
                anchors.right: parent.right
                height: parent.height
                width: theme.tradeItemDefaultWidth
                text: IsDefault ? 'F12（默认）' : ' '
                visible: IsDefault
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    item.ListView.view.currentIndex = index
                }

                onEntered: {
                    isHovered = true;
                }

                onExited: {
                    isHovered = false
                }
            }
        }
    }

    ListModel{
        id: listModel
    }

    TradeControl{
        id: tradeControl
    }

    function refreshTradeList(type, index){
        var count = tradeList.length;
        var defaultIndex = 0;

        if (count > 0){
            listModel.clear();
            listView.currentIndex = -1;

            tradeListContent.visible = true
            listView.focus = true;

            for (var i = 0; i < count; i++){
                var isDefault = false;

                if (tradeControl.tradeSetting.defaultTradeName === tradeList[i].name){
                    isDefault = true;
                    defaultIndex = i;
                }else{
                    isDefault = false;
                }

                listModel.set(i, {
                                  TradeName: tradeList[i].name,
                                  TradePath: tradeList[i].path,
                                  IsDefault: isDefault
                              })
            }

            //当没有默认的时候，设置第一个为默认
            if (tradeControl.tradeSetting.defaultTradeName === ''){
                var obj = listModel.get(0);
                tradeControl.tradeSetting.defaultTradeName = obj.TradeName;
                listModel.setProperty(0, 'IsDefault', true);
            }

            if (type === 'add'){
                listView.currentIndex = count - 1;
            }else if(type === 'del'){

                if (index === 0){
                    listView.currentIndex = 0;
                }else{
                    listView.currentIndex = index - 1;
                }
            }else{
                listView.currentIndex = defaultIndex;
            }
        }else{
            tradeListContent.visible = false
            listView.currentIndex = -1
        }
    }

    function addNewTrade(){
        addTradeDialog.clear();
        addTradeDialog.show();
    }

    //设置对话框
    Dialog {
        id: addTradeDialog
        showButton: false
        confirmType: 2
        miniTitlebar: true
        width: 400
        height: 210
        contentMargin: 10
        title: '新增委托'

        customItem: Item{
            anchors.fill: parent
            Item{
                id: hint
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 50

                Text{
                    width: parent.width
                    text: '将本地程序(或快捷方式)设为快捷委托，即可通过“交易”及快捷键(F12)直接打开默认委托程序。'
                    wrapMode: Text.WordWrap
                }
            }

            Row{
                id: layoutTop
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: hint.bottom
                height: 30
                spacing:6

                Text{
                    id: tradePathText
                    text: '指定路径：'
                    height: parent.height
                    width: 70
                }

                Rectangle{

                    clip: true
                    height: parent.height
                    width: 250
                    border.color: theme.keyboardSpriteBoderColor
                    border.width: 1
                    color: theme.keyboardSpriteInputBackgroundColor
                    Text{
                        id: tradePathInput
                        elide: Text.ElideMiddle
                        height: parent.height
                        width: parent.width
                        text: '';
                    }
                }

                Button{
                    id: add
                    width: 40
                    height: parent.height
                    text: '浏览'
                    backgroundRadius: theme.tradeButtonRadius
                    hoveredRadius: theme.tradeButtonRadius
                    checkedRadius: theme.tradeButtonRadius
                    borderWidth: 1

                    textColor: theme.tradeButtonTextColor
                    backgroundColor: theme.tradeButtonColor
                    hoveredColor: theme.tradeButtonHoverColor
                    checkedColor: theme.tradeButtonCheckedColor

                    borderColor: theme.tradeButtonBorderColor
                    borderCheckedColor: theme.tradeButtonCheckedColor
                    borderHoverColor: theme.tradeButtonHoverBorderColor

                    onClickTriggered: {
                        errorHint.visible = false;
                        fileDialog.open();
                    }

                    KeyNavigation.tab: tradeNameInput
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                            add.clickTriggered();
                        }
                    }
                }
            }

            Row{
                id: layoutBottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: layoutTop.bottom
                anchors.topMargin: 4
                height: 30
                spacing:6

                Text{
                    id: tradeNameText
                    text: '委托名称：'
                    width: 70
                    height: parent.height
                }

                EditLabel{
                    id: tradeNameInput
                    clip: true
                    width: 180
                    height: parent.height
                    border.color: theme.keyboardSpriteBoderColor
                    border.width: 1
                    color: theme.keyboardSpriteInputBackgroundColor
                    textHint: ""
                    maximumLength: 80

                    onInputTextChanged:{
                        errorHint.visible = false;
                    }

                    KeyNavigation.tab: confirmBtn
                }
            }


            Item{
                anchors.bottom: controlButtons.top
                height: 30
                width: parent.width

                Text{
                    id: errorHint
                    visible: false
                    anchors.centerIn: parent
                    height: 28
                    text: ''
                    color: "red"
                }
            }

            Item{
                id: controlButtons
                anchors.bottom: parent.bottom
                width: parent.width
                height: 30
                Button {
                    id: cancelBtn
                    text: '取消'
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width / 2 + 10
                    width: 60
                    height: 30
                    backgroundRadius: theme.tradeButtonRadius
                    hoveredRadius: theme.tradeButtonRadius
                    checkedRadius: theme.tradeButtonRadius
                    borderWidth: 1

                    textColor: theme.tradeButtonTextColor
                    backgroundColor: theme.tradeButtonColor
                    hoveredColor: theme.tradeButtonHoverColor
                    checkedColor: theme.tradeButtonCheckedColor

                    borderColor: theme.tradeButtonBorderColor
                    borderCheckedColor: theme.tradeButtonCheckedColor
                    borderHoverColor: theme.tradeButtonHoverBorderColor

                    onClickTriggered: {
                        addTradeDialog.close();
                    }

                    KeyNavigation.tab: add
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                            cancelBtn.clickTriggered();
                        }
                    }
                }

                Button {
                    id: confirmBtn
                    text: '确定'
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 2 + 10
                    width: 60
                    height: 30

                    focus: true
                    backgroundRadius: theme.tradeButtonRadius
                    hoveredRadius: theme.tradeButtonRadius
                    checkedRadius: theme.tradeButtonRadius
                    borderWidth: 1

                    textColor: theme.tradeButtonTextColor
                    backgroundColor: theme.tradeButtonColor
                    hoveredColor: theme.tradeButtonHoverColor
                    checkedColor: theme.tradeButtonCheckedColor

                    borderColor: theme.tradeButtonBorderColor
                    borderCheckedColor: theme.tradeButtonCheckedColor
                    borderHoverColor: theme.tradeButtonHoverBorderColor

                    KeyNavigation.tab: cancelBtn
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                            confirmBtn.clickTriggered();
                        }
                    }
                    onClickTriggered: {

                        var error = checkInput();
                        if (error.length > 0){

                            errorHint.text = error;
                            errorHint.visible = true;
                        }else{
                            //更新 关闭
                            errorHint.visible = false;
                            var tradeName = trimStr(tradeNameInput.text);
                            var tradePath = trimStr(tradePathInput.text);
                            var newList = tradeList;
                            newList.push({"name": tradeName, "path":tradePath});
                            tradeControl.tradeSetting.tradeList = JSON.stringify(newList);
                            refreshTradeList('add');
                            addTradeDialog.close();
                        }
                    }
                }
            }
        }

        function clear(){
            errorHint.visible = false;
            tradePathInput.text = '';
            tradeNameInput.text = '';

            add.forceActiveFocus();
        }
    }

    function trimStr(str) {
        return str.replace(/(^\s*)|(\s*$)/g, "")
    }

    function checkInput(){
        var error = ''
        var tradeName = trimStr(tradeNameInput.text);
        var tradePath = trimStr(tradePathInput.text);

        if (tradeName.length === 0){
            error = '请输入委托名称！';
            return error;
        }

        var result =  tradeList.filter(function(eachTrade){
            return eachTrade.name === tradeName;
        });

        if (result.length > 0){
            error = '当前委托名称已存在，请重新指定！';
            return error;
        }

        if (tradePath.length === 0){
            error = '请设置正确的委托程序！'
            return error;
        }

        return error;

    }

    FileDialog{
        id:fileDialog
        title:'请选择本地已经安装的委托软件'
        nameFilters: ["可执行文件(*.exe)"]
        folder: '..'
        onAccepted:{
            tradePathInput.text = tradeControl.getRealPath(fileDialog.fileUrl);
        }
        onRejected: {

        }
        selectExisting: true
        selectFolder: false
        selectMultiple: false
    }

    Component.onCompleted: {
        root.requestActivate()
    }
}
