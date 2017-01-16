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

import QtQuick 2.5
import QtWebEngine 1.2

import "../core"
import "../util"
import "../controls"

ContextComponent {
    id: root
    property var obj: ""
    property var stock: StockUtil.stock.createObject(root);
    property string tag: "B1"
    focus: false
    property alias webView: webView
    property string hideCloseJs: 'var closeBtnDivs = document.getElementsByClassName("close_btn");' +
                                 'if(closeBtnDivs[0]){' +
                                 'closeBtnDivs[0].style.display="none"' +
                                 '}'

    property string redeclaredEscJs: 'document.onkeydown = function(e){' +
                                   'var ev = document.all ? window.event : e;' +
                                   'switch (ev.keyCode) {' +
                                   'case 27: self.location = "dzh://close"; break;}}';


    property string openPdfJs: 'window.external={};window.external.download=function(url){' +
                                   'url=url.replace(/#DZH2DATA#0#/g,"http://rdfile.gw.com.cn");' +
                                   'self.location.href=url;' +
                                '}'
    WebView{
        id: webView
        anchors.fill: parent
        activeFocusOnPress: false
        url: {
            var link = '';
            if (visible){
                if (stock.type === 1){
                    link = 'http://webf10.gw.com.cn/stockDefault.html?IsClient=1&stockCode=' + obj;
                }else if ([2, 10, 11].indexOf(stock.type) !== -1){
                    link = 'http://webf10.gw.com.cn/fundDefault.html?IsClient=1&stockCode=' + obj;
                }
            }
            return link;
        }

        onLoadStatusChanged: {
            if (loadStatus === WebEngineView.LoadSucceededStatus){
                /*JS 注入*/
                //屏蔽关闭按钮的显示
                if (webView.url.toString().indexOf('http://webf10.gw.com.cn/') >= 0){
                    webView.runJavaScript(hideCloseJs);
                    webView.runJavaScript(redeclaredEscJs);
                };

                //个股公告的特殊处理
                if (webView.url.toString().indexOf('B14.html') >= 0){
                    webView.runJavaScript(openPdfJs);
                }
            }
        }

        onWindowCloseRequested: {
               root.context.mainWindow.pressEsc();
        }
    }

    Connections {
        target: root.context.mainWindow
        onWebViewKeyEventTrigger:{
            if (visible) {
                root.context.mainWindow.pressEsc();
            }
        }
    }

    onFocusChanged: {
        webView.focus = root.focus;
    }
}
