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
import Dzh.AppLauncher 1.0
import Qt.labs.settings 1.0

import '../core'
import '../util'
import './'

ContextComponent {
    id: root
    signal resetTrade()
    property var tradeDialog;
    property var tradeSetting: TradeSetting

    function getRealPath(path){
        var pathStr = path.toString()
        if (pathStr.lastIndexOf('file:///') === 0)
            return pathStr.substring(8)
        else
            return pathStr
    }

    //启动指定委托程序
    function runTradeApp(tradeName, fileName){
        if (AppLauncher.isFileExits(fileName)){
            if (AppLauncher.isRunning()){
                //已经打开的提醒
                hintdialog.width = 300
                hintdialog.height = 120
                hintdialog.hintText = '您的委托程序已经在运行中了。'
                hintdialog.show()
            }else{
                if (!AppLauncher.lauchDetached(fileName)){
                    hintdialog.width = 300
                    hintdialog.height = 120
                    hintdialog.hintText = '委托程序启动出现异常！'
                    hintdialog.show()
                }
            }

            return true;
        }else{
            hintdialog.width = 400
            hintdialog.height = 150
            hintdialog.hintText = "默认委托“"+ tradeName + "”("+fileName+")无法打开，请至我的-委托设置进行快捷委托设置。"
            hintdialog.show();
            //找不到配置的委托程序
            return false;
        }
    }

    //委托设置界面
    function settingTrade(){
        //委托设置
        var component = Qt.createComponent('/dzh/pages/Trade.qml')
        if (component.status === Component.Ready){
            if (!tradeDialog){
                tradeDialog = component.createObject(mainWindow);
                tradeDialog.show()
                tradeDialog.refreshTradeList();
                tradeDialog.closing.connect(function() {
                    tradeDialog.destroy();
                    tradeDialog = null;
                });
            }
        }
    }


    function doTrade(isSetting){
        if (Qt.platform.os === 'osx'){
            hintdialog.width = 300
            hintdialog.height = 120
            hintdialog.hintText = '交易功能暂不支持MacOS，敬请期待！'
            hintdialog.show()
            //Qt.openUrlExternally('DZHTradeTo://www.gw.com.cn') //todo 可以放开用于Mac版的交易程序的激活
        } else {
            if (isSetting){
                settingTrade()
            }else{
                UBAUtil.sendUserBehavior(UBAUtil.jiaoYiTag); //交易的用户行为统计

                var path = ''
                var tradeName = root.tradeSetting.defaultTradeName;
                var tradeList = JSON.parse(root.tradeSetting.tradeList);

                for(var i=0; i < tradeList.length; i++){
                    if (tradeList[i].name === tradeName){
                        path = tradeList[i].path;
                        break;
                    }
                }

                var fileName = getRealPath(path)

                if (tradeName !== ""){
                   runTradeApp(tradeName, fileName)
                }else{
                    //委托没有配置的情况下
                    settingTrade();
                }
            }
        }
    }

    Dialog{
        id: hintdialog
        miniTitlebar: true
        showButton: true
        confirmType: 1
        title: '提示'
        width: 300
        height: 150
        property string hintText;
        customItem: Text{
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            width: parent.width
            text: hintdialog.hintText
        }
    }
}
