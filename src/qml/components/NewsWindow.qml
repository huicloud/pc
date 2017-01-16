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
import QtQuick.Window 2.2
import Dzh.FrameLessWindow 1.0
import QtWebEngine 1.2

// 导入C++中注册的连接模块
import Dzh.Data 1.0;

import "../core"
import "../controls"
import "../components"
import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

/**
 * 新闻和公告展示窗口组件
 */
FrameLessWindow {

    id: root
    isSelectedWebViewState: true
    width: 860   // 初始大小为设计指定的860 * 540
    height: 540
    property string source
    property string date
    property string content

    // 默认不显示
    visible: false

    Component.onCompleted: {
        root.visible = true;

        // 初始位置在屏幕中间
        root.x = (Screen.width - root.width) / 2
        root.y = (Screen.height - root.height) / 2
    }

    // 标题由外部传入
    title: '大智慧'

    flags: Qt.Window  | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint

    property var theme: ThemeManager.currentTheme
    property int newsWindowUpMargin: theme.newsWindowUpMargin
    property int newsWindowRightMargin: theme.newsWindowRightMargin
    property int newsWindowBottomMargin: theme.newsWindowBottomMargin
    property int newsWindowLeftMargin: theme.newsWindowLeftMargin

    property string newsTitleFontFamily: theme.newsTitleFontFamily
    property int newsTitleFontSize: theme.newsTitleFontSize
    property int newsTitleFontWeight: theme.newsTitleFontWeight
    property color newsTitleColor: theme.newsTitleColor
    property int newsTitleUpMargin: theme.newsTitleUpMargin
    property int newsTitleRightMargin: theme.newsTitleRightMargin
    property int newsTitleBottomMargin: theme.newsTitleBottomMargin
    property int newsTitleLeftMargin: theme.newsTitleLeftMargin

    property string newsSourceFontFamily: theme.newsSourceFontFamily
    property int newsSourceFontSize: theme.newsSourceFontSize
    property int newsSourceFontWeight: theme.newsSourceFontWeight
    property color newsSourceColor: theme.newsSourceColor
    property int newsSourceUpMargin: theme.newsSourceUpMargin
    property int newsSourceRightMargin: theme.newsSourceRightMargin
    property int newsSourceBottomMargin: theme.newsSourceBottomMargin
    property int newsSourceLeftMargin: theme.newsSourceLeftMargin

    property string newsDateFontFamily: theme.newsDateFontFamily
    property int newsDateFontSize: theme.newsDateFontSize
    property int newsDateFontWeight: theme.newsDateFontWeight
    property color newsDateColor: theme.newsDateColor
    property int newsDateUpMargin: theme.newsDateUpMargin
    property int newsDateRightMargin: theme.newsDateRightMargin
    property int newsDateBottomMargin: theme.newsDateBottomMargin
    property int newsDateLeftMargin: theme.newsDateLeftMargin

    property string newsContentFontFamily: theme.newsContentFontFamily
    property int newsContentFontSize: theme.newsContentFontSize
    property int newsContentFontWeight: theme.newsContentFontWeight
    property color newsContentColor: theme.newsContentColor
    property int newsContentUpMargin: theme.newsContentUpMargin
    property int newsContentRightMargin: theme.newsContentRightMargin
    property int newsContentBottomMargin: theme.newsContentBottomMargin
    property int newsContentLeftMargin: theme.newsContentLeftMargin

    RectangleWithBorder {
        anchors.fill: parent
        leftBorder: 1
        rightBorder: 1
        topBorder: 0
        bottomBorder: 1
        border.color: theme.toolbarColor

        TitleBar {
            id: toolbar
            anchors.top: parent.top
            anchors.left: parent.left

            width: parent.width
            height: 34
            mainWindow: root
            title: root.title
        }
        Rectangle{
            anchors.top: toolbar.bottom
            anchors.left: parent.left

            height: parent.height - toolbar.height
            width: parent.width

            WebView {
                id: webView
                anchors.fill: parent
            }
        }
    }

    function clearWebView(){
        webView.html = '';
        root.title = '';
    }

    function load(news, newsType, obj) {

        clearWebView();

        //newsType 0 为云平台的数据接口 1 为手机端的资讯数据接口 2为直接打开连接
        if (newsType === 0){
            var context = news.Context;
            root.title = news.Title || '';

            // 判断context链接是zlib还是pdf
            if (context.slice(-4).toLowerCase() === 'zlib') {
                root.source = news.Source || '';
                root.date = DateUtil.moment(news.Date, 'YYYYMMDDHHmmss').format('YYYY-MM-DD HH:mm:ss');
                root.content = '';

                // 内容加载前显示新闻标题信息
                webView.html = root.newsHtml;

                // 加载zlib格式的新闻
                requestNewsContent(context, function(content) {
                    root.content = content;
                    webView.html = root.newsHtml;
                });

            } else if (context.slice(-3).toLowerCase() === 'pdf') {
                webView.url = context;
            } else {
                webView.url = context;   //可能出现公告直接是网页地址的情况
            }
        }else if(newsType === 1){
            root.title = news.title || '';
            root.date = DateUtil.moment(news.otime).format('YYYY-MM-DD HH:mm:ss');
            root.source = news.source || '';
            if (['SH000001', 'SZ399001', 'SZ399006'].indexOf(obj) > -1){
                root.source = root.source || '大智慧资讯中心转载'
            }
            root.content = '';

            var contentUrl = news.url;
            var reqCallback = function(content){
                var jsonContent = JSON.parse(content);
                if (jsonContent.length > 0){
                    var returnContent = jsonContent[0];
                    var reg = new RegExp('href="@min=',"g");
                    root.content = returnContent.content.replace(reg,'href="DZH://VIEWSTOCK?PAGE=分时走势&LABEL=');

                    webView.html = root.newsHtml;
                }
            }
            Util.ajaxGet(contentUrl, reqCallback);
        }else if(newsType === 2){
            webView.url = news;
        }
    }

    property var lastRequestCallback

    // 每次请求前先将之前最后一次的请求取消，再请求
    function requestNewsContent(contextUrl, callback) {
        if (lastRequestCallback) {
            Channel.messageNews.disconnect(lastRequestCallback);
        }

        Channel.messageNews.connect(callback);
        Channel.sendNews(contextUrl);

        lastRequestCallback = callback;
    }

    Component.onDestruction: {
        if (lastRequestCallback) {
            Channel.messageNews.disconnect(lastRequestCallback);
        }
    }

    property string newsTemplateHead:
        ('<head>' +
         '<meta charset="UTF-8">' +
         '<title>资讯</title>' +
         '<style type="text/css">' +
         '*{ margin:0; padding:0;}' +
         'body { font-size:12px;font-family: Arial,Helvetica, Tahoma,"Microsoft YaHei", "微软雅黑", STXihei, "华文细黑", SimSun, "宋体", Heiti, "黑体", sans-serif;}' +
         'ul,li{list-style-type:none;}' +
         'img{border:0; vertical-align:bottom;}' +
         'i,span,em,cite,p,dl,dt,dd,span,b{ font-style:normal;}' +
         'h1,h2,h3,h4,h5,h6{font-size:100%;font-weight:400;}' +
         'q:before,q:after{content:"";}' +
         'input,textarea,select{font-family:inherit; font-weight:inherit; font-size:100%; border: 0;}' +
         'a{ text-decoration:none; cursor:pointer; bblr:expression(this.onFocus=this.blur()); outline-style:none;}' +
         'a:hover{ text-decoration:none;}' +
         'a:active {star:expression(this.onFocus=this.blur()); outline-style: none;}' +
         '.container{width: 100%;background: #fff}' +
         '.main{min-width: 600px; margin:0 auto;padding-top: 18px;overflow: hidden;}' +
         'article h2{line-height: 45px;font-size: 18px;text-align: center;color: #000}' +
         'article .info{color: #818181;font-size: 14px;height: 30px;line-height: 30px;width: 90%;margin:0 auto;text-align: center;margin-bottom: 10px;}' +
         'article .info time{float: left;width: 200px;text-align: left;}' +
         'article .info .fsz{width: 150px;float: right;}' +
         'article .info .fsz .mid{margin:0 10px 0 10px;}' +
         'article .info .fsz a:hover{color:#1677d3;}' +
         'article .info .fsz a.select{color:#1677d3;}' +
         'article #detail{font-size: 14px;line-height: 20px; margin:0 15px 0}' +
         '</style>' +
         '</head>')

    property string newsTemplateScript:
        ('<script type="text/javascript">' +
         'var big=document.getElementById("big");' +
         'var mid=document.getElementById("mid");' +
         'var small=document.getElementById("small");' +
         'var detail=document.getElementById("detail");' +
         'big.onclick=function(){' +
         'detail.style.fontSize="16px";' +
         'detail.style.lineHeight="22px";' +
         '};' +
         'mid.onclick=function(){' +
         'detail.style.fontSize="14px";' +
         'detail.style.lineHeight="20px";' +
         '};' +
         'small.onclick=function(){' +
         'detail.style.fontSize="12px";' +
         'detail.style.lineHeight="18px";' +
         '};' +
         '</script>')

    property string newsHtml:
        '<html>' +
        newsTemplateHead+
        '<body>' +
        '<div class="container">' +
        '<div class="main">' +
        '<article>' +
        '<h2>' + title + '</h2>' +
        '<div class="info">' +
        '<time>' + date + '</time>' +
        '<span>来源：' + source + '</span>' +
        '<div class="fsz">字号：<a id="big">大</a><a class="mid" id="mid">中</a><a id="small">小</a></div>' +
        '</div>' +
        '<div id="detail">' + content + '</div>' +
        '</article>' +
        '</div>' +
        '</div>' +
        '</body>' +
        newsTemplateScript +
        '</html>';

    onWebViewKeyEventTrigger:{
        root.visible = false;
    }
}
