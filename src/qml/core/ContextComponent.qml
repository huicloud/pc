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

import "./"
import "../util"
import "../js/Util.js" as Util

/**
 * 带着应用上下文的组件
 */
BaseComponent {
    id: root

    property var context: ApplicationContext

    // 断连和重连信号
    signal disconnect
    signal reconnect
    //底层连接打开信号（断线重连成功后也会触发）
    signal open

    Component.onCompleted: {
        context.dataChannel.close.connect(root.disconnect);
        context.dataChannel.error.connect(root.disconnect);
        context.dataChannel.reconnect.connect(root.reconnect);
        context.dataChannel.open.connect(root.open);
    }

    property var portfolioContextMenuItem: ({
                                                obj: '',
                                                text: function(item) { return PortfolioUtil.inPortfolios(item.obj) ? '删除自选股' : '添加自选股' },
                                                triggered: function(item) {
                                                    if (PortfolioUtil.inPortfolios(item.obj)) {
                                                        PortfolioUtil.remove({obj: item.obj});
                                                    } else {
                                                        PortfolioUtil.add({obj: item.obj});
                                                    }
                                                }
                                            })
    property var f10ContextMenuItem: ({
                                          obj: '',
                                          text: 'F10基本资料',
                                          triggered: function(item) {
                                              context.pageNavigator.push(appConfig.routePathStockDetail, {'chart':'f10', 'obj':item.obj});
                                          },
                                          visible: function(item) { return [1, 2, 10, 11].indexOf(StockUtil.getStockType(item.obj)) !== -1 }
                                      })

    function createMenuItem(menuItem, props) {
        return Util.assign({}, menuItem, props);
    }
}
