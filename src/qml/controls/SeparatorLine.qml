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
  * @brief  SeparatorLine分割线
  * @author dongwei
  * @date   2016
  */

import QtQuick 2.0
import "../core"

Rectangle {
    id: separator
    property var theme: ThemeManager.currentTheme
    property int orientation: Qt.Vertical
    property int length: 100
    property int separatorWidth: 1
    color: theme.borderColor

    onOrientationChanged: __adjust()
    onLengthChanged: __adjust()
    onSeparatorWidthChanged: __adjust()

    function __adjust() {
        switch (orientation) {
        case Qt.Vertical:
            //垂直线
            height = length
            width = separatorWidth
            break
        case Qt.Horizontal:
            //水平线
            width = length
            height = separatorWidth
            break
        default:
            height = length
            width = separatorWidth
            break
        }
    }
    Component.onCompleted: __adjust()
}
