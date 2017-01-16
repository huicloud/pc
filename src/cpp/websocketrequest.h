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

#ifndef WEBSOCKETREQUEST_H
#define WEBSOCKETREQUEST_H

#include <QObject>
#include <QWebSocket>
#include <QTimer>

class WebSocketRequest : public QObject
{
    Q_OBJECT
public:
    explicit WebSocketRequest(QObject *parent = 0);

signals:
    //数据接收完成信号,发给DataChannel
    void finishedRecvToChannel(const QByteArray &data);

    //连接状态变化,发给DataChannel
    void stateChangeToChannel(int state);

    //打开,发给DataChannel
    void openToChannel();

    //关闭,发给DataChannel
    void closeToChannel();

    //出错,发给DataChannel
    void errorToChannel(QAbstractSocket::SocketError error);

    //重连超过最大次数,发给DataChannel
    void reConnectOverMaxToChannel();

    //往云平台发送心跳请求
    void sendPing(const QByteArray &payload);

public slots:

    //接收websocke连接信号
    void onConnected();

    //接收websocke状态变化信号，断开时重新建立连接
    void onStateChanged(QAbstractSocket::SocketState state);

    void onError(QAbstractSocket::SocketError error);
    void onDisconnected();

    //QWebSocket接收数据后触发
    void onFinished(const QByteArray & msg);

    //QWebSocket接收到ping的返回时，触发该信号源
    void onPong(quint64 elapsedTime, const QByteArray &payload);

    //定时器处理函数
    void onTimeOut();


public:
    //启动连接
    void StartConnection();
    //关闭连接
    void CloseConnection();
    //建立websocket连接
    void connectWebSocket(const QString & host);
    //断开websocket连接
    void closeWebSocket();

    bool send(const QString &url, const QJsonObject & params);
    void reConnect();

    void setConfigName(QString name);

private:
    void connectSignals();

public:
    int mState;                 //当前连接状态

    uint mLastSendPingTime;     //上次发送ping的时间
    uint mLastRecvPingTime;     //上次接收ping的时间
    int mPingCostTime;          //上次接收ping消耗的时间
    int mHeartTime;              //心跳时间，秒
    int mIsRecvPing;             //是否收到上次ping的返回，发送后设置为1，收到后设置为0

    QWebSocket mChannel;
    QString mhost;              //连接url
    QTimer *mTimerCheckConnect; //定时器，用于重连
    QString mConfigFileName;//当前用户的配置文件

    int mReConnectCountNow;//当前重连次数
    int mReConnectCountMax;//最大重连次数

    int mIsNoCompress;           //数据是否是压缩的：0，数据是压缩数据，1,数据未压缩
    int mWebSocketConnettingMaxTime;//websocket连接超时时间
    int mWebSocketConnettingTimeNow;//websocket连接时间
};

#endif // WEBSOCKETREQUEST_H
