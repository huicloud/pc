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

.pragma library

var Qids = {}


function newQid(baseName) {
    var sn = 0;
    if (baseName in Qids) {
        sn = Qids[baseName];
        Qids[baseName] = sn + 1;
    }else {
        Qids[baseName] = sn;
    }
    return baseName + "_" + sn;
}

var DefaultPaintStyle = {
    bgColor         : "#FFFFFF"       ,
    borderColor     : "#808080"       ,
    borderLineWidth : 1               ,
    gridLineColor   : "#D0D0D0"       ,
    gridLineWidth   : 1               ,
    gridFont        : "normal normal 24px Helvetica" ,
    gridFontColor   : "#000000"       ,
    riseColor       : "#DC143C"       ,
    dropColor       : "#006400"       ,
    kLineWidth      : 2               ,
    lineColors      : ["#00008B", "#008B8B", "#B8860B", "#A9A9A9", "#006400", "#BDB76B", "#8B008B", "#556B2F", "#FF8C00", "#9932CC", "#8B0000", "#E9967A", "#8FBC8F", "#483D8B", "#2F4F4F", "#00CED1", "#9400D3"],
    leftRulerWidth  : 80              ,
    rightRulerWidth : 0              ,
    countRatio      : 0.95            ,
    spaceRatio      : 0.2
};

/*判断对象是否为空*/
function isEmptyObject(o) {
    var t;
    for (t in o)
        return !1;
    return !0
}
