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

#include "singletonapplication.h"
#include <QLocalSocket>
#include <QFileInfo>

#define TIME_OUT                (500)    // 500ms

SingletonApplication::SingletonApplication(int &argc, char **argv)
    : QGuiApplication(argc, argv)
    , _isRunning(false)
    , _localServer(NULL) {

    // 取应用程序名作为LocalServer的名字
    //_serverName = QFileInfo(QCoreApplication::applicationFilePath()).fileName();
    _serverName = "QDZH3SERVER-B040617F";
    _initLocalConnection();
}

//----------------------
// 检查是否已經有一个实例在运行, true - 有实例运行， false - 没有实例运行
//----------------------
bool SingletonApplication::isRunning() {
    return _isRunning;
}

//----------------------
// 通过socket通讯实现程序单实例运行，监听到新的连接时触发该函数
//----------------------
void SingletonApplication::_newLocalConnection() {
    QLocalSocket *socket = _localServer->nextPendingConnection();
    if(socket) {
        socket->waitForReadyRead(2 * TIME_OUT);
        delete socket;

        // 其他处理，如：读取启动参数
        _activateWindow();
    }
}

//----------------------
// 通过socket通讯实现程序单实例运行，
// 初始化本地连接，如果连接不上server，则创建，否则退出
//----------------------
void SingletonApplication::_initLocalConnection() {
    _isRunning = false;

    QLocalSocket socket;
    socket.connectToServer(_serverName);
    if(socket.waitForConnected(TIME_OUT)) {
        _isRunning = true;
        // 其他处理，如：将启动参数发送到服务端
        return;
    }

    //连接不上服务器，就创建一个
    _newLocalServer();
}

//----------------------
// 创建LocalServer
//----------------------
void SingletonApplication::_newLocalServer() {
    _localServer = new QLocalServer(this);
    connect(_localServer, SIGNAL(newConnection()), this, SLOT(_newLocalConnection()));
    if(!_localServer->listen(_serverName)) {
        // 此时监听失败，可能是程序崩溃时,残留进程服务导致的,移除之
        if(_localServer->serverError() == QAbstractSocket::AddressInUseError) {
            QLocalServer::removeServer(_serverName); // <-- 重点
            _localServer->listen(_serverName); // 再次监听
        }
    }
}

//----------------------
// 激活主窗口
//----------------------
void SingletonApplication::_activateWindow() {

}

