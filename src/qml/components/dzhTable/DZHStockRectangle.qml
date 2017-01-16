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
import "../../controls"

Rectangle{
    id: root

    property double zhangdie: 0
    property double zuixinjia: 0
    property var labelText
    property string role: ""

/*
  column
{
 0: "XuHao", 1: "Obj", 2: "ZhongWenJianCheng", 3: "ZuiXinJia", 4: "ZhangDie",
 5: "ZhangFu", 6: "ChengJiaoLiang", 7: "HuanShou", 8: "XianShou", 9: "ChengJiaoE",
 10: "FenZhongZhangFu5", 11: "ZuoShou", 12: "KaiPanJia", 13: "ZuiGaoJia", 14: "ZuiDiJia",
 15: "HangYe", 16: "ShiYingLv", 17: "ShiJingLv", 18: "ShiXiaoLv", 19: "WeiTuoMaiRuJia1",
 20: "WeiTuoMaiChuJia1", 21: "NeiPan", 22: "WaiPan", 23: "ZhenFu", 24: "LiangBi",
 25: "JunJia", 26: "WeiBi", 27: "WeiCha", 28: "ZongChengJiaoBiShu",
 29: "ChengJiaoFangXiang", 30: "ZongShiZhi", 31: "LiuTongShiZhi"
}
*/

    property var roleStyle: {
        "ZuiXinJia": "upDown",
        "ZhangDie": "upDown",
        "ZhangFu": "upDown",
        "JunJia": "upDown",

        "ChengJiaoLiang": "blue",
        "HuanShou": "blue",
        "ChengJiaoE": "blue",
        "LiangBi": "blue",

        "ShiYingLv": "orange",
        "ShiJingLv": "orange",
        "ZongShiZhi": "orange",
        "LiuTongShiZhi": "orange",

        "NeiPan": "green",

        "WaiPan": "red"

    }

    function getColor(colorClass) {
        var c = theme.stockTableFontDefaultColor;

        switch(colorClass) {
        case "upDown":
            if (zhangdie>0) c = theme.redColor
            if (zhangdie<0) c = theme.greenColor
            break;

        case "blue": c = theme.blueColor; break;
        case "orange": c = theme.orangeColor; break;
        case "green": c = theme.greenColor; break;
        case "red":  c = theme.redColor; break;

        }

        return c;
    }

    Text {
        id : label
        anchors.fill: parent
        anchors.rightMargin: 5
        horizontalAlignment: ["XuHao","ZhongWenJianCheng","ZuiXinJia"].indexOf(role)>=0 ? Text.AlignHCenter : Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        color: getColor(roleStyle[role])
        text: {
            return (["ZuiXinJia","ZhangDie","ZhangFu"].indexOf(role)>=0 && zuixinjia===0) ? "--" : labelText;
        }


    }

}
