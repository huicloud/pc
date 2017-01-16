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

import QtQuick 2.6
import QtQuick.Controls 1.4 as Controls
//import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import Dzh.MainWindow 1.0

import 'core'
import 'core/data'
import 'core/common'
import 'controls'
import 'components'

MainWindow {
    id: mainWindow
    title: qsTr("大智慧-舵手版")

    property Login loginWindow //登录窗口

    ContextComponent {
        id: applicationContent
        anchors.fill: parent
        focusAvailable: false
        property QtObject appConfig: ApplicationConfigure   //全局配置信息
        RectangleWithBorder{
            id: content
            anchors.fill: parent
            leftBorder: 1
            rightBorder: 1
            topBorder: 0
            bottomBorder: 1
            border.color: applicationContent.theme.toolbarColor

            //顶部标题栏
            Toolbar{
                id: toolbar
                //width: parent.width
                height: applicationContent.theme.toolbarHeight
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                mainWindow: mainWindow
            }

            //内容切换区
            PageNavigator {
                id: pageNavigator
                anchors.top: toolbar.bottom
                anchors.left:parent.left
                anchors.right: parent.right
                anchors.bottom: statusbar.top
            }

            //底部状态栏
            Statusbar{
                id: statusbar
                height: applicationContent.theme.statusbarHeight
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                keyboardSprite: kbSprite
                floatContent: applicationContent

                //分割线
                SeparatorLine {
                    id: statusBarTopLine
                    orientation: Qt.Horizontal
                    length: parent.width
                    anchors.bottom: parent.top
                }
            }

            //键盘精灵
            KeyboardSprite {
                id: kbSprite
                isAnimation: false
                showMask: true
                appContent: applicationContent
                x: parent.x + parent.width - kbSprite.width;
                y: parent.y + parent.height - kbSprite.height -31
                z: 101
                opacity: 1
                radius: 1
                visible: false;
            }
        }

        TradeControl{
            id: tradeControl
            //            onResetTrade: {
            //                //调整到交易界面
            //                applicationContent.context.pageNavigator.push(appConfig.routePathTrade)
            //            }
        }

        Component.onCompleted: {
            //将当前菜单栏传入路由器，用于被更新按钮状态
            pageNavigator.navigatorMenu = toolbar.navigatorMenu
            applicationContent.context.pageNavigator = pageNavigator


            // 初始化主题
            applicationContent.context.themeManager.changeTheme(
                        applicationContent.context.setting.theme)

            applicationContent.context.mainWindow = mainWindow;
        }

        focus: true

        //全局键盘事件处理
        Keys.onPressed:{
            //键盘宝
            if(((event.key >= Qt.Key_0 && event.key <= Qt.Key_9) || (event.key>= Qt.Key_A && event.key <= Qt.Key_Z)) &&
                    ((event.modifiers !== Qt.ShiftModifier) && (event.modifiers !== Qt.AltModifier) && (event.modifiers !== Qt.ControlModifier))){
                if (!kbSprite.visible){
                    kbSprite.show(event.text)
                }
                event.accepted = true;
                return;
            }

            //F10切到个股资料页面
            if (event.key === Qt.Key_F10){
                var item =  applicationContent.context.pageNavigator.currentPage;
                if (item && item.obj && item.obj.length > 0){
                    applicationContent.context.pageNavigator.push(appConfig.routePathStockDetail, {'chart' : 'f10', 'obj' : item.obj})
                }
                event.accepted = true;
                return;
            }

            //老板键功能
            if (event.key === Qt.Key_Pause){
                mainWindow.showMinimized();
                event.accepted = true;
                return;
            }

            if (event.key === Qt.Key_F3 || event.key === Qt.Key_F4){
                var keysResult = [];
                var key = '';

                if (event.key === Qt.Key_F3){
                    key = '03'  //上证指数分时
                }else{
                    key = '04'  //深圳指数分时
                }
                keysResult = appConfig.localKBSprite.keys.filter(function(item, index){
                    if (item.DaiMa === key)
                        return true;
                })

                if (keysResult.length > 0)
                    applicationContent.context.pageNavigator.push(appConfig.routePathStockDetail, keysResult[0].Params);

                event.accepted = true;
                return;
            }

            //自选股
            if (event.key === Qt.Key_F6){
                applicationContent.context.pageNavigator.push(appConfig.routePathSelfStock, {'type':1});
                event.accepted = true;
                return;
            }

            //委托
            if (event.key === Qt.Key_F12){
                tradeControl.doTrade(false)
                event.accepted = true;
                return;
            }

            //ESC回退
            if (event.key === Qt.Key_Escape){
                pressEsc();
                event.accepted = true;
                return;
            }

            //退格按键
            if (event.key === Qt.Key_Backspace){
                toolbar.navigatorBack();
                event.accepted = true;
                return;
            }
        }
    }

    Component.onCompleted: {

        // 提前初始化加载
        preLoad();

        loginWindow.loginSuccessed.connect(function() {
            postLoad();
        });
    }

    function pressEsc(){
        if(kbSprite.visible){
            kbSprite.hide()
        } else {
            applicationContent.context.pageNavigator.esc();
        }
    }

    function preLoad() {
        // TODO 页面相关
    }

    function postLoad() {
        //主窗口最大化加载资源后再隐藏，减少因窗口变化引起的不必要的计算
        mainWindow.showMaximized();
        mainWindow.hide();
        // TODO 登录成功后用户相关加载, 加载过程中需要判断登录框状态，如果不是加载中状态则停止加载（登录框中的取消登录功能）
        // TODO 连接服务器
        DataChannel.openChannel();

        //加载指定页面
        loginWindow.load(30, '初始化中……');
        applicationContent.context.pageNavigator.push(applicationContent.appConfig.routePathSelfStock, {'type':1});

        //预加载部分需缓存页面
        loginWindow.load(50, '资源预加载中……');

        if (applicationContent.context.pageNavigator.isInitialized){
            //登录成功后 退出登录再进行登录的情况
            loadFinish();
        }else{
            //第一次进行登录
            loginWindow.load(90, '资源预加载中……');
            applicationContent.context.pageNavigator.pageInitializeFinished.connect(function(){
                loadFinish();
            });
            applicationContent.context.pageNavigator.pageInitialize();
        }
    }

    function loadFinish(){
        // TODO 用户配置读取
        // TODO 用户自选股

        // TODO 完成加载隐藏登录框，显示主窗体
        loginWindow.finish();
        loginWindow.hide();
        mainWindow.visible = true;

        // 监控被踢
        UserService.subscribeKickoff(function() {

            loginWindow.error('你的帐号已经在别的终端中登录');
            loginWindow.show();
        });
    }

    Dialog{
        id: hintdialog
        miniTitlebar: true
        showButton: true
        confirmType: 2
        flags: Qt.Window  | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
        title: '提示'
        width: 200
        height: 120
        isSimple: true
        property string hintText;
        customItem: Text{
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            width: parent.width
            text:'是否退出程序？'
        }

        onDialogConfirm:{
            mainWindow.close();
        }

        onDialogCancel: {

        }
    }

    function closeQuery(){
        hintdialog.show();
        return false;
    }

    //    Connections {
    //        target: loginWindow
    //        onLoginSuccessed: {
    //            postLoad();
    //        }
    //    }

    //    //显示登陆框
    //    function showLoginWindow() {
    //        if (!loginWindow) {
    //            var component = Qt.createComponent("components/Login.qml");
    //            if (component.status === Component.Ready){

    //                loginWindow = component.createObject(mainWindow);
    //                if (loginWindow !== null) {
    //                    // 关闭窗口时，将当前窗口删除 程序退出
    //                    loginWindow.closing.connect(function() {
    //                        loginWindow.destroy();
    //                        loginWindow = null;

    //                        mainWindow.close();
    //                    });

    //                    //登录成功信号
    //                    loginWindow.loginSuccessed.connect(function() {
    //                        mainWindow.visible = true;
    //                        mainWindow.showMaximized();

    //                        loginWindow.destroy();
    //                        loginWindow = null;
    //                    });

    //                    loginWindow.show();
    //                }else{
    //                    //发现异常 退出
    //                    mainWindow.close();
    //                }
    //            }
    //        }
    //    }
}
