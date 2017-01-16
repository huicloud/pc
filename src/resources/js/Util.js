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

.pragma library
//.import './venders/lodash.js' as LoDash
//.import './venders/zlib.min.js' as ZlibUtil
//.import './venders/encoding-indexes.js' as EncodingIndexes
//.import './venders/encoding.js' as Encoding

/**
 * 通用js方法
 */

// 类似Object.assign方法
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign
function assign(target) {
    if (target == null) {
        throw new TypeError('Cannot convert undefined or null to object');
    }

    target = Object(target);
    for (var index = 1; index < arguments.length; index++) {
        var source = arguments[index];
        if (source != null) {
            for (var key in source) {
                if (Object.prototype.hasOwnProperty.call(source, key)) {
                    target[key] = source[key];
                }
            }
        }
    }
    return target;
}

function deepAssign(target) {
    if (target == null) {
        throw new TypeError('Cannot convert undefined or null to object');
    }

    target = Object(target);
    for (var index = 1; index < arguments.length; index++) {
        var source = arguments[index];
        if (source != null) {
            for (var key in source) {
                if (Object.prototype.hasOwnProperty.call(source, key)) {
                    var value = source[key];
                    if (typeof value === 'object') {
                        var targetValue = target[key];
                        if (!targetValue) {
                            targetValue = target[key] = new (value.constructor);
                        }
                        deepAssign(targetValue, value);
                    } else {
                        target[key] = source[key];
                    }
                }
            }
        }
    }
    return target;
}

var DEFAULT_VALUE = '--';

/**
 * 格式化文本，将输入的数字参数格式化为指定精度的字符串
 * @param {!number|string|null} data      需要格式化的数字，可以是数字，字符串或者null对象
 * @param {?number} precision             保留小数精度，null则默认取2位小数
 * @param {?''|'K'|'M'|'B'|'K/M'|'K/M/B'|'万'|'亿'|'万/亿'|'%'} unit    单位，按自定的单位格式化数据，null则为''为不加单位
 * @param {boolean|string=} useDefault    是否使用默认值，默认显示--，字符串类型表示需要显示的默认值
 * @param {boolean=} isAutoPrec    是否自动进行精度控制，true时 对于不到单位转换的情况时直接取整
 * @param {boolean=} isAbs    是否显示数字绝对值
 * @returns {string}
 */
function formatStockText(data, precision, unit, useDefault, isAutoPrec, isAbs) {
//    if (!data) {
//        data = 0;
//    }

    var n = Number(data);
    if (isNaN(n) && useDefault !== false) {
        return typeof useDefault === 'string' ? useDefault : DEFAULT_VALUE;
    }

    var abs = Math.abs(n), m = n;

    unit = unit || '';
    precision = precision != null ? precision : 2;

    if (unit.indexOf('B') >= 0 && abs >= 1000 * 1000 * 1000) {
        unit = 'B';
        n = n / (1000 * 1000 * 1000);
    } else if (unit.indexOf('亿') >= 0 && abs >= 10000 * 10000) {
        unit = '亿';
        n = n / (10000 * 10000);
    } else if (unit.indexOf('M') >= 0 && abs >= 1000 * 1000) {
        unit = 'M';
        n = n / (1000 * 1000);
    } else if (unit.indexOf('万') >= 0 && abs >= 10000) {
        unit = '万';
        n = n / 10000;
    } else if (unit.indexOf('K') >= 0 && abs >= 1000) {
        unit = 'K';
        n = n / 1000;
    } else if (unit === 100) {
        unit = '';
        n = n / 100;
    } else if (unit === '%') {
        n = n * 100;
    } else {
        unit = '';
    }

    if (n === m && isAutoPrec === true) {
        precision = 0;
    }
    if (isAbs) {
        n = Math.abs(n);
    }

    return n.toFixed(precision) + unit;
}

/**
 * 异步请求方法
 */
function ajaxGet(url, callback, responseBinary, header) {
    var xhr = new XMLHttpRequest();
    xhr.cancel = false;
    xhr.onreadystatechange = function() {

        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (!xhr.cancel) {
                if (xhr.status === 200) {
                    callback && callback(responseBinary === true ? xhr.response : xhr.responseText, xhr);
                } else {
                    callback && callback(new Error(xhr.statusText));
                }
            }
        }
    }
    xhr.open('GET', url);

    if (header) {
        for (var key in header) {
            xhr.setRequestHeader(key, header[key]);
        }
    }

    if (responseBinary === true) {
        xhr.responseType = 'arraybuffer'
    }
    xhr.send();
    return xhr;
}

function param(params) {
    if (typeof params === 'object') {
        return Object.keys(params).reduce(function(preValue, key) { return preValue + '&' + [key, encodeURIComponent(params[key])].join('=') }, '')
    }
    return params;
}

function param(params) {
    if (typeof params === 'object') {
        return Object.keys(params).reduce(function(preValue, key) { return preValue + '&' + [key, encodeURIComponent(params[key])].join('=') }, '')
    }
    return params;
}

function paramNoURI(params) {
    if (typeof params === 'object') {
        return Object.keys(params).reduce(function(preValue, key) { return preValue + '&' + [key, params[key]].join('=') }, '')
    }
    return params;
}
