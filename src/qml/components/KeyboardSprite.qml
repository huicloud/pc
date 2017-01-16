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

/**
  * @brief  键盘宝
  * @author dongwei
  * @date   2016
  */
import QtQuick 2.6

import "../core"
import "../core/data"
import "../controls"
import "../util"

ContextComponent {
    id: root
    width: theme.keyboardSpriteWidth
    height: theme.keyboardSpriteHeight
    z: 100

    property bool showMask: false    //是否显示蒙版
    property bool isAnimation: false //是否显示动画
    property int duration: 500       //动画时间
    property int easingInType: Easing.InOutExpo //显示动画效果
    property int easingOutType: Easing.InExpo   //隐藏动画效果
    property alias radius: content.radius
    property ContextComponent appContent: null
    property string searchedText: ""

    //私有属性
    property double __innerOpacity

    property int __preModelCount: 0             //上一次显示的总数
    property int __currentModelCount: 0         //当前显示的总数
    //透明度记录，防止被动画修改
    MouseArea {
        anchors.fill: parent
        onPressed: {
            parent.focus = true
        }
    }
    //遮罩层
    MaskLayer {
        id: mask
        visible: false

        MouseArea {
            anchors.fill: parent
            onPressed: {
                root.hide()
                mouse.accepted = false

                /* var pointObj = mapToItem(root, mouse.x, mouse.y)
                 if ((pointObj.x < 0) || (pointObj.x > root.width)
                         || (pointObj.y < 0) || (pointObj.y > root.width)) {
                     console.log("在键盘包区域之外点击")
                 }*/
            }
        }
    }

    //键盘宝数据请求
    DataProvider {
        id: kbspriteQuery
        serviceUrl: "/kbspirit"
        sub: 0
        cacheLevel: 0
        autoQuery: false
    }

    Rectangle {
        id: content
        anchors.fill: parent
        border.color: theme.keyboardSpriteBoderColor
        border.width: 2
        color: theme.backgroundColor
        clip: true

        EditLabel {
            id: keyInput
            x: 3
            y: 3
            height: theme.keyboardSpriteInputHeight
            width: parent.width - 6
            border.color: theme.keyboardSpriteBoderColor
            border.width: 1
            color: theme.keyboardSpriteInputBackgroundColor
            textHint: "代码/名称/简拼"
            maximumLength: 30

            textFont.capitalization: Font.AllUppercase
        }
        ListView {
            id: listView
            anchors.top: keyInput.bottom
            anchors.topMargin: 3
            anchors.left: keyInput.left
            anchors.right: keyInput.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3

            currentIndex: 0
            focus: true
            clip: true
            keyNavigationWraps: true
            boundsBehavior: Flickable.StopAtBounds
            snapMode: ListView.SnapToItem

            model: listModel
            delegate: component
        }
        VScrollBar {
            id: scrollbar
            flicker: listView
        }
    }

    Component {
        id: component
        Rectangle {
            id: item
            height: codeText.visible ? 26 : 1
            width: parent.width
            color: ListView.isCurrentItem ? theme.keyboardSpriteHighlightColor : "transparent"

            Text {
                id: codeText
                height: parent.height
                width: 70
                anchors.left: parent.left
                anchors.leftMargin: 4
                text: DaiMa
                color: Type === 0 ? theme.keyboardSpriteCodeColor : theme.textColor
                visible: Type !== 99
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                id: nameText
                height: parent.height
                width: 150
                anchors.leftMargin: 6
                text: MingCheng
                visible: codeText.visible
                anchors.left: codeText.right
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                id: infoText
                height: parent.height
                text: ShuXing
                visible: codeText.visible
                anchors.left: nameText.right
                anchors.rightMargin: 12
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
            }

            SeparatorLine {
                orientation: Qt.Horizontal
                length: parent.width
                height: 1
                color: theme.keyboardSpriteSeparatorLineColor
                visible: !codeText.visible
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (codeText.visible)
                        item.ListView.view.currentIndex = index
                }

                onDoubleClicked: {
                      __kbspriteGoto(index, codeText);
                }
            }
        }
    }
    ListModel {
        id: listModel
    }

    Timer{
        id: queryTimer
        property string inputText
        interval: inputText.length >= 6 ? 1 : 50
        onTriggered: {
            kbspriteQuery.params = ({
                                        input: inputText,
                                        type: appConfig.localKBSprite.type,
                                        count: appConfig.localKBSprite.queryCount,
                                        market: appConfig.localKBSprite.markert
                                    })

            //执行查询
            kbspriteQuery.cancel()
            kbspriteQuery.query()
        }
    }

    Connections {
        target: keyInput
        onInputTextChanged: {
            var trimText = trimStr(text)

            //文本真正变化的时候 触发查询和加载
            if (trimText ===  ''){
                root.searchedText = ''
                __preModelCount = 0
                __currentModelCount = 0
                listModel.clear()
                return;
            }

            if (root.searchedText !== trimText) {
                root.searchedText = trimText

                /**
                kbspriteQuery.params = ({
                                            input: trimText,
                                            type: 6,
                                            count: 50,
                                            market: "SZ,SH,B$"
                                        })

                //执行查询
                kbspriteQuery.cancel()
                kbspriteQuery.query()
                */

                //定时器出发请求
                queryTimer.inputText = trimText
                queryTimer.restart()

                //本地列表加载
                __preModelCount = listModel.count
                __currentModelCount = 0

                //不同页面加载不同的本地命令 todo 优化
                var pageType = 0
                var pagePath = root.context.pageNavigator.currentPage.path
                //当前显示的页面判断
                if (pagePath === appConfig.routePathStockDetail){
                    pageType = 2  //个股详情
                }

                //排序后 显示
                appConfig.localKBSprite.keys.sort(function(a, b){
                    if (a.DaiMa.indexOf(trimText) === 0){
                        if ( b.DaiMa.indexOf(trimText) !== 0){
                            return -1
                        }

                    }else if  (b.DaiMa.indexOf(trimText) === 0){
                        if  (a.DaiMa.indexOf(trimText) !== 0){
                            return 1
                        }
                    }

                    return a.DaiMa > b.DaiMa ? 1 : -1

                }).forEach(function(item){
                    if (item.DaiMa.indexOf(trimText) >= 0) {
                        if ((pageType !== 2)){
                            if (item.Type !== 2){
                                listModel.set(__currentModelCount, item)
                                __currentModelCount = __currentModelCount + 1
                            }
                        }else{
                            listModel.set(__currentModelCount, item)
                             __currentModelCount = __currentModelCount + 1
                        }
                    }
                })

                //下划线加载
                if (__currentModelCount > 0) {
                    listModel.set(__currentModelCount, {
                                      DaiMa: "",
                                      MingCheng: "",
                                      ShuXing: "",
                                      Type: 99
                                  })
                    __currentModelCount = __currentModelCount + 1
                    listView.currentIndex = 0
                }
            }
        }
    }

    Connections {
        target: kbspriteQuery
        onSuccess: {
            if (data[0]){
                var keyword =  data[0].GuanJianZi

                if (keyword === root.searchedText){
                    if (data[0].JieGuo[0] && data[0].JieGuo[0].ShuJu) {
                        for (var i in data[0].JieGuo[0].ShuJu) {
                            var item = data[0].JieGuo[0].ShuJu[i]
                            item.Type = 0
                            item.Params = {'type':3, 'obj':item.DaiMa}//'type=3&obj=' + item.DaiMa

                            listModel.set(__currentModelCount, item)
                            __currentModelCount = __currentModelCount + 1
                        }
                    }
                }
            }

            if (__currentModelCount > 0){
                listView.currentIndex = 0
            }
            //移出多余的项
            if (__preModelCount > __currentModelCount && __preModelCount == listModel.count){
                for (var n = __preModelCount - 1; n >= __currentModelCount ; n--){
                    listModel.remove(n)
                }
            }
        }
        onError: {
            console.log(error)
            //移出多余的项
            if (__preModelCount > __currentModelCount && __preModelCount == listModel.count){
                for (var n = __preModelCount - 1; n >= __currentModelCount ; n--){
                    listModel.remove(n)
                }
            }
        }
    }

    Connections {
        target: animFadeOut
        onStopped: __close()
    }

    PropertyAnimation {
        id: animFadeIn
        target: root
        duration: root.duration
        easing.type: root.easingInType
        property: 'opacity'
        from: 0
        to: root.__innerOpacity
    }

    PropertyAnimation {
        id: animFadeOut
        target: root
        duration: root.duration
        easing.type: root.easingOutType
        property: 'opacity'
        from: root.__innerOpacity
        to: 0
    }

    Component.onCompleted: {
        root.__innerOpacity = root.opacity
        root.parent = __getRoot(this)
    }

    Keys.onReturnPressed: {
         __kbspriteGoto(listView.currentIndex, null);
    }

    Keys.onEnterPressed: {
        __kbspriteGoto(listView.currentIndex, null);
    }

    Keys.onDownPressed: {

        if (listView.currentIndex === listView.count - 1) {

        } else {
            if (listModel.get(listView.currentIndex + 1).Type === 99) {
                listView.incrementCurrentIndex()
            }
            listView.incrementCurrentIndex()
        }
    }

    Keys.onUpPressed: {
        if (listView.currentIndex === 0) {

        } else {
            if (listModel.get(listView.currentIndex - 1).Type === 99) {
                listView.decrementCurrentIndex()
            }
            listView.decrementCurrentIndex()
        }
    }

    Keys.onEscapePressed: {
        root.hide()
    }

    function __getRoot(item) {
        return (item.parent !== null) ? __getRoot(item.parent) : item
    }

    function show(key) {
        mask.visible = true
        root.focus = true
        keyInput.text = key
        keyInput.textFocus = true

        listView.currentIndex = 0
        root.opacity = __innerOpacity
        root.scale = 1

        mask.visible = showMask

        if (isAnimation) {
            animFadeIn.start()
        }
        root.visible = true
    }

    function hide() {
        if (isAnimation) {
            animFadeOut.start()
        } else {
            __close()
        }
    }

    function trimStr(str) {
        return str.replace(/(^\s*)|(\s*$)/g, "")
    }

    //关闭(私有属性)
    function __close() {
        mask.visible = false
        root.visible = false
        context.pageNavigator.currentPage.forceActiveFocus()
    }

    function __kbspriteGoto(index, codeText){

        if (!codeText ||(codeText && codeText.visible)) {
            //键盘精灵隐藏
            hide()

            //路由跳转
            var currentItem = listModel.get(index)

            UBAUtil.sendUserBehavior(UBAUtil.jianPanBaoTag, currentItem.DaiMa)
            context.pageNavigator.kbspritePush(currentItem)
        }
    }
}
