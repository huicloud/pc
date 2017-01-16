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

#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QObject>
#include <QNetworkReply>
#include <QTimer>

class HttpRequest:public QObject
{
    Q_OBJECT
public:
    explicit HttpRequest(QObject *parent = 0);

signals:
    //http数据接收完成信号
    void finishedHttpReply(QNetworkReply* reply);

    void openToChannel();

    void closeToChannel();

public slots:
    //http数据接收完成处理函数
    void onFinishedHttpReply(QNetworkReply* reply);


    void onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility accessible);

public:
    //http发送请求函数
    bool send(const QString & url, const QJsonObject & params);

    //请求新闻内容
    bool sendRequestNews(const QString & url);

    void init();
    void setConfigName(QString name);

private:
    QString mhost;              //连接url
    int mState;                 //当前连接状态
    int mHeartTime;             //心跳时间，秒
    QTimer *mTimerCheckConnect; //定时器，用于重连
    QNetworkAccessManager *mManager;
    QString mConfigFileName;//当前用户的配置文件
};

#endif // HTTPREQUEST_H
