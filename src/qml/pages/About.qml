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

import '../controls'
import '../core'
import '../core/common'
import '../core/data'
import '../util'

Dialog {
    id: root
    showButton: false
    confirmType: 2
    miniTitlebar: true
    width: 400
    height: 260
    contentMargin: 20
    title: '关于' + AppLauncher.getApplicationName()
    customItem: Column{
        anchors.fill: parent
        spacing: 16
        clip: true
        Rectangle{
            id: logo
            width: parent.width
            height: 37
            Image{
                id: miniLogo
                width: 42
                height: parent.height
                source: '/dzh/images/minilogo.png'
            }

            Text{
                anchors.left: miniLogo.right
                anchors.leftMargin: 5
                height: parent.height
                font.pixelSize: 18
                text: AppLauncher.getApplicationName() + 'V' + AppLauncher.getApplicationVersion()
            }
        }

        Text{
            text: AppLauncher.getApplicationCopyright()
        }

        Text{
            text:'网址：<a href=\"http://'+ AppLauncher.getApplicationWebSite() + '\">' +
                 AppLauncher.getApplicationWebSite() + '</a>'
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }

        Text{
            text:'用户ID：' + (UserService.userName ? UserService.userName : '游客')
        }

        Text{
            width: parent.width
            wrapMode: Text.Wrap
            text: '本软件受版权法的保护，未经授权不得擅自复制或传播本软件的全部或部分内容，否则将受到法律制裁'
        }

    }

    onVisibleChanged: {
        if (root.visible){
            UBAUtil.sendUserBehavior(UBAUtil.guanYuTag) //记录用户行为
        }
    }


}
