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
  * @brief  工具栏左上角的回退按钮控件
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import QtQuick.Controls 1.4
import "../../core"
import "../../core/common"
import "../../controls"
import "../../util"

ContextComponent {
    id: backItem

    width: theme.toolbarBackItemButtonWidth
    height: theme.toolbarBackItemButtonHeight

    clip: true
    signal popMenu()

    Image {
        id: background
        anchors.centerIn: parent
        source: theme.backItemBackground
        clip: true
        IconButton {
            id: backItemArrow
            width: parent.width / 5 * 3
            height: parent.height
            iconSize: Qt.size(backItemArrow.width, backItemArrow.height)
            anchors.left: parent.left
            anchors.top: parent.top
            iconRes: backItem.context.pageNavigator.historyList.count > 1 ? theme.iconBackArrow : theme.iconBackArrowNull
        }

        IconButton {
            id: backItemDropdwon
            width: parent.width / 5 * 2
            height: parent.height
            iconSize: Qt.size(backItemDropdwon.width, backItemDropdwon.height)
            anchors.top: parent.top
            anchors.right: parent.right
            iconRes: theme.iconBackItemDropdown
        }
    }

    onPopMenu: {
        if ((menu !== null) && (backItem.context.pageNavigator.historyList.count > 1)){
            menu.clear()

            //最多显示前20条路由记录
            var minIndex = Math.max(0, backItem.context.pageNavigator.historyList.count - 20)

            for (var i = backItem.context.pageNavigator.historyList.count - 2; i >= minIndex; i--){
                var history = backItem.context.pageNavigator.historyList.get(i)

                var stockName = ''
                var titleStr = history['title']

                if (titleStr.indexOf('$') === 0){
                    //含表达式的计算
                    var match = titleStr.match(/\$\{stock\[(.*)\]\.(.*)\}/);
                    var obj = match[1];
                    var field = match[2];
                    if (field === 'name'){
                        stockName = StockUtil.getStockName(obj, function(name){});
                        if (stockName === ''){
                            titleStr =  history['url']
                        }else{
                            titleStr = obj + stockName
                        }
                    }
                }

                var item = menu.addItem(titleStr);
                item.url = history['url']
                __bingAction(item)
            }
            menu.__minimumWidth = 200
            menu.__popup(Qt.rect(0, backItem.height, 0, 0), 0)
        }
    }

    PopMenu{
        id: menu
    }

    Binding {
        target: menu
        property: "__visualItem"
        value: backItem
    }

    Connections {
        target: backItemDropdwon
        onClickTriggered: {
            backItem.popMenu();
        }
    }

    Connections {
        target: backItemArrow
        onClickTriggered: {
            back()
        }
    }


    function __bingAction(item){
        item.triggered.connect(function(){
            //backItem.context.pageNavigator.historyList.remove(item.index)
            backItem.context.pageNavigator.push(item.url)
        })
    }

    //回退入口
    function back(){
        backItem.context.pageNavigator.pop();
    }
}
