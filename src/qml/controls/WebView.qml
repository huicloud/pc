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
import QtWebEngine 1.2
import QtQuick.Window 2.0
import Dzh.AppLauncher 1.0

import '.'
import "../util"
import '../core'
import '../core/common'

WebEngineView{
    id: root
    focus: false
    activeFocusOnPress: true
    settings.autoLoadImages: true
    settings.javascriptEnabled: true
    settings.errorPageEnabled: true
    settings.pluginsEnabled: true
    settings.fullScreenSupportEnabled: true
    settings.localContentCanAccessFileUrls: true
    settings.localContentCanAccessRemoteUrls: true

    profile: ApplicationConfigure.webProfile

    property string html
    property bool showIndicator: false
    property var context: ApplicationContext
    property QtObject appConfig: ApplicationConfigure
    property string pdfViewer: Qt.platform.os === 'osx' ? '/../Resources/PDFViewer/web/viewer.html?file=' :'/PDFViewer/web/viewer.html?file='
    property string __prefix: Qt.platform.os === 'osx' ? 'file://' : ''
    signal loadStatusChanged(int loadStatus)

    property Component newsWindowComponent: Qt.createComponent('../components/NewsWindow.qml');

    onHtmlChanged: {
        root && root.loadHtml(html);
    }
    onCertificateError: {
        //浏览器证书错误
        error.defer()
    }

    onLinkHovered: {
    }

    onFeaturePermissionRequested: {
        //申请浏览器权限
        root.grantFeaturePermission(securityOrigin, feature, true)
    }

    onLoadingChanged: {
        root.loadStatusChanged(loadRequest.status)

        if (loadRequest.status == WebEngineView.LoadStartedStatus){
            var loadingUrlStr = loadRequest.url.toString();  //传入的原始url
            var formattedLoadingUrl = loadingUrlStr.toLowerCase();//转为小写，用于统一格式判断大智慧命令

            if ((formattedLoadingUrl.lastIndexOf("dzh://", 0) === 0)){
                var splits = loadingUrlStr.split('?');
                var path = splits[0];          //W3C标准，路径默认会被转为小写，所以这里不需要进行转换
                var query = splits[1] || '';
                var parameters = {};

                query.split('&').forEach(function(eachData){
                    var querySplits = eachData.split('=');
                    parameters[querySplits[0]] = querySplits[1];
                });

                if (path.indexOf('viewstock') !== -1){
                    var codeStr = parameters['LABEL'] || '';
                    var chartType = 'min';
                    if (parameters['PAGE'] === '分时走势'){
                        chartType = 'min';
                        if (codeStr === ''){
                            context.pageNavigator.push(appConfig.routePathStockDetail, {'type':3, 'chart':chartType});
                        }else{
                            context.pageNavigator.push(appConfig.routePathStockDetail, {'type':3, 'obj':codeStr.substr(0, 8).toLocaleUpperCase(), 'chart':chartType});
                        }
                    }else if (parameters['PAGE'] === 'K线走势'){
                        chartType = 'kline';
                        var period = parameters['PERIOD'];
                        if (!period){
                            period = '1day';
                        }

                        if (codeStr === 'PERIOD'){
                            context.pageNavigator.push(appConfig.routePathStockDetail, {'type':3, 'chart':chartType, 'period':period});
                        }else{
                            context.pageNavigator.push(appConfig.routePathStockDetail, {'type':3, 'obj':codeStr.substr(0, 8).toLocaleUpperCase(), 'chart':chartType, 'period':period});
                        }

                    }else if (parameters['PAGE'] === '基本资料'){
                        chartType = 'f10'
                        context.pageNavigator.push(appConfig.routePathStockDetail, {'type':3, 'obj':codeStr.substr(0, 8).toLocaleUpperCase(), 'chart':chartType});
                    }else if (parameters['PAGE'] === '添加自选'){
                         if (codeStr !== ''){
                             // 添加自选股
                             PortfolioUtil.add({obj: codeStr});
                         }
                    }
                }else if (path.indexOf('filemgr') !== -1){
                    var link = parameters['LINK'] || '';
                    if (link !== ''){
                        showWebWindow(link);
                    }
                }else if (path.indexOf('shellexe') !== -1){
                    query = query.replace(/\'/g, "")
                    var parameter = query.split(' ');

                    if (parameter[0] === 'iexplore.exe'){
                        Qt.openUrlExternally(parameter[1]);
                    }
                }else if (path.indexOf('cmd') !== -1){
                    query = query.replace(/\'/g, "");
                    if(query === '委托'){
                        tradeControl.doTrade(false)
                    }
                }else if (path.indexOf('close') !== -1){
                    context.mainWindow.pressEsc();
                }

            } else if (root.isHttp(formattedLoadingUrl)){
                if (root.isPdf(formattedLoadingUrl)){
                    //pdf跳转
                    root.url = __prefix + AppLauncher.getApplicationPath() + pdfViewer + loadingUrlStr; //不能进行大小写转换
                }else{
                    //TODO 临时支持 手机的跳转协议
                    if (formattedLoadingUrl.indexOf('@min=') > -1){
                        var tempSplits = formattedLoadingUrl.split('@');
                        var tempPath = tempSplits[0];
                        var tempQuery = tempSplits[1] || '';
                        var tempParameters = {};

                        tempQuery.split('&').forEach(function(eachData){
                            var querySplits = eachData.split('=');
                            tempParameters[querySplits[0]] = querySplits[1];
                        });

                        var tempCodeStr = tempParameters['min'] || '';
                        context.pageNavigator.push(appConfig.routePathStockDetail, {'type':3, 'chart':'min', 'obj':tempCodeStr.toLocaleUpperCase()});
                    }
                }
            }
        }

        if (loadRequest.status == WebEngineView.LoadFailedStatus) {
            console.log("Load failed! Error code: " + loadRequest.errorCode);
        }

        if (loadRequest.status == WebEngineView.LoadSucceededStatus) {
            if (showIndicator){
                busyIndicator.running = false
            }
        }
    }

    TradeControl{
        id: tradeControl
    }

    BusyIndicator{
        anchors.centerIn: parent
        id: busyIndicator
        running: showIndicator
    }

    onNewViewRequested: {
        if (!request.userInitiated){

        } else{
            request.openIn(root);
        }
    }

    onUrlChanged: {

    }

    onRenderProcessTerminated: {

    }

    onWindowCloseRequested: {
        windowCloseRequestedSignalEmitted = true;
    }

    Component.onCompleted: {
        root.profile.downloadRequested.connect(root.onDownloadRequested)
        root.profile.downloadFinished.connect(root.onDownloadFinished)

        if (html) {
            loadHtml(html);
        }
    }

    ListModel {
        id: downloadModel
        property var downloads: []
    }

    //下载相关 todo
    function append(download) {
        downloadModel.append(download)
        downloadModel.downloads.push(download)
    }

    function onDownloadRequested(download) {
        console.log('onDownloadRequested', download)
        download.accept()
    }

    function onDownloadFinished(download){
        console.log('onDownloadFinished', download)
    }

    function isAttach(url) {
        if(url.slice(-4) === ".rar"  || url.slice(-4) === ".zip")
            return true
        else
            return false
    }

    function isPdf(url) {
        return url.slice(-4) === ".pdf";
    }

    function isHttp(url){
        return (url.lastIndexOf('http://') === 0 || url.lastIndexOf('https://') === 0)
    }

    function showWebWindow(url) {

        // 判断当前新闻窗口是否存在，不存在打开新闻窗口，然后加载context对应连接，具体context是zlib还是pdf在新闻窗体中判断处理
        if (!context.commonNewsWindow) {

            // 创建子窗口，parent设置为0则打开独立窗口，TODO 需要考虑关闭主窗口时关闭子窗口
            context.commonNewsWindow = newsWindowComponent.createObject(context.mainWindow);

            // 关闭窗口时，将当前窗口删除(目前保留) 清空残留
            context.commonNewsWindow.closing.connect(function() {
                context.commonNewsWindow.clearWebView();
            });
        } else if (context.commonNewsWindow.visibility === Window.Minimized) {
            // 如果窗口当前状态为最小化时，将窗体还原(最小化还原后窗口看不见了)
            context.commonNewsWindow.visibility = Window.Windowed;
        }

        context.commonNewsWindow.load(url, 2);
        context.commonNewsWindow.show();
    }

}
