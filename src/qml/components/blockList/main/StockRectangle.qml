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
import "../../../controls"

Rectangle{
    id: root

    property double zhangdie: 0
    property double zuixinjia: 0
    property alias labelText: label.text
    property int row: 0
    property int column: 0
    property int chengfenguhead: 0
    property int changeField: 0

    Text {
        id : label
        anchors.fill: parent
        anchors.rightMargin: 0
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        color: {
            var c = theme.stockTableFontDefaultColor;
            if (changeField === 1){
                return "#FFFFE0"
            }

            if ([4,5,6,26].indexOf(column)>=0) {
                if (zhangdie>0) {
                    c = theme.redColor
                }
                if (zhangdie<0) {
                    c = theme.greenColor
                }
            } else if ([7,8,10,25].indexOf(column)>=0) {
                c = theme.blueColor;
            } else if ([17,18,29,30].indexOf(column)>=0) {
                c = theme.orangeColor;
            } else if ([22].indexOf(column)>=0) {
                c = theme.greenColor;
            } else if ([23].indexOf(column)>=0) {
                c = theme.redColor;
            }

            return c;
        }
        states: [

            State {
                name: "center"
                when: [0,1,2,3].indexOf(column)>=0 || row === 0
                PropertyChanges {target: label; horizontalAlignment: Text.AlignHCenter}
            },
            State {
                name: "tingpai"
                when: zuixinjia===0 && column !==3
                PropertyChanges {target: label; text: "--"}
            },
            State {
                name: "head"
                when: chengfenguhead===1
                PropertyChanges {target: label; color : "red"; horizontalAlignment: Text.AlignRight}
            }
        ]

    }

}
