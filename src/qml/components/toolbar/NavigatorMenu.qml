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
  * @brief  工具栏中的菜单栏
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import QtQuick.Controls 1.4 as Controls

import "../../core"
import "../../controls"
import "../../util"

ContextComponent {
    id: navigator
    property int itemWidth: theme.toolbarMenuButtonWidth
    property int itemHeight: theme.toolbarMenuButtonHeight
    property int itemSpacing: 2
    implicitWidth: itemWidth * model.count + itemSpacing * (model.count - 1)
    implicitHeight: theme.toolbarHeight
    ListView {
        id: listView
        highlightFollowsCurrentItem: false
        spacing: itemSpacing
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: model
        delegate: componentDelegate
    }

    //单选控制
    Controls.ExclusiveGroup {
        id: radioToolbarItemGroup
    }

    Component {
        id: componentDelegate
        Button {
            id: menuButton
            width: itemWidth
            height: itemHeight
            textColor: theme.toolbarButtonTextColor
            text: name
            hoveredRadius: itemHeight / 2
            checkedRadius: itemHeight / 2
            checkable: url === '/jiaoyi'? false: true
            checked: index == 0 ? true : false
            isAlwaysChecked: true
            //backgroundMarginBottom: 6
            //backgroundMarginTop: 6
            anchors{
                top: parent.top
                topMargin: (parent.height - itemHeight) / 2
                bottom: parent.bottom
                bottomMargin: (parent.height - itemHeight) / 2
            }
            hoveredColor: theme.toolbarButtonHoverColor
            checkedColor: theme.toolbarButtonCheckedColor
            checkedTextColor: theme.toolbarButtonCheckedTextColor
            exclusiveGroup: radioToolbarItemGroup
            onClickTriggered: {


                //调用路由进行页面跳转
                if (url === '/jiaoyi'){
                    //交易暂时特殊处理
                    tradeControl.doTrade(false);
                }else{
                    UBAUtil.sendUserBehavior(tag) //一级导航统一处理，记录用户行为
                    navigator.context.pageNavigator.push(url)
                }
            }
        }
    }

    TradeControl{
        id: tradeControl
    }
     //property int ziXuanTag: 27
     //property int huSHenTag: 28
     //property int xuanGuTag: 29
     //property int ziXunTag: 30
     //property int jiaoYiTag: 31
    ListModel {
        id: model
        ListElement {
            name: '自选'
            url: '/zixuanguliebiao?type=1'
            tag: 27
        }
        ListElement {
            name: '沪深'
            url: '/hushenliebiao?market=60&tableHeaderType=1'
            tag: 28
        }
        ListElement {
            name: '选股'
            url: '/xuangu?type=1'
            tag: 29
        }
        ListElement {
            name: '资讯'
            url: '/zixun?type=1'
            tag: 30
        }
        ListElement {
            name: '交易'
            url: '/jiaoyi'
            tag: 31
        }
    }

    //用于更新菜单按钮的选中状态
    function updateCheckedState(url){

        for(var i = 0; i < model.count; i++)
        {
            var menuUlr = model.get(i).url;
            if(url.indexOf(menuUlr.split('?')[0]) >= 0){
                if (listView.contentItem.children[i])
                {
                    listView.contentItem.children[i].checked= true;
                    break;
                }
            }else{
                if (listView.contentItem.children[i])
                    listView.contentItem.children[i].checked= false;
            }
        }
    }
}
