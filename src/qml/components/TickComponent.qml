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
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import "../core"
import "../core/data"
import "../controls"
import "../util"
import "../js/DateUtil.js" as DateUtil

/**
 * 分笔数据组件
 * TODO 考虑缓存问题
 */
ContextComponent {
    id: root
    property string obj
    property var tickData: []
    property bool hasMoreData: true

    property var stock: StockUtil.stock.createObject(root)

    // 昨收价
    property real lastClose: 0

    // 股票每笔单位股数
    property int stockCountUnit: stock.volumeUnit

    // 用作请求更多数据
    property DataProvider requestDataProvider: DataProvider {
        serviceUrl: '/quote/tick'
        params: ({
            obj: root.obj,
            count: 100,
//            start: -(tickData.length + 100)
        })
        autoQuery: false
        function adapt(nextData) {
            return nextData[0].Data;
        }

        onSuccess: {

            // 合并数据
            var lastLength = tickData.length;
            var lastTime = tickData[0].ShiJian;
            var eachData;
            for (var i = data.length - 1; i >= 0; i--) {
                eachData = data[i];
                if (eachData.ShiJian < lastTime) {
                    tickData.unshift(eachData);
                } else {

                    // 请求到重复时间数据表示不再有更多数据
                    hasMoreData = false;
                }
            }

            tickData = tickData.concat([]);
            var yPosition = (showStartIndex + (tickData.length - lastLength)) / tickData.length;
            flicker.contentY = yPosition * flicker.contentHeight;
        }
    }

    property var lastData: ({})

    // 用作订阅最新数据
    property DataProvider subscribeDataProvider: DataProvider {
        parent: root
        serviceUrl: '/quote/tick'
        params: ({
            obj: root.obj,
            start: -100
        })
        sub: 1

        function adapt(nextData) {
            return nextData[0].Data;
        }

        onSuccess: {


//            if (data.length >= 100) {
//                lastData = data.shift();
//            }

            // 追加最新的数据
            tickData = counter > 1 ? tickData.concat(data) : data;

//            // 第一次追加数据后如果数据条数小于请求的100，则表示没有更多数据
//            if (tickData.length < 100) {
//                hasMoreData = false;
//            }
        }
    }

    // 清理方法，还原初始值，取消当前请求
    function clear() {
        tickData = [];
        hasMoreData = true;
        requestDataProvider.cancel();
        selectedTime = 0;
    }

    onObjChanged: {
        clear();
        flicker.state = 'autoscroll';
    }

    property color tickLabelColor: theme.tickLabelColor
    property int tickLabelFontSize: theme.tickLabelFontSize
    property int tickLabelFontWeight: theme.tickLabelFontWeight
    property string tickLabelFontFamily: theme.tickLabelFontFamily
    property int tickLabelPreferredWidth: theme.tickLabelPreferredWidth

    property color tickPriceColor: theme.tickPriceColor
    property color tickPriceUpColor: theme.tickPriceUpColor
    property color tickPriceDownColor: theme.tickPriceDownColor
    property int tickPriceFontSize: theme.tickPriceFontSize
    property int tickPriceFontWeight: theme.tickPriceFontWeight
    property string tickPriceFontFamily: theme.tickPriceFontFamily
    property int tickPricePreferredWidth: theme.tickPricePreferredWidth

    property color tickVolumeColor: theme.tickVolumeColor
    property color tickVolumeUpColor: theme.tickVolumeUpColor
    property color tickVolumeDownColor: theme.tickVolumeDownColor
    property int tickVolumeFontSize: theme.tickVolumeFontSize
    property int tickVolumeFontWeight: theme.tickVolumeFontWeight
    property string tickVolumeFontFamily: theme.tickVolumeFontFamily
    property int tickVolumePreferredWidth: theme.tickVolumePreferredWidth

    property color tickChangeColor: theme.tickChangeColor
    property int tickChangeFontSize: theme.tickChangeFontSize
    property int tickChangeFontWeight: theme.tickChangeFontWeight
    property string tickChangeFontFamily: theme.tickChangeFontFamily
    property int tickChangePreferredWidth: theme.tickChangePreferredWidth

    property int tickRowLeftMargin: theme.tickRowLeftMargin
    property int tickRowRightMargin: theme.tickRowRightMargin
    property int tickRowTopMargin: theme.tickRowTopMargin
    property int tickRowBottomMargin: theme.tickRowBottomMargin
    property int tickRowHeight: theme.tickRowHeight

    property int minHeightPer: tickRowHeight

    property int showCount: Math.floor(height / minHeightPer);

    property int showStartIndex: Math.max(0, Math.ceil(flicker.visibleArea.yPosition * tickData.length))

    property int selectedTime

    Flickable {
        id: flicker
        anchors.fill: parent

        // 计算总数据高度
        contentHeight: minHeightPer * tickData.length
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Binding {
            target: flicker
            property: 'contentY'
            when: flicker.state === 'autoscroll'
            value: flicker.contentHeight - flicker.height;
        }

        onContentYChanged: {
            if (contentY >= flicker.contentHeight - flicker.height - 10) {
                state = 'autoscroll';
            } else if (contentY !== 0) {
                state = ''; // default state
            }

//            // 滚动条到达最顶部，请求更多历史数据
//            if (contentY < minHeightPer && hasMoreData && tickData.length > 0) {
//                requestDataProvider.params.start = -(tickData.length + 100);
//                requestDataProvider.query();
//            }
        }
    }
    ColumnLayout {
        id: layout
//        width: scrollbar.visible ? parent.width - 10 : parent.width
        anchors.fill: flicker
        anchors.rightMargin: scrollbar.visible ? 8 : 0
        spacing: 0
        clip: true
        Repeater {
            model: {

                // TODO 考虑使用WorkerScript处理，避免数据过多时处理数据阻塞UI响应
                if (showStartIndex >= 0 && showCount > 0 && tickData.length > 0) {

                    // 需要显示的数据
                    var arr = tickData.slice(showStartIndex, showStartIndex + showCount);
                    var lastLabel, currentLabel, volume, tick, label, showSecond, updown, currentPrice, lastPrice;
                    return arr.map(function(eachData, index) {
                        volume = eachData.DanCiChengJiaoLiang / stockCountUnit;
                        tick = eachData.DanCiChengJiaoDanBiShu;
                        currentLabel = DateUtil.moment.unix(eachData.ShiJian).format('HH:mm');
                        if (currentLabel === lastLabel) {
                            label = DateUtil.moment.unix(eachData.ShiJian).format(':ss');
                            showSecond = true;
                        } else {
                            label = currentLabel;
                            showSecond = false;
                        }
                        lastLabel = currentLabel;

                        currentPrice = eachData.ChengJiaoJia;
                        if (lastPrice) {
                            updown = currentPrice > lastPrice ? 1 : currentPrice < lastPrice ? -1 : 0;
                        } else {
                            updown = 0;
                        }
                        lastPrice = currentPrice;

                        return {
                            time: eachData.ShiJian,
                            label: label,
                            showSecond: showSecond,
                            price: currentPrice,
                            volume: volume,
                            buySell: eachData.MaiMaiFangXiang,
                            tick: tick,
                            updown: updown,

                            // 是否是最新(最后)的一条数据
                            last: tickData[tickData.length - 1] === eachData
                        }
                    });
                } else {
                    return [];
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: scrollbar.visible ? true : false
                Layout.preferredHeight: scrollbar.visible ? -1 : minHeightPer
                color: selectedTime === modelData.time || (!selectedTime && modelData.last) ? theme.rightSideBarHighLight : 'transparent'
                RowLayout {
                    spacing: 0
                    anchors.fill: parent
                    anchors.leftMargin: tickRowLeftMargin
                    anchors.rightMargin: tickRowRightMargin
                    anchors.topMargin: tickRowTopMargin
                    anchors.bottomMargin: tickRowBottomMargin
                    Text {
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignRight
                        Layout.fillHeight: true
                        Layout.preferredWidth: tickLabelPreferredWidth
                        color: tickLabelColor
                        font.pixelSize: modelData.showSecond ? tickLabelFontSize - 2 : tickLabelFontSize
                        font.weight: tickLabelFontWeight
                        font.family: tickLabelFontFamily
                        text: modelData.label
                    }
                    Label {
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: tickPricePreferredWidth
                        isAutoFormat: true
                        normalColor: tickPriceColor
                        upColor: tickPriceUpColor
                        downColor: tickPriceDownColor
                        font.pixelSize: tickPriceFontSize
                        font.weight: tickPriceFontWeight
                        font.family: tickPriceFontFamily

                        value: modelData.price
                        baseValue: root.lastClose

                        precision: stock.precision || 2
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: false
                        horizontalAlignment: Qt.AlignLeft
                        color: modelData.updown === 1 ? tickVolumeUpColor : tickVolumeDownColor
                        font.pixelSize: tickVolumeFontSize
                        font.weight: tickVolumeFontWeight
                        font.family: tickVolumeFontFamily
                        opacity: Math.abs(modelData.updown)
                        text: modelData.updown === 1 ? '↑' : '↓'
                    }
                    Label {
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment: Qt.AlignVCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: tickVolumePreferredWidth
                        normalColor: modelData.buySell === 1 ? tickVolumeUpColor : tickVolumeDownColor
                        font.pixelSize: tickVolumeFontSize
                        font.weight: tickVolumeFontWeight
                        font.family: tickVolumeFontFamily
                        precision: 0

                        value: modelData.volume
                    }

                    Label {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.preferredWidth: 40
                        horizontalAlignment: Qt.AlignRight
                        normalColor: tickChangeColor
                        font.pixelSize: tickChangeFontSize
                        font.weight: tickChangeFontWeight
                        font.family: tickChangeFontFamily
                        precision: 0

                        value: modelData.tick
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (modelData.last) {
                            selectedTime = 0;
                        } else {
                            selectedTime = modelData.time;
                        }
                    }
                }
            }
        }

        // 用于填充剩余高度
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: scrollbar.visible ? false : true
            Layout.preferredHeight: 0
            height: 0
        }
    }
    VScrollBar {
        id: scrollbar
        flicker: flicker
    }
}
