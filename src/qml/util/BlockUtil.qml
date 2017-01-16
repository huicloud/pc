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

import "./"

/**
 * 板块相关共通方法
 */
Item {

    // 缓存板块编码和路径的对应关系
    readonly property var blockFullNameCache: ({
                                                   'SH000001': '股票/市场分类/上证AB股',
                                                   'SZ399001': '股票/市场分类/深证AB股',
                                                   'SZ399006': '股票/市场分类/创业板',

                                                   // market对应的板块名称
                                                   '60': '市场/沪深市场/沪深A股',
                                                   '61': '市场/沪深市场/上证A股',
                                                   '63': '市场/沪深市场/深证A股',
                                                   '67': '市场/沪深市场/创业板',
                                                   '69': '市场/沪深市场/中小板块',
                                                   'st': '市场/沪深市场/沪深ST',
                                                   'SH': '市场/沪深市场/上证A股',
                                                   'SZ': '市场/沪深市场/深证A股',
                                                   'SHINX': '市场/沪深市场/上证指数',
                                                   'SZINX': '市场/沪深市场/深证指数',


                                                   'ETFFund': '市场/基金/ETF基金无申购赎回',
                                                   'ClosedFund': '市场/基金/封闭基金',
                                                   'LofFund': '市场/基金/LOF基金',
                                                   'GradingFundA': '市场/基金/分级A',
                                                   'GradingFundB': '市场/基金/分级B',
                                                   'T0Fund': '市场/基金/T+0基金'
                                               })

    function getBlockName(obj, callback) {
        return StockUtil.getStockName(obj, callback);
    }

    function getBlockFullName(obj, callback) {
        var fullName = blockFullNameCache[obj];
        if (!fullName) {
            getBlockName(obj, function(name) {
                if (name) {
                    if (obj.substring(0, 2) === 'B$') {
                        var fullName = '股票/大智慧自定义/指数板块/' + name;
                        blockFullNameCache[obj] = fullName;
                        callback && callback(fullName);
                    } else {
                        // TODO 其它的板块规则不确定
                    }
                }
            });
        } else {
            callback && callback(fullName);
        }
        return fullName;
    }

    // 提供外部使用绑定板块名称的组件
    // BlockUtil.blockName.createObject(parent);
    property Component blockName: Component {
        Item {
            id: block

            // 默认绑定parent中的obj属性
            property string obj: parent[objProperty]
            property string objProperty: 'obj'
            property string name
            property string fullName

            onObjChanged: {
                name = '';
                fullName = '';
                getBlockName(obj, function(name) {
                    if (block) {
                        block.name = name;
                        getBlockFullName(obj, function(fullName) {
                            if (fullName) {
                                block.fullName = fullName;
                            }
                        });
                    }
                });
            }
        }
    }
}
