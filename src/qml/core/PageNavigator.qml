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

import "./common"
import "../util"
import "../js/Util.js" as Util
/**
 * 路由组件
 */
Item {
    id: root;
    property QtObject appConfig: ApplicationConfigure   //全局配置信息
    property Item currentPage: currentLoader !== null ? currentLoader.item: null
    property ListModel historyList: ListModel{} //路由历史记录
    property Loader currentLoader: null         //当前加载器
    property Item navigatorMenu: null           //外部传入的导航栏菜单

    property bool isInitialized: false          //是否已经初始化过
    signal pageInitializeFinished()             //初始化完成信号

    //解析url，找到对应的route，跳转到对应的页面，parameters为参数对象，可选
    function push(url, parameters){
        if ((arguments.length >= 2) ){
            var jionParameters = '';
            jionParameters = Util.paramNoURI(parameters);   //object转url参数
            if (jionParameters.length !== 0){
                 jionParameters = '?' + jionParameters.substr(1);
            }
            pushWithStates(url + jionParameters, true)
        }else{
            pushWithStates(url, true)
        }
    }

    //解析url，找到对应的route，跳转到对应的页面，  isRecordHistory是否记录到路由历史中
    function pushWithStates(url, isRecordHistory) {

        if (root.currentLoader){
            if (root.currentLoader.states === Loader.Loading){
                console.info("当前路由正在加载中，不支持新的路由跳转")
                return;
            }
        }

        UBAUtil.sendUserBehaviorUrl(url);

        // TODO 解析url的前缀协议
        var splits = url.split('?');
        var path = splits[0];
        var query = splits[1] || '';

        var route = appConfig.routeMap[path];

        if (isRecordHistory){
            if(historyList.count > 0){
                var tempUrl = historyList.get(historyList.count - 1)['url'];
                if (url !== tempUrl){
                    //如果和最新一次url不一致 则进入路由历史
                    historyList.append({'url': url, 'title': ''})
                }
            }else{
                historyList.append({'url': url, 'title': ''})
            }
        }

        if (route) {

            if ( navigatorMenu){
                //更新菜单栏的按钮状态
                navigatorMenu.updateCheckedState(path)
            }

            //解析query为property
            var parameters = {};
            query.split('&').forEach(function(eachData) {
                var splits = eachData.split('=');
                parameters[splits[0]] = splits[1];
            })

            var newLoader;

            if(path === appConfig.routePathMarketList){
                newLoader = marketListPage
            }else if (path === appConfig.routePathSelfStock){
                newLoader = selfStockPage
            }else if (path === appConfig.routePathStockDetail){
                newLoader = stockDetailPage
            }else if (path === appConfig.routePathSelectStock){
                newLoader = selectStockPage
            }else if (path === appConfig.routePathTrade){
                newLoader = tradePage
            }else if (path === appConfig.routePathNews){
                newLoader = newsPage
            }else if (path === appConfig.routePathFeedback){
                newLoader = feedbackPage
            }else {
                //不在预加载中的页面的动态加载
                otherLoader.source = route
                newLoader = otherLoader;
            }

            if (root.currentLoader){

                if (root.currentLoader.item && root.currentLoader.item.objectName === 'WebEngine'){
                    root.currentLoader.focus = false
                    if (root.currentLoader.item.context.mainWindow){
                        //如果当前加载页面是webview 则修改mainwindow的状态
                        root.currentLoader.item.context.mainWindow.isSelectedWebViewState = false
                    }
                }

                if (root.currentLoader !== newLoader){
                    //装载器不相同时先设置为不可见
                    root.currentLoader.visible = false
                }

                if (root.currentLoader.item){
                    //取消激活上一个页面(发送信号)
                    root.currentLoader.item.afterDeactive()
                }

                if (root.currentLoader !== newLoader){
                    //装载器不相同时 有销毁标记时 销毁
                    if (root.currentLoader.hasOwnProperty('isDestroy')) {
                        root.currentLoader.active = false
                    }
                }
            }

            root.currentLoader = newLoader
            root.currentLoader.active = true

            if (root.currentLoader.item){
                root.currentLoader.item.path = path
                root.currentLoader.item.params = query
                root.currentPage = root.currentLoader.item

                for (var key in parameters){
                    if ((key !=='') && parameters.hasOwnProperty(key)){
                        root.currentLoader.item[key] = parameters[key];
                    }
                }

                //将新内容的title内容更新到路由历史中
                if (isRecordHistory)
                    historyList.setProperty(historyList.count - 1, 'title', root.currentPage.title)

                __processWebView()  //处理浏览器界面

                //激活页面初始化信号
                root.currentLoader.item.afterActive()
                root.currentLoader.visible = true
            }else{

                /*页面存在懒加载的时候的情况，loader成功加载页面后触发
                  预加载的页面，则不会进入此过程
                */
                root.currentLoader.loaded.connect(function(){

                    root.currentPage = root.currentLoader.item

                    //将新内容的title内容更新到路由历史中
                    if (isRecordHistory)
                        historyList.setProperty(historyList.count - 1, 'title', root.currentPage.title)

                    for (var key in parameters){
                        if ((key !== '') && parameters.hasOwnProperty(key)){
                            root.currentLoader.item[key] = parameters[key];
                        }
                    }

                    __processWebView()  //处理浏览器界面

                    //激活页面初始化信号
                    root.currentLoader.item.afterActive()
                    root.currentLoader.visible = true
                })
            }
        } else {
            console.error('route error in path:', path)
        }
    }

    function __processWebView(){
        //激活新的页面 触发loaded信号 已存在的不触发
        if (root.currentLoader.item && root.currentLoader.item.objectName === 'WebEngine'){
            root.currentLoader.focus = false
            if (root.currentLoader.item.context.mainWindow){
                //如果当前加载页面是webview 则修改mainwindow的状态
                root.currentLoader.item.context.mainWindow.isSelectedWebViewState = true
            }
        }else{
            root.currentLoader.focus = true
//            if (root.currentLoader.item && root.currentLoader.item.context.mainWindow){
//                root.currentLoader.item.context.mainWindow.isSelectedWebViewState = false
//            }
        }
    }

    //回退按钮
    function pop() {

        /*historyList.count = 1 时不能进行回退，已回到默认的初始页面*/
        if (currentPage && currentPage.objectName === 'WebEngine'){
            if (currentPage.webView.canGoBack){
                //如果当前是web页面，则当前webengine的页面先进行回退
                currentPage.webView.goBack();
                return;
            }
        }

        if (historyList.count > 1){
            historyList.remove(historyList.count - 1);
            var url = historyList.get(historyList.count - 1)['url'];
            var title = historyList.get(historyList.count - 1)['title'];
            pushWithStates(url, false)
        }
    }

    //esc键
    function esc() {
        if (historyList.count > 1){
            var currentUrl = historyList.get(historyList.count - 1)['url'];
            var currentPath = currentUrl.split('?')[0];  //当前正在展示的路径
            var level = currentPath.split('/').length - 1
            //如果当前是1级菜单
            if(level === 1) return

            for (var i = historyList.count - 2; i >= 0; i--){
                var tempUrl = historyList.get(i)['url'];
                var tempPath = tempUrl.split('?')[0];   //遍历展示过的路径历史
                var templevel = tempPath.split('/').length - 1
                if(templevel === 1){
                    pushWithStates(tempUrl, true)
                    break
                }
            }
        }

        /*------------------------------------------------------------------------
                if (historyList.count > 0){
                    var currentUrl = historyList.get(historyList.count - 1)['url'];
                    var currentPath = currentUrl.split('?')[0];  //当前正在展示的路径
                    for (var i = historyList.count - 2; i >= 0; i--){
                        var tempUrl = historyList.get(i)['url'];
                        var tempPath = tempUrl.split('?')[0];   //遍历展示过的路径历史
                        if (currentPath !== tempPath)
                        {
                             historyList.remove(historyList.count - 1)
                             pushWithStates(tempUrl, false)
                             break;
                        }else{
                            if(i === 0){
                                 //保留最后一个记录
                                 historyList.remove(historyList.count - 1)
                                 pushWithStates(tempUrl, false)
                            }
                            else {
                                historyList.remove(i)
                            }
                        }
                    }
                }
        --------------------------------------------------------------------------*/
    }

    /*键盘宝的路由控制入口*/
    function kbspritePush(item){
        if (item.Type === 0) {
            push(appConfig.routePathStockDetail, item.Params)
        }else if (item.Type === 1){
            if (item.DaiMa === '06' || item.DaiMa === '060'){
                push(appConfig.routePathSelfStock, item.Params)
            } else {
                push(appConfig.routePathMarketList, item.Params)
            }
        }else if (item.Type === 2){
            //个股详细页的键盘宝快捷键
            if (currentLoader){
                var obj = currentPage.obj;                
                if (currentLoader.objectName !== 'stockDetailPage'){
                    if (item.Params){
                        item.Params.split('&').forEach(function(eachData) {
                            var splits = eachData.split('=');
                            currentPage[splits[0]] = splits[1];
                        })
                        currentPage['selectObj'] = obj

                    }
                }else{
                    //当前加载器不是个股详细页面则进行跳转 一般不出现此情况
                    item.Params.type = 3;
                    item.Params.obj = obj;
                    push(appConfig.routePathStockDetail, item.Params)
                }
            }
        } else if (item.Type === 3){
            //常用指数
            push(appConfig.routePathStockDetail, item.Params)
        }
    }

    /**
    *所有页面的加载器组件
    */
    function pageInitialize(){
        loaderTimer.start()
    }

    Timer{
        id: loaderTimer
        interval: 200
        onTriggered: {
            var loadedCount = 0;
            var initialLoadCallBack = function(){

                loadedCount++;
                if (loadedCount === 5){
                    //加载完成 取消关联
                    marketListPage.loaded.disconnect(initialLoadCallBack);
                    stockDetailPage.loaded.disconnect(initialLoadCallBack);
                    newsPage.loaded.disconnect(initialLoadCallBack);
                    selectStockPage.loaded.disconnect(initialLoadCallBack);
                    feedbackPage.loaded.disconnect(initialLoadCallBack);

                    isInitialized = true;            //预加载完成标志
                    root.pageInitializeFinished();   //发送加载完成信号
                }
            }

            marketListPage.loaded.connect(initialLoadCallBack);
            stockDetailPage.loaded.connect(initialLoadCallBack);
            newsPage.loaded.connect(initialLoadCallBack);
            selectStockPage.loaded.connect(initialLoadCallBack);
            feedbackPage.loaded.connect(initialLoadCallBack);

            marketListPage.active = true;
            stockDetailPage.active = true;

            //Web页面启动时缓存
            newsPage.active = true;
            selectStockPage.active = true;
            feedbackPage.active = true;
        }
    }

    //自选股页面加载器[启动立即预加载]
    Loader{
        id: selfStockPage

        anchors.fill: parent
        source: appConfig.routeMap[appConfig.routePathSelfStock]
        visible: false
        active : true
    }

    //沪深行情列表加载器[延后预加载]
    Loader{
        id: marketListPage
        anchors.fill: parent
        asynchronous : true
        source: appConfig.routeMap[appConfig.routePathMarketList]
        visible: false
        active: false
    }

    //个股详情加载器[延后预加载]
    Loader{
        id: stockDetailPage
        objectName: 'stockDetailPage'
        anchors.fill: parent
        asynchronous : true
        source: appConfig.routeMap[appConfig.routePathStockDetail]
        visible: false
        active: false
    }

    //选股页面加载器[延后预加载]
    Loader{
        id: selectStockPage
        anchors.fill: parent
        asynchronous : true
        source: appConfig.routeMap[appConfig.routePathSelectStock]
        visible: false
        active: false
        //property bool isDestroy: true  //销毁标记
    }

    //交易页面加载器
    Loader{
        id: tradePage
        anchors.fill: parent
        asynchronous : true
        source: appConfig.routeMap[appConfig.routePathTrade]
        visible: false
        active: false
        property bool isDestroy: true  //销毁标记
    }

    //资讯页面加载器[延后预加载]
    Loader{
        id: newsPage
        anchors.fill: parent
        asynchronous: true
        source: appConfig.routeMap[appConfig.routePathNews]
        visible: false
        active: false
       // property bool isDestroy: true //销毁标记
    }

    //反馈页面加载器[延后预加载]
    Loader{
        id: feedbackPage
        anchors.fill: parent
        asynchronous: true
        source: appConfig.routeMap[appConfig.routePathFeedback]
        visible: false
        active: false
       // property bool isDestroy: true //销毁标记
    }


    //其他页面的懒加载器
    Loader{
        id: otherLoader
        anchors.fill: parent
        asynchronous: true
        visible: false
        active: false
        property bool isDestroy: true //销毁标记
    }
}
