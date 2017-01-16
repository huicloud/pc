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


//WorkerScript.onMessage = function(msgObject) {
//    WorkerScript.sendMessage(handleData(msgObject));
//}

.import './Util.js' as Util

function handleData(msgObject) {
    var columns = msgObject.columns;
    var currentData = msgObject.currentData;
    var lastData = msgObject.lastData;
    var idField = msgObject.idField;

    var lastMap = {};
    lastData.forEach(function(eachData) {
        lastMap[eachData[idField]] = eachData;
    });

    var result = currentData.map(function(eachData, rowIndex) {
        var id = eachData[idField];

        // 如果数据中存在_last字段则使用这个字段的值作为上次的数据
        var lastData = eachData._last || lastMap[id] || {};

        return formatData(eachData, lastData, columns, rowIndex);
    });

    return result;
}

function formatData(data, lastData, columns, rowIndex) {
    var volumeUnit = data._volumeUnit || data['ChengJiaoLiangDanWei'] || 100;
    var result = Util.assign({}, data);
    result._volumeUnit = volumeUnit;

    lastData = lastData || {};
    var lastVolumeUnit = lastData._volumeUnit;
    var formatStockText = Util.formatStockText;
    columns.forEach(function(eachColumn, columnIndex) {
        var field = eachColumn.field;
        var currentValue = data[field];
        result[field] = currentValue;

        var lastPosition, currentPosition;
        if (rowIndex != null) {
            lastPosition = lastData[field + '_position'];
            currentPosition = result[field + '_position'] = [rowIndex, columnIndex].join('_');
        }

        var lastValue = lastData[field] || undefined;
        result[field + '_last'] = lastValue;
        if (typeof currentValue === 'number') {

            // 对于量相关字段
            if (currentValue === lastValue && lastData[field + '_format'] &&(!eachColumn.isVolume || lastVolumeUnit === volumeUnit)) {
                result[field + '_format'] = lastData[field + '_format'];
                result[field + '_updown'] = lastData[field + '_updown'];

                // 如果位置保持一致则高亮状态保持
                if (lastPosition === currentPosition) {
                    result[field + '_highlight'] = lastData[field + '_highlight'];
                }
            } else {

                // 格式化
                currentValue = currentValue * (eachColumn.ratio || 1);
                if (eachColumn.isVolume) {
                    currentValue = currentValue / volumeUnit;
                }

                // 没有指定精度时使用数据中的XiaoShuWei字段(默认2位)
                var precision = eachColumn.precision >= 0 ? eachColumn.precision : ((!eachColumn.isAutoPrec && data.XiaoShuWei) || 2);

                result[field + '_format'] = formatStockText(currentValue, precision, eachColumn.unit, eachColumn.useDefault, eachColumn.isAutoPrec, eachColumn.isAbs);

                // 判断涨跌
                if (eachColumn.updownStyle) {
                    var relateField = eachColumn.relateField;
                    var compareField = eachColumn.compareField;
                    var compareValue
                    if (relateField) {
                        var relateValue = data[relateField];
                        compareValue = compareField === 'last' ? lastData[relateField] : currentData[compareField] || 0;
                        result[field + '_updown'] = relateValue > compareValue ? 1 : relateValue < compareValue ? -1 : 0;
                    } else {
                        compareValue = compareField === 'last' ? lastData[field] : data[compareField] || 0;
                        result[field + '_updown'] = currentValue > compareValue ? 1 : currentValue < compareValue ? -1 : 0;
                    }
                }

                // 判断高亮
                if (lastValue !== undefined) {
                    if (eachColumn.highlightPolicy === 'updown') {
                        result[field + '_highlight'] = currentValue > lastValue ? 1 : currentValue < lastValue ? -1 : 0;
                    } else if (eachColumn.highlightPolicy === 'change') {
                        result[field + '_highlight'] = currentValue !== lastValue ? 1 : 0;
                    }
                }
            }
        }
    });
    return result;
}
