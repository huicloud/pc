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
import "../core/data"
import "../util"

Item {
    id: root

    property var model: []

    property string obj     //默认选中的股票
    property bool desc: true       //默认按正序
    property string orderBy: "ZhangFu"
    property string market
    property int type

    property var blockName: {
        if (type === 4) {
            return null;
        } else if (type === 0 || type === 5 || type === 6) {
            return BlockUtil.getBlockFullName(market);
        }
    }

    property var dpParam: {
        var param = {mode: 2, field: "ZhongWenJianCheng", desc: desc, orderBy: orderBy};

        if (blockName === null) {
            param.market = "B$";
        } else {
            param.gql = "block=" + blockName;
        }
        return param
    }

    DataProvider {
        id: dp
        parent: root
        serviceUrl: "/stkdata"
        params: dpParam
        sub: 0;

        onSuccess: {
            root.model = data;
        }
    }

}
