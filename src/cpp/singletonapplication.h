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

#ifndef SINGLETONAPPLICATION_H
#define SINGLETONAPPLICATION_H
#include <QGuiApplication>
#include <QObject>
#include <QLocalServer>

class SingletonApplication : public QGuiApplication {
        Q_OBJECT
    public:
        SingletonApplication(int &argc, char **argv);
        bool isRunning();                // 是否已經有实例在运行

    private slots:
        // 有新连接时触发
        void _newLocalConnection();

    private:
        // 初始化本地连接
        void _initLocalConnection();
        // 创建服务端
        void _newLocalServer();
        // 激活窗口
        void _activateWindow();

        bool _isRunning;                // 是否已經有实例在运行

        QLocalServer *_localServer;     // 本地socket Server
        QString _serverName;            // 服务名称
};

#endif // SINGLETONAPPLICATION_H
