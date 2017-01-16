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
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import QtWebEngine 1.2
import Dzh.DZHWebEngineProfile 1.0
import Dzh.AppLauncher 1.0

import "../core/common"
import "../controls"
import "../core/data"
import "../js/Util.js" as Util

import Dzh.FileSetting 1.0

Window {
    id: root
    width: 620
    height: 366
    title: qsTr("大智慧-舵手版")
    // 主窗体显示状态时，登录框模态
    modality: window && window.visible ? Qt.ApplicationModal : Qt.NonModal

    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint

    signal loginSuccessed()  // 登录成功的信号，该信号由登录框发出，由主窗体捕捉到该信号后做初始化操作

    visible: true

    // 主窗体
    property var window

    // 登录状态枚举
    readonly property int stateNoLogin: 0
    readonly property int stateLoginning: 1
    readonly property int stateLoading: 2
    readonly property int stateLogined: 3

    property int state: stateNoLogin

    // 表单元素当未登录时有效，登录中和登录后失效
    property bool formEnabled: state === stateNoLogin

    property alias userName: userNameInput.text
    property alias password: passwordInput.text
    property bool isMd5: false
    property alias saveUser: saveUserCheckbox.checked
    property alias autoLogin: autoLoginCheckbox.checked
    property var loginUserInfos: JSON.parse(setting.loginUserInfos)

    property var lastUrlChangedCallback
    property string sessionId

    onStateChanged: {

        // 如果状态变回未登录时，加载进度设置为0
        if (state === stateNoLogin) {
            progressBar.percent = 0;
        }
    }

    function saveUserInfo() {

        // 移出相同用户名的用户信息
        loginUserInfos.some(function(userInfo, index) {
            if (userInfo.userName === userName) {
                loginUserInfos.splice(index, 1);
                return true;
            }
        });

        setting.loginUserInfos = JSON.stringify([{
                              userName: userName,
                              password: password,
                              isMd5: isMd5,
                              saveUser: saveUser,
                              autoLogin: autoLogin,

                              // 追加时间戳，避免数据不更新
                              timestamp: Date.now()
                          }].concat(loginUserInfos).slice(0, 5)); // 记录最近5条登录信息
    }

    function loadUserInfo(userInfo) {
        userName = userInfo.userName;
        password = userInfo.password;
        isMd5 = userInfo.isMd5;
        saveUser = userInfo.saveUser;
        autoLogin = userInfo.autoLogin;
    }

    function resetUserInfo() {
        userName = '';
        password = '';
        isMd5 = false;
        saveUser = true;
        autoLogin = false;

        userNameInput.showUserList = false;
    }

    function removeUserInfo(userInfo) {
        loginUserInfos.some(function(currentUserInfo, index) {
            if (currentUserInfo.userName === userInfo.userName) {
                loginUserInfos.splice(index, 1);
                return true;
            }
        });

        setting.loginUserInfos = JSON.stringify(loginUserInfos);

        // 如果当前显示的是删除的用户信息，则重新设置登录框中显示的用户信息
        if (userInfo.userName === userName) {

            // 如果当前记录的用户列表中还有用户信息，则加载第一个用户信息，否则重置登录框上的用户信息为默认值
            if (loginUserInfos.length > 0) {
                loadUserInfo(loginUserInfos[0]);
            } else {
                resetUserInfo();
            }
        }
    }

    function setMessage(messageText, isError) {
        message.text = messageText;
        message.color = isError ? '#ee2c2c' : '#999';
    }

    function validateUserName() {
        var userName = root.userName.trim();
        var isValid = true;
        if (userName === '') {
            setMessage('用户名不能为空', true);
            isValid = false;
        } else if (userName.length > 50) {
            setMessage('用户名长度不能超过50个字符', true);
            isValid = false;
        } else if (!new RegExp(/^[a-zA-Z0-9\u4E00-\u9FA5\.\-_&@]*$/g).test(userName)) {
            setMessage('用户名必须由英文,数字,点,减号,汉字,下划线或@组成!', true);
            isValid = false;
        } else if (!new RegExp(/^[a-zA-Z0-9\u4E00-\u9FA5\@]/).test(userName)) {
            setMessage('用户名必须由英文,数字,@ 或者汉字开头!', true);
            isValid = false;
        }

        if (!isValid) {
            userNameInput.focus = true;
            userNameInput.selectAll();
        }
        return isValid;
    }

    function validatePassword() {
        var isValid = true;
        if (isMd5 !== true && password.length > 32 || password.length < 1) {
            setMessage('密码长度必须在1到32个字符之间', true);
            isValid = false;
        } else if (new RegExp(/[\u4E00-\u9FA5]/g).test(password)) {
            setMessage('密码不能有汉字!', true);
            isValid = false;
        }

        if (!isValid) {
            passwordInput.focus = true;
            passwordInput.selectAll();
        }
        return isValid;
    }

    function validate() {
        return validateUserName() && validatePassword();
    }

    // 登录
    function login() {
        setMessage('');
        userNameInput.showUserList = false;
        if (validate()) {
            state = stateLoginning;

            load(0, '登录中');
            UserService.login(userName, password, isMd5, function(result) {
                if (result instanceof Error) {
                    error(result.message);
                } else {

                    if (state === stateLoginning) {

                        // 登录成功
                        state = stateLoading;
                        loginSuccessed();
                    } else {
                        // 取消登录了
                    }
                }
            });
        }
    }

    // 取消登录，登录框点击取消登录按钮后触发，重置登录框状态，通知主窗体停止加载
    function cancelLogin() {
        setMessage('');
        state = stateNoLogin;
    }

    // 登出，登录框点击登出按钮后触发，重置登录框状态，调用用户登出（主窗体应该监听状态然后做登出操作，断掉连接，重置用户相关数据）
    function logout() {
        userNameInput.showUserList = false;
        UserService.logout(function(data) {
            if (data instanceof Error) {

            } else {

                // 登出成功
                setMessage('登出成功');
                state = stateNoLogin;
            }
        });
    }

    // 加载进度
    function load(progress, message) {
        if (state === stateLoginning || state === stateLoading) {
            progressBar.percent = progress || 0;
            setMessage(message || '');
        }
    }

    // 加载完成
    function finish() {
        load(100, '登录成功');

        // 登录加载完成后，记录登录用户信息
        if (saveUser) {
            saveUserInfo();
        }

        state = stateLogined;
    }

    // 错误
    function error(message) {
        setMessage(message, true);
        state = stateNoLogin;
    }

    // 加载广告，使用XMLHttpRequest请求广告后台jsonp文件，判断是否有更新（比较本地广告数据的更新时间），有更新则重设本地缓存并且下载缓存广告图片，然后图片缓存更新本地广告缓存
    function loadAdv() {
        Util.ajaxGet('http://ad.gw.com.cn/loginAdv/loginJson-F.jsonp', function(result) {
            if (!(result instanceof Error)) {

                // 解析jsonp格式
                var match = result.match(/\(([^\)]*)\)/);
                if (match && match.length > 1) {
                    try {
                        var advData = JSON.parse(match[1]);

                        // 判断更新时间是否和当前缓存的更新时间相同
                        if (loginAdvCache.updateTime !== advData.updateTime) {

                            // 不相同则重新下载图片后缓存
                            var advImageUrl = advData.advImageUrl;
                            if (advImageUrl) {

                                // 解析图片名称
                                var imageFileName = advImageUrl.replace(/.*\//, '');
                                var fileDownload = Qt.createQmlObject('import Dzh.FileSetting 1.0; FileSetting {}', root);

                                var imageCache = fileDownload.source = 'cache/' + imageFileName;
                                fileDownload.url = advImageUrl;
                                fileDownload.response.connect(function() {

                                    // 广告图片缓存完成
                                    advData.imageCache = fileDownload.getPath();
                                    advSetting.loginAdvCache = JSON.stringify(advData);
                                    fileDownload.destroy();
                                });
                                fileDownload.request();
                            }
                        }
                    } catch (e) {
                        console.error('加载缓存广告图片失败');
                    }
                }
            }
        });
    }

    Component.onCompleted: {
        if (loginUserInfos.length > 0) {
            loadUserInfo(loginUserInfos[0]);
        }

        userNameInput.focus = true;

        // 使用ajaxGet请求一次，避免第一次请求时耗时
        Util.ajaxGet('http://localhost/');

        // 直接提前加载主窗体
        var windowComponent = Qt.createComponent("qrc:/dzh/Window.qml");

        if (windowComponent.status === Component.Ready) {
            window = windowComponent.createObject(0, {loginWindow: root});

            window.closing.connect(function() {
                UserService.logout();
            });
        } else {
            windowComponent.statusChanged.connect(function() {
                if (windowComponent.status === Component.Ready) {
                    window = windowComponent.createObject(0, {loginWindow: root});
                }
            });
        }

        // 如果自动登录选中状态，直接登录
        if (autoLogin) {
            login();
        }

        // 广告加载
//        loadAdv();
    }

    property var loginAdvCache: JSON.parse(advSetting.loginAdvCache)

    Settings {
        id: advSetting
        category: 'loginAdvCache'
        property string loginAdvCache: '{}'
    }

    Settings {
        id: setting
        category: 'loginUserInfos'
        property string loginUserInfos: '[]'
    }

    MouseArea {
        anchors.fill: parent
        property point previousPosition
        property bool dragged: false
        onPressed: {
            previousPosition = Qt.point(mouseX, mouseY);
            dragged = false;
        }
        onPositionChanged: {
            if (pressedButtons === Qt.LeftButton) {
                var dx = mouseX - previousPosition.x;
                var dy = mouseY - previousPosition.y;
                root.x = root.x + dx;
                root.y = root.y + dy;
                dragged = true;
            }
        }

        onClicked: {

            // 点击广告
            if (advImage.contains(Qt.point(mouseX, mouseY)) && !dragged && loginAdvCache.advLinkUrl) {
                Qt.openUrlExternally(loginAdvCache.advLinkUrl);
            }
            focus = true;
            dragged = false;
        }
    }

    ColumnLayout {
        id: container
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180

            Image {
                id: advImage
                anchors.fill: parent
                source: loginAdvCache.imageCache ? ('file:///' + loginAdvCache.imageCache) : '../images/login/default.png'
            }

            RowLayout {
                anchors.top: parent.top;
                anchors.right: parent.right;
                anchors.margins: 1
                spacing: 1

                IconButton {
                    iconSize: Qt.size(18, 18)
                    iconRes: IconResource {
                        defaultIcon: '../images/login/minimum.png'
                        hoverIcon: '../images/login/minimum-hovered.png'
                        pressIcon: '../images/login/minimum-actived.png'
                    }

                    onClickTriggered: {

                        userNameInput.showUserList = false;

                        // 登录状态点击最小化和关闭按钮隐藏登录框
                        if (root.state === root.stateLogined || window.visible === true) {
                            root.hide();
                        } else {
                            root.showMinimized();
                        }
                    }
                }
                IconButton {
                    iconSize: Qt.size(18, 18)
                    iconRes: IconResource {
                        defaultIcon: '../images/login/close.png'
                        hoverIcon: '../images/login/close-hovered.png'
                        pressIcon: '../images/login/close-actived.png'
                    }

                    onClickTriggered: {

                        userNameInput.showUserList = false;

                        // 登录状态点击最小化和关闭按钮隐藏登录框
                        if (root.state === root.stateLogined) {
                            root.hide();
                        } else {
                            root.close();
                        }
                    }
                }
            }
        }

        Rectangle {
            id: progress
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: '#fff'
            Rectangle {
                id: progressBar
                property int percent: 0
                property real _width: parent.width * percent / 100
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                color: '#ff6600'

                PropertyAnimation {
                    id: propertyAnimation
                    target: progressBar
                    property: 'width'
                    duration: 200
                    to: 0
                }

                on_WidthChanged: {
                    if (_width === 0) {
                        width = 0;
                    } else {
                        propertyAnimation.stop();
                        width = propertyAnimation.to;
                        propertyAnimation.to = _width;
                        propertyAnimation.start();
                    }
                }
            }
        }

        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 28
            Text {
                id: message
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                text: ''
            }
            Text {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignRight
                text: '客服热线：021-20219997'
                color: '#999'
                font.pixelSize: 12
            }
        }

        RowLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    columnSpacing: 14
                    rowSpacing: 0

                    Text {
                        Layout.preferredWidth: 86
                        Layout.preferredHeight: 30
                        horizontalAlignment: Text.AlignRight
                        text: '用户名'
                    }
                    TextField {
                        id: userNameInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        placeholderText: '邮箱/手机/用户名'
                        rightPadding: 30
                        enabled: formEnabled
                        selectByMouse: true
                        z: 100
                        opacity: 1
                        KeyNavigation.tab: passwordInput

                        property alias showUserList: userList.visible

                        onTextChanged: {
                            setMessage('');
                            isMd5 = false;
                        }

                        background: Rectangle {
                            border.width: 1
                            color: parent.enabled ? "transparent" : "#eeeeee"
                            border.color: parent.activeFocus ? "#4177f3" : "#d7d7d7"
                        }

                        IconButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconSize: Qt.size(30, 30)
                            iconRes: IconResource {
                                defaultIcon: userNameInput.showUserList ? '../images/login/arrow-up.png' : '../images/login/arrow-down.png'
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed:  mouse.accepted = false
                            }
                            onClickTriggered: {
                                userNameInput.showUserList = !userNameInput.showUserList;
                                if (userNameInput.showUserList) {
                                    userNameInput.focus = true;
                                }
                            }
                        }

                        onFocusChanged: {
                            if (!focus) {
                                showUserList = false;
                            }
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                login();
                            }
                        }

                        Window {
                            id: userList
                            flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

                            x: root.x + userNameInput.mapToItem(container, 0, 0).x
                            y: root.y + userNameInput.mapToItem(container, 0, userNameInput.height).y
                            width: userNameInput.width
                            height: listColumn.height + 2
                            visible: false

                            Rectangle {
                                anchors.fill: parent

                                border.width: 1
                                border.color: '#4177f3'

                                opacity: loginUserInfos.length > 0 ? 1 : 0

                                Column {
                                    id: listColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 1
                                    Repeater {
                                        model: loginUserInfos
                                        Rectangle {
                                            property bool hovered: hoverMouseArea.containsMouse
                                            color: hovered ? '#d2dcf3' : '#ffffff';
                                            height: 30
                                            width: parent.width
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    root.loadUserInfo(modelData);
                                                    userNameInput.showUserList = false;
                                                }
                                            }

                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.userName
                                            }

                                            IconButton {
                                                id: closeButton
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.rightMargin: 5
                                                iconSize: Qt.size(18, 18)
                                                iconRes: IconResource {
                                                    defaultIcon: '../images/login/delete.png'
                                                }
                                                visible: parent.hovered

                                                onClickTriggered: {
                                                    removeUserInfo(modelData);
                                                }
                                            }

                                            MouseArea {
                                                id: hoverMouseArea
                                                hoverEnabled: true
                                                anchors.fill: parent
                                                onPressed:  mouse.accepted = false
                                            }
                                            MouseArea {
                                                anchors.fill: closeButton
                                                cursorShape: Qt.PointingHandCursor
                                                onPressed:  mouse.accepted = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Text{}

                    Text {
                        Layout.preferredWidth: 86
                        Layout.preferredHeight: 30
                        horizontalAlignment: Text.AlignRight
                        text: '密　码'
                    }

                    TextField {
                        id: passwordInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        placeholderText: '请输入密码'
                        selectByMouse: true
                        enabled: formEnabled
                        echoMode: TextInput.Password
                        opacity: 1
                        KeyNavigation.tab: saveUserCheckbox

                        onTextChanged: {
                            setMessage('');
                            isMd5 = false;
                        }

                        background: Rectangle {
                            border.width: 1
                            color: parent.enabled ? "transparent" : "#eeeeee"
                            border.color: parent.activeFocus ? "#4177f3" : "#d7d7d7"
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                login();
                            }
                        }

                        Keys.onEnterPressed: {
                            login();
                        }
                    }

                    Text {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
//                        textFormat: Qt.RichText
//                        text: '<a style="text-decoration: none; color: #005ab1" href="https://i.gw.com.cn/UserCenter/page/account/forgetPass?q=f">找回密码</a>'
//                        onLinkActivated: {
//                            Qt.openUrlExternally(link);
//                        }
                        color: '#005ab1'
                        text: '找回密码'
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
//                            onPressed:  mouse.accepted = false
                            onClicked: {
                                Qt.openUrlExternally('https://i.gw.com.cn/UserCenter/page/account/forgetPass?q=f');
                            }
                        }
                    }
                    Text{}

                    RowLayout {
                        Layout.fillHeight: false
                        Layout.leftMargin: -6
                        Layout.rightMargin: -6

                        CheckBox {
                            id: saveUserCheckbox
                            text: '保存帐号密码'
                            indicator.width: 18
                            indicator.height: 18
                            Component.onCompleted: {
                                indicator.children[0].width = 18;
                                indicator.children[0].height = 18;
                            }
                            checked: true
                            enabled: formEnabled
                            KeyNavigation.tab: autoLoginCheckbox

                            onCheckedChanged: {
                                if (!checked) {
                                    autoLoginCheckbox.checked = false;
                                }
                            }
                        }
                        CheckBox {
                            id: autoLoginCheckbox
                            text: '自动登录'
                            indicator.width: 18
                            indicator.height: 18
                            enabled: formEnabled
                            KeyNavigation.tab: userNameInput

                            Component.onCompleted: {
                                indicator.children[0].width = 18;
                                indicator.children[0].height = 18;
                            }

                            onCheckedChanged: {
                                if (checked) {
                                    saveUserCheckbox.checked = true;
                                }
                            }
                        }
                    }
                    Text{}
                    Text{}
                    Button {
                        backgroundColor: pressed ? '#166ddd' : hovered ? '#3d9ceb' : ['#2e8de7', '#778a9d', '#778a9d', '#2e8de7'][root.state]
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        Layout.bottomMargin: 14
                        hoverEnabled: true
                        textColor: '#fff'
                        text: ['登　录', '取消登录', '取消登录', '退出登录'][root.state]

                        onClickTriggered: {
                            if (root.state === root.stateNoLogin) {
                                login();
                            } else if (root.state === root.stateLoginning || root.state === root.stateLoading) {
                                cancelLogin();
                            } else {
                                logout();
                            }
                        }
                    }
                }
            }

            LinearGradient {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                start: Qt.point(0, 0)
                end: Qt.point(0, height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: 'white' }
                    GradientStop { position: 0.1; color: '#ddd' }
                    GradientStop { position: 0.8; color: '#ddd' }
                    GradientStop { position: 0.9; color: 'white' }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.preferredWidth: 230

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10

                    Text {
                        text: '还没有大智慧帐号？'
                    }

                    Rectangle {
                        Layout.fillWidth: false
                        Layout.fillHeight: false
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 28
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        color: '#ff6600'

                        Button {
                            anchors.fill: parent
                            anchors.margins: 1
                            backgroundColor: pressed ? '#ff6600' : hovered ? '#ff6600' : '#ffffff'
                            textColor: hovered ? '#fff' : '#ff6600'
                            text: '立即注册!'
                            onClickTriggered: {
                                Qt.openUrlExternally('https://i.gw.com.cn/UserCenter/page/account/register?q=r');
                            }
                        }
                    }

                    Text {
                        text: '其它登录方式：'
                        color: '#999'
                    }

                    RowLayout {
                        spacing: 10
                        ImageButton {
                            Layout.preferredWidth: 60
                            imageSize: Qt.size(21, 20)
                            imageRes: IconResource {
                                defaultIcon: formEnabled ? '../images/login/qq.png' : '../images/login/qq-disabled.png'
                            }
                            hasText: true
                            anchorsAlignment: Qt.AlignLeft
                            spacing: 5
                            text: 'QQ'
                            enabled: formEnabled

                            onClickTriggered: {
                                thirdLogin('qq', function(){});
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed:  mouse.accepted = false
                            }
                        }

                        ImageButton {
                            Layout.preferredWidth: 60
                            imageSize: Qt.size(21, 20)
                            imageRes: IconResource {
                                defaultIcon: formEnabled ? '../images/login/wechat.png' : '../images/login/wechat-disabled.png'
                            }
                            hasText: true
                            anchorsAlignment: Qt.AlignLeft
                            spacing: 5
                            text: '微信'
                            enabled: formEnabled

                            onClickTriggered: {
                                thirdLogin('wechat', function(){});
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPressed:  mouse.accepted = false
                            }
                        }
                    }
                }
            }
        }
    }

    property var thirdLoginConfig: ({
                                        source: 11,
                                        qq: 'https://mail.qq.com/cgi-bin/loginpage',  //模拟数据 TODO
                                        wechat: 'https://wx.qq.com/'                  //模拟数据 TODO
                                    })

    // 第三方登录
    function thirdLogin(type, callback) {

        var jsessionid = 10086;  //模拟jsessionid数据 TODO 账号
        var url = thirdLoginConfig[type];

        if (jsessionid) {
            url = url + ';jsessionid=' + jsessionid;
        }

        url = [
                    url,
                    Util.param({
                                   source: thirdLoginConfig.source,
                                   // 时间戳
                                   _: new Date().getTime()
                               })
                ].join('?');

        var xhr = Util.ajaxGet(url, function(data) {
            // 请求失败
            if (!data || data === '' || data === '1') {
                callback(new Error('请求第三方登录失败'));
            } else {

                //模拟返回的数据 TODO
                data = '{"code":"200","message":null,"data":"'+ thirdLoginConfig[type]+'"}';
                var json = JSON.parse(data);
                if (json.code === '200') {
                    thirdLoginDialog.url = json.data;
                    thirdLoginDialog.show();
                } else {
                    callback(new Error('请求第三方登录失败[' + data.message + "]"));
                }
            }
        }, null, {'X-Requested-Mark': 1});
    }

    // 第三方登录对话框
    Window {
        id: thirdLoginDialog
        width: 700
        height: 500
        title: "大智慧舵手版"
        modality: Qt.ApplicationModal
        property alias url: webView.url

        WebView {
            id: webView
            anchors.fill: parent

            profile: DZHWebEngineProfile {
                id: profiles
                storageName: "QDZH"

                // cookie记录在内存中，下次再打开时cookie失效
                offTheRecord: true
                persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
            }

            onUrlChanged: {
                var url = webView.url.toString();

                var splits = url.split('?');
                var query = splits[splits.length - 1];

                //模拟页面跳转，解析URL中的相关参数 跳转到登陆窗口 注意模拟时用到的链接https://wx.qq.com/此地址扫描后不会主动跳转，真实场景中不会出现此问题。 TODO
                if (splits.length > 1 && query.length >= 0) {

                    var params = {};
                    params.uname = 'qqwechat';
                    params.u = 'password';

                    if (params.uname && params.u) {
                        userName = params.uname;
                        password = params.u;
                        isMd5 = true;
                        thirdLoginDialog.close();

                        // 直接登录
                        login();
                    }
                }
            }
        }

        onVisibleChanged: {
            if (!visible) {
                url = 'about:blank';
            }
        }

        Component.onCompleted: {

            // 创建完成后直接关闭，避免占用主窗体的焦点
            thirdLoginDialog.close();
        }
    }

    // 监听连接状态，如果连接中断后台直接重连，登录框提示正在重连，重连尝试失败时停止重连，提示用户连接失败
    Connections {
        target: DataChannel
        onClose: {
            setMessage('正在尝试重新连接服务器');
        }

        onReconnect: {
            setMessage('');
        }

        onReconnectFail: {
            error('连接服务器失败');

            // 弹出登录框
            root.show();
        }
    }
}
