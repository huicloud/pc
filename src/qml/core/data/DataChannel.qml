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

import QtQuick 2.0;

// 导入C++中注册的连接模块
import Dzh.Data 1.0;

import "../../js/Util.js" as Util

// 数据连接，默认连接云平台，提供state状态属性，查询和订阅方法，取消订阅方法
Item {
    id: dataChannel;

//    readonly property int connecting: 0;
//    readonly property int open: 1;
//    readonly property int closing: 2;
//    readonly property int closed: 3;

    property int state: Channel.getState();

    property string dzhToken: ''

    signal open;
    signal close(string reason);
    signal error(int errorCode, string errorMessage);

    // 重连失败信号
    signal reconnectFail();

    // 重连上信号(断开后重新连接上会触发该信号)
    signal reconnect;

    function query(serviceUrl, params, callback, direct) {

        // 创建请求对象
        var qid = internal.getNextQid();
        var request = {
            serviceUrl: serviceUrl,
            requested: false,
            qid: qid,
            params: params,
            callback: callback,
            cancel: function() {
                dataChannel.cancel(qid);
            },
            direct: direct
        }

        internal.requests[qid] = request;

        // 打开状态直接请求
        if (dataChannel.state === Channel.Connected) {
            internal.send(request);
        }
        return request;
    }

    function subscribe(serviceUrl, params, callback, direct) {
        params = Util.assign({}, params);
        params.sub = 1;
        return dataChannel.query(serviceUrl, params, callback, direct);
    }

    function cancel(qid) {
        var request = internal.requests[qid];
        if (request && request.requested === true && dataChannel.state === Channel.Connected) {
            internal.send({
                 serviceUrl: '/cancel',
                 qid: qid
            });
        }
        delete internal.requests[qid];
    }

    // 主动连接服务器
    function openChannel() {
        Channel.startDataChannel();
    }

    // 主动中断连接服务器
    function closeChannel() {
        Channel.stopDataChannel();
    }


    QtObject {
        id: internal;
        property int qid: 0;

        property var requests: ({});

        function getNextQid() {
            return qid++;
        }

        function send(request) {
            var params = internal.formatParams(request.params);
            params.qid = request.qid;

            // 发送请求
            Channel.send(request.serviceUrl, params);
            request.requested = true;
        }

        // 格式化参数，将传人的params中value数据类型都转换为字符串类型（数组格式化为逗号分隔的字符串）
        function formatParams(params) {
            var result = {};
            if (params) {
                Object.keys(params).forEach(function(key) {
                    var value = params[key];
                    if (value instanceof Array) {
                        value = value.join(',');
                    }
                    if (value) {
                        result[key] = encodeURIComponent(value);
                    }
                });
            }
            return result;
        }

        function convertToJsonArray(input) {
            if (!input || !input.head) {
                return input;
            }

            var head = input.head;
            var data = input.data;

            return data.map(function(row) {
                var rowObject = {};
                row.forEach(function(cell, columnIndex) {
                    rowObject[head[columnIndex]] = internal.convertToJsonArray(cell);
                });
                return rowObject;
            });
        }

        function formatData(data) {
          if (data.JsonTbl) {
            data = internal.convertToJsonArray(data.JsonTbl)[0];
            return data[Object.keys(data)[0]];
          } else if (data.hasOwnProperty('Id')) {
            delete data.Id;
            delete data.Obj;
            return data[Object.keys(data)[0]];
          } else {
            return data;
          }
        }

        function eventRequest(doSomething, filter) {
            filter = typeof filter === 'function' ? filter : function() {return true};
            internal.requests.forEach(function(request) {
                if (filter(request)) {
                    doSomething(request);
                }
            });
        }
    }

    Connections {
        target: Channel

        onMessage: {

            // 接受到信息，根据接收到的数据的qid找到对应的请求，处理回调方法
            var qid = data.Qid;
            var err = data.Err;
            var counter = data.Counter
            var resultData = data.Data;
            var request = internal.requests[qid];
            if (request) {
                request.callback && request.callback((err === 0) ? (request.direct !== true ? internal.formatData(resultData) : data) : new Error(JSON.stringify(resultData)), qid, counter);
                if (request.params.sub !== 1) {
                  delete internal.requests[qid];
                }
            }
        }

        onOpen: {

            // 连接open
            var lastState = dataChannel.state;
            dataChannel.state = Channel.getState();
            dataChannel.open();

            // 之前的状态是断连则触发重连事件
            if (lastState === Channel.DisConnected) {
                dataChannel.reconnect();
            }

            // 将请求队列中为发送的请求发送出去
            Object.keys(internal.requests).forEach(function(key) {
                var request = internal.requests[key];
                if (!request.requested) {
                    internal.send(request);
                }
            });
        }

        onClose: {

            // 连接关闭
            dataChannel.state = Channel.getState();
            dataChannel.close('connect close');

            var requests = internal.requests;
            internal.requests = {};
            Object.keys(requests).forEach(function(key) {
                var request = requests[key];
                request.callback(new Error('connect close'));
            });
        }

        onError: {

            // 连接错误
            dataChannel.state = Channel.getState();
            dataChannel.error(0, 'connect error');

            var requests = internal.requests;
            internal.requests = {};
            Object.keys(requests).forEach(function(key) {
                var request = requests[key];
                request.callback(new Error('connect error'));
            });
        }

        onReconnectfail: {

            // 重连失败
            dataChannel.reconnectFail();
        }
    }

    Component { id: timerComponent; Timer {} }

    function setTimeout(callback, timeout) {
        var timer = timerComponent.createObject(parent);
        timer.interval = timeout || 1;
        timer.triggered.connect(function() {
            timer.destroy();
            callback();
        });
        timer.start();
        return timer;
    }
}
