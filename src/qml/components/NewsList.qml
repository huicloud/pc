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
import "../core"
import "../core/data"
import "../controls"
import "../util"
import "../js/DateUtil.js" as DateUtil
import "../js/Util.js" as Util

/**
 * 新闻列表组件
 */
ContextComponent {
    id: root
    property string serviceUrl
    property var params
    property int stockType
    property string title
    property string timeFormat
    property var obj
    property int __requestedIndex: 0
    property string __requestNextPageUrl
    property var __resultWithOutSort: [];
    property int __lazyInterval: 1000
    property int __firtLoadCount: 20
    property var xhr;

    signal click(var itemData, int index, int newsType)

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: {
            if (stockType === 1) {
                return stockNewsList;
            } else if (stockType === 0) {
                return newsCenterList;
            }
        }
    }

    Component{
        id: stockNewsList
        ScrollBarList {
            id: list
            anchors.fill: parent
            highlightOnFocus: true
            delegate:  Component {
                Rectangle{
                    width: list.listView.width
                    height: list.rowHeight
                    color: (list.focusData && list.focusData.id === modelData.id)? '#ecf2ff' : 'transparent'
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        Text {
                            Layout.preferredWidth: 40
                            Layout.alignment: Qt.AlignLeft
                            text:{
                                if (modelData.type === '3'){
                                    return '新闻'
                                }else if (modelData.type === '2'){
                                    return '研报'
                                }else if (modelData.type === '4'){
                                    return '公告'
                                }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            text: modelData.title
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: formateItemTime(modelData.otime, root.timeFormat)
                        }
                    }
                }
            }

            onItemClick: {
                root.click(itemData, index, 1);
            }
        }
    }

    Component{
        id: newsCenterList
        ScrollBarList {
            id: list
            anchors.fill: parent
            highlightOnFocus: true
            delegate:  Component {
                Rectangle{
                    width: list.listView.width
                    height: list.rowHeight
                    color: (list.focusData && list.focusData.id === modelData.id) ? '#ecf2ff' : 'transparent'
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        Text {
                            Layout.preferredWidth: 40
                            Layout.alignment: Qt.AlignLeft
                            text:{
                                if (modelData.type === '3'){
                                    return '新闻'
                                }else if (modelData.type === '2'){
                                    return '晨报'
                                }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            text: modelData.title
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: formateItemTime(modelData.otime, root.timeFormat)
                        }
                    }
                }
            }

            onItemClick: {

                if (itemData.type === '2'){
                    //晨报PDF需求要求直接打开
                    var pdfCallback = function(content){

                        var resultGroup = content.match(/"(http:[^"]*)\\/);
                        if (resultGroup != null){
                            root.click(resultGroup[1], index,  2);
                        }
                    }
                    Util.ajaxGet(itemData.url, pdfCallback);

                }else{
                    root.click(itemData, index, 1);
                }
            }
        }
        /*//支持云平台的数据请求格式
          ScrollBarList {
            id: list
            anchors.fill: parent
            highlightOnFocus: true
            delegate: Component {
                Rectangle{
                    width: list.listView.width
                    height: list.rowHeight
                    color: list.focusData.NewsId === modelData.NewsId ? '#ecf2ff' : 'transparent' //list.highlightOnFocus && ListView.isCurrentItem && (list.currentIndex >= 0)
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        Text {
                            Layout.preferredWidth: 40
                            Layout.alignment: Qt.AlignLeft
                            text: root.title
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            text: modelData.Title
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: {
                                var date = DateUtil.moment(modelData.Date, 'YYYYMMDDHHmmss');

                                if (root.timeFormat) {
                                    return date.format(root.timeFormat);
                                } else if (moment().diff(date, 'days') === 0) {
                                    // today
                                    return date.format('HH:mm');
                                } else {
                                    return date.format('MM-DD');
                                }
                            }
                        }
                    }
                }
            }

            onItemClick: {
                root.click(itemData, index, 0);
            }
        }*/
    }

    function adapt(nextData) {
        return nextData;
    }

    function formateItemTime(time, format){
        var date = DateUtil.moment(time, 'YYYYMMDDHHmmss');

        var now = moment().startOf('day');
        var dateDay = DateUtil.moment(time, 'YYYYMMDD');

        if (format) {
            return date.format(format);
        } else if (now.diff(dateDay, 'days') === 0) {
            return date.format('HH:mm');
        } else {
            return date.format('MM-DD');
        }
    }

    //大盘资讯数据源
    DataProvider {
        id: dataProvider
        parent: root
        serviceUrl: root.serviceUrl
        params: root.params
        sub: 0  //暂时不订阅
        autoQuery: false
        function adapt(nextData) {
            return root.adapt(nextData);
        }

        onSuccess: {
            /*{"NewsId":433673682,"Date":"20161212155949","Title":"","Context":".txt.zlib","Source":""}*/
            var tempArray = counter > 1 ? data.concat(loader.item.model) : data;

            //进行排序操作
            tempArray.sort(function(a, b){
                return a.Date > b.Date ? -1 : 1;
            })
            loader.item.model = tempArray;
        }
    }

    function updateNewsList(sortArray){

        sortArray.sort(function(a, b){
            return a.otime > b.otime ? -1 : 1;
        });

        loader.item.model = sortArray;
    }

    Timer{
        id: lazyRequestTimer
        interval: root.__lazyInterval
        repeat: false
        running: false
        onTriggered: {
            xhr = Util.ajaxGet(root.__requestNextPageUrl, requestCallback);
            lazyRequestTimer.interval = root.__lazyInterval / 10;
        }
    }

    //请求返回数据回调处理
    function requestCallback(content){
        if (content == null || content instanceof Error){
            console.error(__requestNextPageUrl, root.obj, '返回为空或请求出现异常')
            return;
        }

        var reqCount = root.params.count[__requestedIndex];
        var currentCode;
        var jsonContent = JSON.parse(content);
        if (jsonContent.length > 0){
            var returnContent = jsonContent[0];
            if (returnContent.data.length === 0){
                console.error('个股资讯收到了空数据,不处理')
            }else{
                for(var i in returnContent.data){
                    __resultWithOutSort.push(returnContent.data[i])
                }

                if (__resultWithOutSort.length <= __firtLoadCount){
                    //优先加载第一次请求的数据
                    updateNewsList(__resultWithOutSort);
                }
            }

            //判断是否到了请求数量
            var nextPageUrl = returnContent.header.nextPage;
            if (nextPageUrl != null){
                var id = nextPageUrl.substr(nextPageUrl.length - 6, 1);
                if ((parseInt(id) <= reqCount)){
                    __requestNextPageUrl = nextPageUrl;
                    lazyRequestTimer.running = true;

                }else{
                    requestNext();
                }
            }else{
                requestNext();
            }
        }
    }

    function requestNext(){
        if (__requestedIndex >= root.params.type.length - 1){
            //没有下一页或请求结束,更新列表
            root.updateNewsList(__resultWithOutSort);
        }else{
            __requestedIndex++;
            var prefix = root.params.obj.substr(0, 2);
            if (prefix === 'B$')
            {
                prefix = 'BI';
            }
            var objUrl = prefix + '/' + root.params.obj.substr(6, 8) + '/'+ root.params.obj.substr(2) + '/';
            __requestNextPageUrl =  root.serviceUrl + objUrl + root.params.type[__requestedIndex];

            lazyRequestTimer.running = true;
        }
    }

    //请求手机资讯源
    function requestNewsFromJson(){
        if(root.params.type.length > 0){
            //预先请求第一组的第一批数据
            __requestedIndex = 0;
            var prefix = root.params.obj.substr(0, 2);
            if (prefix === 'B$')
            {
                prefix = 'BI';
            }
            var objUrl = prefix + '/' + root.params.obj.substr(6, 8) + '/'+ root.params.obj.substr(2) + '/';
            var url =  root.serviceUrl + objUrl + root.params.type[__requestedIndex];
            xhr = Util.ajaxGet(url, requestCallback);
        }
    }

    onObjChanged: {

        /*//触发指数的资讯订阅
        list.model = [];
        dataProvider.cancel();
        dataProvider.query();*/

        if ([0, 1].indexOf(stockType) > -1){
            //触发大盘、个股的资讯请求
            list.model = [];
            requestNewsFromJson();
        }
    }

    Component.onDestruction: {
        if (xhr){
            xhr.cancel = true;
        }
    }

}
