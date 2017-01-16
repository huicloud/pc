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
//用户行为统计组件
import QtQuick 2.0

Item {
    id: root
    readonly property string title: Qt.platform.os === 'osx' ? '大智慧舵手版_Mac' : '大智慧舵手版_Win'
    readonly property string environment: Qt.platform.os === 'osx' ? 'Macintosh; Intel Mac OS X 10_10' : 'Windows NT 6.2; WOW64'

    //自选(一级)——27、沪深(一级) ——28、选股(一级) ——29、资讯(一级) ——30、交易(一级) ——31、反馈(一级) ——32、
    //关于(一级) ——33、自选股(二级) ——34、最近浏览(二级) ——35、沪深A股(二级) ——36、热门板块(二级) ——37、
    //上证指数(二级) ——38、深证指数(二级) ——39

    readonly property int ziXuanTag: 27
    readonly property int huSHenTag: 28
    readonly property int xuanGuTag: 29
    readonly property int ziXunTag: 30
    readonly property int jiaoYiTag: 31
    readonly property int fanKuiTag: 32
    readonly property int guanYuTag: 33
    readonly property int ziXuanGuTag: 34
    readonly property int zuiJinLiuLanTag: 35
    readonly property int huShenAGuTag: 36
    readonly property int reMenBanKuaiTag: 37
    readonly property int shangZhengZhiShuTag: 38
    readonly property int shenZhengZhiShuTag: 39
    readonly property int jianPanBaoTag: 40
    readonly property int urlTag: 42
    readonly property int duanXianJingLingTag: 43

    //记录产品定义的行为
    function sendUserBehavior(behaviorTag, action){
        var http = new XMLHttpRequest()
        var actionName = action ? root.title + '_' + action :  root.title;
        var url = 'http://pcpiwik.gw.com.cn/piwik/piwik.php?action_name=' + actionName + '&idsite=' + behaviorTag + '&rec=1&url=http://www.gw.com.cn&_idn=0&_refts=0&send_image=0';
        http.open("GET", url, true);
        http.setRequestHeader("Accept-Language","zh-CN,zh;q=0.8,en;q=0.6");
        http.setRequestHeader("Accept-Encoding", "gzip,deflate,sdch");
        http.setRequestHeader("Referer", "http://www.gw.com.cn/");
        http.setRequestHeader("User-Agent", "Mozilla/5.0 (" + root.environment + ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36");
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Connection", "close");
        /** 不需要接收响应
                http.onreadystatechange = function() {
                    if (http.readyState ==  XMLHttpRequest.DONE) {
                        if (http.status == 200) {
                            console.log("ok")
                        } else {
                            console.log("error: " + http.status)
                        }
                    }
                }
                */
        http.send(null);
    }

    //记录原始链接信息
    function sendUserBehaviorUrl(behaviorUrl){
        var http = new XMLHttpRequest();
        var url = 'http://pcpiwik.gw.com.cn/piwik/piwik.php?action_name=' + root.title + '&idsite=' + root.urlTag + '&rec=1&url=http://www.gw.com.cn/'+ behaviorUrl +'&_idn=0&_refts=0&send_image=0';
        http.open("GET", url, true);
        http.setRequestHeader("Accept-Language","zh-CN,zh;q=0.8,en;q=0.6");
        http.setRequestHeader("Accept-Encoding", "gzip,deflate,sdch");
        http.setRequestHeader("Referer", "http://www.gw.com.cn/");
        http.setRequestHeader("User-Agent", "Mozilla/5.0 (" + root.environment + ") AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36");
        http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http.setRequestHeader("Connection", "close");
        http.send(null);
    }

}
