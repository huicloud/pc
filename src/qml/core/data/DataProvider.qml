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

Item {

    id: dataProvider;

    // serviceUrl应该固定，初始赋值后不能修改
    property string serviceUrl;

    // 请求参数，修改后重新查询数据
    property var params;

    // 是否订阅标志，默认为0表示请求，设置为1表示订阅
    property int sub: 0;

    // 缓存级别，初始赋值后不能修改, 0-不缓存，1-内存缓存，2-本地持久化（每次数据更新后会调用storage方法，初始时会调用restore方法，根据storageKey方法得到的key值请求本地缓存数据还原数据然后触发data信号）
    property int cacheLevel: 0;

    // 自动查询，是否在组件创建后自动查询
    property bool autoQuery: true;

    // 查询延时时间，毫秒数，0表示不延时，延时查询在指定时间内的查询将合并在一次查询
    property int delayTime: 0;

    property bool isRequested: false;

    // 直接返回数据
    property bool direct: false

    property Storage localStorage;

    // 数据变化信号，请求或者订阅到数据时触发该信号
    signal success(var data, int counter);

    // 请求数据错误，可能是连接问题，也可能是数据错误
    signal error(var error);

    function query(callback) {
        if (dataProvider.delayTime === 0) {
            return directQuery(callback);
        } else {
            return delayQuery();
        }
    }

    function delayQuery() {
        if (!delayTimer.running) {
            delayTimer.start();
        }
    }

    Timer {
        id: delayTimer
        interval: dataProvider.delayTime
        onTriggered: {
            dataProvider.directQuery();
        }
    }

    // 开始请求数据方法，调用DataChannel去请求数据，当数据响应回来则触发data信号，当本身存在缓存数据时，请求缓存数据后直接触发信号
    function directQuery(callback) {

        // 注册信号处理，TODO 还需要考虑在哪里取消这个信号处理
        if (typeof callback === 'function') {
            success.connect(callback);
            error.connect(callback);
        }

        if (internal.cache) {
            dataProvider.success(internal.cache, 0);
        } else if (cacheLevel === 2) {
            dataProvider.restore();
        }

        if (!dataProvider.visible) {
            internal.pause = true;
            return;
        }

        if (!internal.request) {

            // 请求远程数据
            internal.request = DataChannel[(sub === 1 ? 'subscribe': 'query')](serviceUrl, params, function(data, qid, counter) {

                if (!(dataProvider && internal && internal.request && qid === String(internal.request.qid))) {
                    return;
                }

                if (data instanceof Error) {
                    dataProvider.error(data);
                } else {
                    var newData = dataProvider.adapt(data, internal.cache, counter);
                    if (cacheLevel !== 0) {
                        internal.cache = newData;
                    }
                    if (cacheLevel === 2) {
                        dataProvider.storage(newData);
                    }

                    dataProvider.success(newData, counter);
                }

                // 如果是请求数据，在得到数据后，将请求取消
                if (sub === 0) {
                    internal.request = null;
                }
            }, dataProvider.direct);
        }
    }

    function cancel() {
        if (internal.request) {
            internal.request.cancel();
            internal.request = null;
        }
    }

    // 处理数据，请求或者推送到的数据可能需要和之前的数据进行合并处理(第二个参数当cacheLevel=0时为空)
    function adapt(nextData, lastData) {
        return nextData;
    }

    // 监听请求参数变化，在已经查询数据状态下，取消之前的查询，再重新查询，没有查询过则不处理
    onParamsChanged: {
        if (dataProvider.autoQuery === true && dataProvider.visible) {
            dataProvider.cancel();
            dataProvider.query();
        }
    }

    onVisibleChanged: {

        // 从显示变成不显示时，暂停请求
        if (dataProvider.visible === false) {

            // 取消当前请求，并且设置暂停标记
            if (internal.request) {
                dataProvider.cancel();
                internal.pause = true;
            }
        } else {

            // 从不显示变成显示时，如果是暂停状态则重新查询
            if ((internal.pause === true || dataProvider.autoQuery) && !internal.request) {
                internal.pause = false;
                dataProvider.query();
            }
        }
    }

    Component.onCompleted: {
        if (dataProvider.autoQuery && dataProvider.visible) {
            dataProvider.query();
        }
    }

    Component.onDestruction: {
        dataProvider.cancel();
        internal.request = null;
    }

    function storageKey() {
        // TODO 根据serviceUrl和params生成指定的key
    }

    function storage(data) {
        // 根据storageKey生成的key将数据缓存到本地
        if (localStorage) {
            localStorage.setItem(storageKey(), data);
        }
    }

    function restore() {
        // 第一次请求数据时（cache不存在的情况下）根据storageKey生成的key将数据从本地缓存中恢复回来, 恢复后判断cache是否已经存在，不存在则还原数据后触发data信号
        if (localStorage && !internal.cache) {
            var data = localStorage.getItem(storageKey());
            internal.cache = data;
            dataProvider.success(data, 0);
        }
    }

    // 共通方法
    function arrayToObject(array, key) {
        if ((array instanceof Array) && typeof key === 'string') {
            var result = {};
            array.forEach(function(eachData) {
                result[eachData[key]] = eachData;
            });
            return result;
        }
        return array;
    }

    // 内部对象，缓存数据
    QtObject {

        id: internal;

        // 缓存数据
        property var cache;

        // 缓存的上次请求对象
        property var request;

        property bool pause: false
    }

    Binding {
        target: dataProvider;
        property: 'isRequested'
        value: !!internal.request
    }
}
