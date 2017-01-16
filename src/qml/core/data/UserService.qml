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
import Dzh.Data 1.0;
import Dzh.AppLauncher 1.0

import "./"
import "../../js/Util.js" as Util

// 用户相关服务，包括登录，登出，得到当前用户信息等
Item {
    id: root

    property var currentUserInfo
    property var userName: currentUserInfo ? currentUserInfo.UserName : null
    property var dzhToken: currentUserInfo ? currentUserInfo.DzhToken : null
    property var extra: currentUserInfo ? JSON.parse(currentUserInfo.Extra) : null
    property string userId: currentUserInfo ? currentUserInfo.UserTid : ''

    // 根据extra判断（权限位PZ9为3表示有level2权限，沪深市场的权限）
    property bool isLevel2: extra ? parseInt(extra.PZ9) & 3 === 3 : false

    property string dzhyunAddress: 'http://' + Channel.getHost()

    function login(userName, password, isMd5, callback) {
        /*
           此处为定制的登录接口 参数可以有
           uname: userName,
           upass: isMd5 ? password : Qt.md5(password),
           computerid: Channel.getMachineId(),
           token: Channel.getToken(),
           // 产品和版本信息
           productid: AppLauncher.getProductId(),
           productversion: AppLauncher.getApplicationVersion()
        */

        var url = 'https://i.gw.com.cn/UserCenter/page/account/login'; //此处为模拟的地址，需要改成指定的登录接口 TODO 账号
        Util.ajaxGet(url, function(data) {
            if (data instanceof Error) {
                callback(new Error('登录服务器失败'));
            }else{
                //模拟返回的数据 解析为对应的js对象
                data = {
                    "Err": 0,
                    "Result": 0,
                    "Msg": "登录成功",
                    "UserName": "simulation",
                    "UserTid": "666888",
                    "UserMarket": "616514501",
                    "Extra": "{\"PZ9\":\"3\"}",
                    "Result": 0
                };

                if (data.Err === 0) {
                    // 登录成功记录登录用户信息
                    if (data.Result === 0) {
                        currentUserInfo = data;
                        currentUserInfo.Extra = JSON.parse(currentUserInfo.Extra);

                        callback(currentUserInfo);
                    } else {
                        // 登录失败
                        callback(new Error(data.Msg));
                    }
                } else {
                    // 服务器错误
                    callback(new Error((data.Data && data.Data.desc) || '服务器异常'));
                }
            }
        });

    }

    function logout(callback) {
        if (currentUserInfo) {
            var url = dzhyunAddress + getUrl('/usr/crm', {
                                                 cmd: 'logout',
                                                 dzhtoken: currentUserInfo.DzhToken,
                                                 token: Channel.getToken()
                                             });
            console.debug('logout url', url);

            // 登出给服务器发登出请求后直接中断连接，做登出成功处理
            Util.ajaxGet(url/*, function(data) {
                data = JSON.parse(data);
                if (data.Err === 0) {
                    data = data.Data.RepDataUserLogout[0];

                    // 登出成功
                    if (data.Result === 0) {

                        // 连接中断
                        DataChannel.closeChannel();
                        currentUserInfo = null;
                        callback && callback();
                    } else {

                        // 登出失败
                        callback && callback(new Error(data.Msg));
                    }
                } else {

                    // 服务器错误
                    callback && callback(new Error((data.Data && data.Data.desc) || '服务器异常'));
                }
            }*/);

            DataChannel.closeChannel();
            currentUserInfo = null;
            callback && callback();
        }
    }

    // 订阅被踢消息
    function subscribeKickoff(callback) {

        // 订阅 /sysmsg/iskickoff?dzhtoken=XXXXX，如果得到踢人推送时触发callback（由主窗体订阅后处理被踢后退出操作）
        DataChannel.subscribe('/sysmsg/iskickoff', {}, function(result) {
            if (!(result instanceof Error)) {
                var data = JSON.parse(result[0].ShuJu);

                // 被踢
                if (data.result === 1) {

                    // 连接中断
                    DataChannel.closeChannel();
                    currentUserInfo = null;
                    callback();
                }
            }
        });
    }

    function getUrl(url, params) {
        return [url, Util.param(params)].join('?');
    }
}
