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

import "../core"
import "../controls"
import "../components"

BasePage {
    title: '消息中心'


    Column{
      anchors.fill: parent
      Repeater{
        model: 10
        Text {
            text: index===0 ? '当前版本号：' + AppLauncher.getApplicationVersion() :(index) + "、你有一条新的消息未读!"
            color: Qt.darker("gray", 1.3)
        }
      }
    }
}
