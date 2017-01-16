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
  * @brief  MaskLayer
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0

/**遮罩层，禁止操作下层的对象**/
Rectangle {
    color: 'lightgrey'
    opacity: 0
    z: 99
    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
    }

    function __getRoot(item) {
        return (item.parent !== null) ? __getRoot(item.parent) : item
    }

    Component.onCompleted: {
        this.parent = __getRoot(this)
        this.anchors.fill = parent
    }
}
