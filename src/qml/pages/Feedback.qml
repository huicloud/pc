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

import "../core"
import "../core/data"
import "../controls"
import "../components"
import "../util"


BasePage {
    id: root
    title:'反馈'
    focus: false
//    clip:true
//    Image{
//        mipmap:true
//        anchors.centerIn: parent
//        source: '/dzh/images/feedback.png'
//    }

//    onAfterActive:{
//        UBAUtil.sendUserBehavior(UBAUtil.fanKuiTag)
//    }
    objectName: 'WebEngine'
    property alias webView: webView
    property string __defaultUrl: 'http://t.gw.com.cn/user/otherHome/56e222ffe4b05afe1c69595a' + '?client=9&dataType=html&token=' + UserService.dzhToken

    WebView{
        id: webView
        anchors.fill: parent
        activeFocusOnPress: true
        url: __defaultUrl
    }

    Connections{
        target: root.context.mainWindow
        onWebViewKeyEventTrigger:{
            if (visible)
                root.context.mainWindow.pressEsc()
        }
    }

    onAfterActive: {
       // if (webView.url != __defaultUrl){
            webView.url = __defaultUrl
       // }
    }
}
