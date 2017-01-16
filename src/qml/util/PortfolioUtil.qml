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

import "../core/data"
import "../core/common"

/**
 * 自选股共通方法
 */
Item {
    id: root

    // 同步远程的自选股列表
    property var remoteList: null

    // 本地的自选股列表
    property var localList: JSON.parse(portfolio.list) || []

    // 外部使用自选股
    property var list: remoteList || localList

    // 过滤掉不支持的市场的自选股列表（只保留SH和SZ市场还有B$板块的obj，再加上常用指数对应的obj）
    property var filterList: list.filter(function(eachStock) {
        var obj = eachStock.obj || '';
        var market = obj.substring(0, 2).toUpperCase();
        return ['SH', 'SZ', 'B$'].indexOf(market) >= 0 || ApplicationConfigure.requestObjsCyinx.indexOf(obj) >= 0
    })

    property var userName: UserService.currentUserInfo ? UserService.currentUserInfo.UserName : null

    // 本地存储自选股
    Settings {
        id: portfolio
        category: ['portfolio', UserService.userId].join('.')

        // 初始自选股
        property string list: '[{"obj":"SH000001"},{"obj":"SZ399001"},{"obj":"SZ399006"},{"obj":"SH601519"}]'
    }

    // dirty变成true时表示本地自选股有更新, 需要更新服务器上数据
    property bool dirty: false

    onDirtyChanged: {
        if (dirty === true) {

            // 更新服务器中的自选股
            DataChannel.query('/selfstocksync', {
                                  type: 105,
                                  action: 2,
                                  username: userName,
                                  objsdesc: 1,
                                  objs: localList.map(function(eachData) {
                                      return eachData.obj
                                  })
                              }, function(result) {
                                  if (result instanceof Error) {

                                      // 请求服务错误
                                      console.error('更新自选股失败');
                                      return;
                                  }

                                  var data = result[0];

                                  if (data.CaoZuoJieGuo !== 0) {
                                      console.error('更新自选股失败');
                                      return;
                                  }

                                  // 更新成功重新请求远程数据
                                  remoteList = null;
                              });

            dirty = false;
        }
    }

    onUserNameChanged: {

        // 用户变化时将远程列表删除
        remoteList = null;
    }

    DataProvider {
        serviceUrl: '/selfstocksync'
        params: {

            // 监听remoteList变化，null时请求远程自选股列表
            if (remoteList === null && UserService.currentUserInfo) {
                autoQuery = true;
                return {
                    type: 106,
                    username: userName
                };
            }
            autoQuery = false;
            return null;
        }
        onError: {
            console.error('获取自选股失败');
        }

        onSuccess: {
            data = data[0];

            if (data.CaoZuoJieGuo !== 0) {
                console.error('获取自选股失败');
                remoteList = null;
                return;
            }

            remoteList = (data.ZiXuanGuLieBiao || []).map(function(eachObj) { return {obj: eachObj.Obj.toUpperCase()} });

            // 记录到本地
            portfolio.list = JSON.stringify(remoteList);
        }
    }

    // 添加自选股（加到最前面）
    function add(stock) {
        if (stock && stock.obj) {

            // 先删除
            var newList = localList.filter(function(eachStock) {
                return eachStock.obj !== stock.obj;
            });
            saveList([stock].concat(newList));
        }
    }

    // 移出自选股
    function remove(stock) {
        if (stock) {
            var obj = (typeof stock === 'string' ? stock : stock.obj);
            saveList(localList.filter(function(eachStock) {
                return eachStock.obj !== obj;
            }));
        }
    }

    //移动位置
    function move(srcObj, destObj, isFront){
        if (srcObj && destObj){
            var srcStock = null;
            var newList = list.filter(function(eachStock){
                if (eachStock.obj === srcObj){
                    srcStock = eachStock; //记录要移动的股票
                    return false;
                }else{
                    return true;
                }
            })

            var destIndex = 0;    //定位目标股票所在索引
            for(var i =0; i < newList.length; i++){
                if(newList[i].obj === destObj){
                    destIndex = i;
                    break;
                }
            }

            if (isFront && destIndex === 0){
                destIndex = 0;
            }else{
                destIndex++;
            }

            if(srcStock){
                newList.splice(destIndex, 0, srcStock);
                saveList(newList);
            }
        }
    }

    // 得到自选股列表
    function getList() {
        return filterList;
    }

    property Timer lastTimer

    // 保存自选股列表（可用作排序）
    function saveList(list) {

        // 当用户不存在时不能修改自选股
        if (userName) {

            // 限制自选股不超过100条
            list = list.slice(0, 100);
            portfolio.list = JSON.stringify(list);

            if (lastTimer) {
                lastTimer.stop();
            }

            // 延时处理，保证同时修改多个自选股后才同步更新远程数据
            lastTimer= DataChannel.setTimeout(function() {
                dirty = true;
            });
        }
    }

    // 判断是否在自选股中
    function inPortfolios(obj) {
        return list.some(function(eachStock) {
            return eachStock.obj === obj;
        });
    }

    // 请求远程自选股列表（将remoteList设置为null会自动重新请求自选股）
    function requestRemoteList() {
        remoteList = null;
    }
}
