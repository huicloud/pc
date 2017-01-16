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

import "../core/data"

/**
 * 股票相关共通方法
 */
Item {
    id: root

    // 缓存股票(需要考虑更新机制)
    readonly property var stockCache: ({})
    property var _objs: []
    property var request

    function getStockName(obj, callback) {
        var name;
        getStock(obj, function(stock) {
            if (stock && stock.hasOwnProperty('ZhongWenJianCheng')) {
                name = stock.ZhongWenJianCheng;
                callback && callback(name);
            }
        });
        return name;
    }

    function getStockType(obj, callback) {
        var type;
        getStock(obj, function(stock) {
            if (stock && stock.hasOwnProperty('LeiXing')) {
                type = stock.LeiXing;
                callback && callback(type);
            }
        });
        return type;  //0、指数 板块等 1、股票 2、封闭基金 10、基金 11、LOF基金，分级基金A/B
    }

    function getStock(obj, callback) {
        var stock = stockCache[obj];
        if (stock) {
            callback && callback(stock);
            return stock;
        } else if (obj && obj !== '' && obj !== 'CYINX' && obj !== 'B$') {

            // 记录所有需要查询的obj，一起查询
            if (!request) {
                request = requestStock.createObject(root);
            }

            // 避免请求重复的code
            if (_objs.indexOf(obj) < 0) {
                _objs.push(obj);
            }

            request.dataProvider.success.connect(function() {

                // 查询成功
                var stock = stockCache[obj];
                callback && callback(stock);
            });
        }
    }

    Component {
        id: requestStock
        Timer {
            id: timer
            property DataProvider dataProvider: DataProvider {
                serviceUrl: '/stkdata'
                params: ({
                    obj: _objs,
                    field: 'ZhongWenJianCheng,LeiXing,RongZiRongQuanBiaoJi,ChengJiaoLiangDanWei,LiuTongAGu,XiaoShuWei,ZuoShou'
                })
                autoQuery: false
                onSuccess: {
                    data.forEach(function(eachData) {
                        stockCache[eachData.Obj] = eachData;
                    });

                    // 1秒后本身销毁
                    timer.destroy(1000);
                }
            }
            interval: 0
            running: true
            onTriggered: {
                if (_objs.length > 0) {

                    // 查询后清除之前的查询信息
                    dataProvider.query();
                    _objs = [];
                    request = null;
                }
            }
        }
    }

    // 提供外部使用绑定股票名称的组件
    // StockUtil.stock.createObject(parent);
    property Component stock: Component {
        Item {
            id: _stock

            // 默认绑定parent中的obj属性
            property string obj: parent[objProperty]
            property string objProperty: 'obj'
            property string code: obj.substring(2)
            property string prefix: obj.substring(0, 2)
            property string name: '--'
            property int type: -1
            property bool financing: false
            property int volumeUnit: 100
            property int precision: 2

            // 流通股本
            property real share: 0

            // 昨收
            property real lastClose: 0

            // 根据type判断是否是基金（type=11）
            property bool isFund: [2, 10, 11, 17, 18, 19, 20, 21, 22, 23, 24].indexOf(type) >= 0

            onObjChanged: {
                if (obj) {
                    getStock(obj, function(stock) {
                        if (_stock) {
                            _stock.name = stock.ZhongWenJianCheng;
                            _stock.type = stock.LeiXing;
                            _stock.financing = stock.RongZiRongQuanBiaoJi === 1 ? true : false;
                            _stock.volumeUnit = stock.ChengJiaoLiangDanWei || 1;
                            _stock.share = stock.LiuTongAGu * 10000 || 0;
                            _stock.precision = stock.XiaoShuWei || 2;
                            _stock.lastClose = stock.ZuoShou || 0;
                        }
                    });
                }
            }
        }
    }
}
