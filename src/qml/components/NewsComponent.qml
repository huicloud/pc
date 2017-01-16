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
import QtQuick.Window 2.0

import "../core"
import "../core/data"
import "../controls"
import "../util"

/**
 * 新闻资讯组件
 */
ContextComponent {
    id: root
    property string obj
    property var stock: StockUtil.stock.createObject(root);

    property Component newsWindowComponent: Qt.createComponent('NewsWindow.qml');

    Loader {
        anchors.fill: parent
        sourceComponent: {
            if (stock.type === 1) {
                return newsStock;
            } else if (stock.type === 0) {
                if (['SH000001', 'SZ399001', 'SZ399006'].indexOf(obj) !== -1){
                    return newsCenter;
                }else{
                    //B$版块 暂时不显示
                    //return newsPlank;
                }
            }
        }
    }

    Component {
        id: newsPlank
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Repeater {
                model:
                    [{
                        serviceUrl: 'http://mnews.gw.com.cn/wap/data/ipad/sector/',
                        params: {
                            obj: root.obj,
                            count: [3],
                            type: ['list/1.json']
                        },
                        title: '新闻'
                    }]
                RectangleWithBorder {
                    rightBorder: index === 0 ? 1 : 0
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent ? parent.width / 2 : 0

                    NewsList {
                        anchors.fill: parent
                        obj: root.obj
                        stockType: stock.type
                        serviceUrl: modelData.serviceUrl
                        params: modelData.params
                        title: modelData.title
                        timeFormat: modelData.timeFormat || ''
                        onClick: {
                            showNews(itemData, newsType);
                        }
                    }
                }
            }
        }
    }

    // 上证指数和深成指数展示新闻中心数据， 其中快讯采用A股分类，分类号class：1，要闻采用经济新闻分类，分类号class：13
    Component {
        id: newsCenter
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Repeater {
                model:
                    [{
                        serviceUrl: 'http://mnews.gw.com.cn/wap/data/ipad/stock/',
                        params: {
                            obj: root.obj,
                            count: [3],
                            type: ['list/dsb1.json']
                        },
                        title: '新闻'
                    }, {
                        serviceUrl: 'http://mnews.gw.com.cn/wap/data/ipad/stock/',
                        params: {
                            obj: root.obj,
                            count: [3],
                            type: ['yjbg/1.json']
                        },
                        title: '晨报',
                        timeFormat: 'MM-DD'
                    }]
                RectangleWithBorder {
                    rightBorder: index === 0 ? 1 : 0
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent ? parent.width / 2 : 0

                    NewsList {
                        anchors.fill: parent
                        obj: root.obj
                        stockType: stock.type
                        serviceUrl: modelData.serviceUrl
                        params: modelData.params
                        title: modelData.title
                        timeFormat: modelData.timeFormat || ''
                        onClick: {
                            showNews(itemData, newsType);
                        }
                    }
                }
            }
        }
    }

    // 个股展示个股新闻和公告
    Component {
        id: newsStock
        RowLayout {
            anchors.fill: parent
            spacing: 0
            Repeater {
                model:
                    [{
                        serviceUrl: 'http://mnews.gw.com.cn/wap/data/ipad/stock/',
                        params: {
                            obj: root.obj,
                            count: [3],
                            type: ['gsxw/1.json']
                        },
                        title: '新闻'
                    }, {
                        serviceUrl: 'http://mnews.gw.com.cn/wap/data/ipad/stock/',
                        params: {
                            obj: root.obj,
                            count: [2, 2],
                            type: ['gsgg/1.json', 'yjbg/1.json']
                        },
                        title: '公告',
                        timeFormat: 'MM-DD'
                    }]
                RectangleWithBorder {
                    rightBorder: index === 0 ? 1 : 0
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent ? parent.width / 2 : 0
                    NewsList {
                        anchors.fill: parent
                        obj: root.obj
                        stockType: stock.type
                        serviceUrl: modelData.serviceUrl
                        params: modelData.params
                        title: modelData.title
                        timeFormat: modelData.timeFormat || ''
                        function adapt(nextData) {
                            return nextData[0] ? nextData[0].Data : [];
                        }
                        onClick: {
                            showNews(itemData, newsType);
                        }
                    }
                }
            }
        }
    }

    function showNews(news, newsType) {

        // 判断当前新闻窗口是否存在，不存在打开新闻窗口，然后加载context对应连接，具体context是zlib还是pdf在新闻窗体中判断处理
        if (!root.context.commonNewsWindow) {

            // 创建子窗口，parent设置为0则打开独立窗口，TODO 需要考虑关闭主窗口时关闭子窗口
            root.context.commonNewsWindow = newsWindowComponent.createObject(root.context.mainWindow);

            // 关闭窗口时，将当前窗口删除(目前保留) 清空残留
            root.context.commonNewsWindow.closing.connect(function() {
                //root.newsWindow.destroy();
                //root.newsWindow = null;
                root.context.commonNewsWindow.clearWebView();
            });
        } else if (root.context.commonNewsWindow.visibility === Window.Minimized) {
            // 如果窗口当前状态为最小化时，将窗体还原(最小化还原后窗口看不见了)
            root.context.commonNewsWindow.visibility = Window.Windowed;
        }

        root.context.commonNewsWindow.load(news, newsType, obj);
        root.context.commonNewsWindow.show();
    }
}
