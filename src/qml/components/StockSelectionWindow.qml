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
import QtQuick.Window 2.2
import Dzh.FrameLessWindow 1.0
import QtWebEngine 1.2
import Dzh.Data 1.0;

import "../controls"

/*选股页*/
FrameLessWindow {

    id: root
    isSelectedWebViewState: true
    width: 900   // 初始大小为设计指定的900 * 540
    height: 540

    // 默认不显示
    visible: false

    title: '选股'

    flags: Qt.Window  | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint

    property string helpUrl: '';

    property var webHost: 'http://' + Channel.getConfigValue('WEB','webHost') + '/';
    property var yunToken: Channel.getToken();
    property var yunHost: Channel.getHost();

    RectangleWithBorder {
        anchors.fill: parent
        leftBorder: 1
        rightBorder: 1
        topBorder: 0
        bottomBorder: 1
        border.color: theme.toolbarColor

        TitleBar {
            id: toolbar
            anchors.top: parent.top
            anchors.left: parent.left

            width: parent.width
            height: 34
            mainWindow: root
            title: root.title

            Text {
                id: text
                text: '用法说明'
                elide: Text.ElideMiddle
                color: 'red'

                font.underline: true

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: toolbar.right
                anchors.rightMargin: toolbar.windowButton.width

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        Qt.openUrlExternally(root.helpUrl);
                    }
                    onEntered: {
                        root.canResize = false;
                    }
                    onExited: {
                        root.canResize = true;
                    }
                }
            }

        }
        Rectangle{
            anchors.top: toolbar.bottom
            anchors.left: parent.left

            height: parent.height - toolbar.height
            width: parent.width


            WebView {
                id: webView
                anchors.fill: parent
            }
        }
    }

    function open(webUrlObj) {
        root.title = webUrlObj.title;
        root.helpUrl = webHost + webUrlObj.helpUrl;
        webView.url = webHost + webUrlObj.url + '&yunHost=' + yunHost + '&yunToken=' + yunToken;

        if (!root.visible) {
            root.x = (Screen.width - root.width) / 2
            root.y = (Screen.height - root.height) / 2
            root.visible = true;
        }
    }


    onWebViewKeyEventTrigger:{
        root.visible = false;
    }

    onVisibleChanged: {
        if (!visible) {
            webView.url = 'about:blank';
        }
    }

    Component.onCompleted: {
        webView.url = 'about:blank';
    }

}
