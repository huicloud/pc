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

pragma Singleton
import QtQuick 2.0
import Qt.labs.settings 1.0

/**
 * 最近查看股票历史共通方法(保存最近100条数据)
 */
Item {
    id: root

    property var list: JSON.parse(history.list);

    Settings {
        id: history
        category: 'history'
        property string list: '[]'
    }

    // 添加到查看历史（加到最前面）
    function add(stock) {
        if (stock && stock.obj) {

            // 先删除
            var newList = list.filter(function(eachStock) {
                return eachStock.obj !== stock.obj;
            });
            saveList([stock].concat(newList));
        }
    }

    // 移出查看历史
    function remove(stock) {
        if (stock) {
            var obj = (typeof stock === 'string' ? stock : stock.obj);
            saveList(list.filter(function(eachStock) {
                return eachStock.obj !== obj;
            }));
        }
    }

    // 得到查看历史列表
    function getList() {
        return list;
    }

    // 保存查看历史列表
    function saveList(list) {
        history.list = JSON.stringify(list.slice(0, 100));
    }
}
