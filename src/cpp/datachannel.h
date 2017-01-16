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

#ifndef DATACHANNEL_H
#define DATACHANNEL_H

#include "dataprocess.h"
#include "httprequest.h"
#include "websocketrequest.h"
#include "configuresetting.h"
#include <QObject>
#include <QWebsocket>
#include <QJsonObject>
#include <QByteArray>
#include <QVector>
#include <QNetworkAccessManager>
#include <QProcess>
#include <QTimer>


class DataChannel : public QObject
{
    Q_OBJECT
    Q_ENUMS(State)

public:
    enum State{
        Ready,
        Connecting,
        Connected,
        DisConnected
    };
public:
    explicit DataChannel(QObject *parent = 0);

signals:
    //数据处理完成后，发射该信号，通知UI
    void message(const QJsonValue data);

    //连接建立后，发射该信号，通知UI
    void open();

    //连接关闭后，发射该信号，通知UI
    void close();

    //重连超过最大次数后，发射该信号，通知UI
    void reconnectfail();

    //报错后，发射该信号，通知UI
    void error(QAbstractSocket::SocketError err);

    //连接状态发生变化
    void stateChanged();

    //datachannel启动信号,并不是真正的重连websocket,只是修改dataChanel状态
    void startDataChannel();

    //datachannel关闭信号,并不是真正的关闭websocket,只是修改dataChanel状态
    void stopDataChannel();

    //个股新闻数据处理完成后，发射该信号，通知UI
    void messageNews(const QString data);

public slots:
    //接收数据请求信号，根据输入参数，往云平台发送请求
    void send(const QString & url, const QJsonObject & params);

    //接收新闻数据请求信号，根据输入参数，请求个股新闻内容
    void sendNews(const QString & url);

    //接收datachannel启动信号
    void onStartDataChannel();

    //接收datachannel关闭信号
    void onStopDataChannel();

private slots:

    //线程处理完数据后被触发
    void onMessage(const QJsonValue data);

    //连接状态变化被触发
    void onWebSocketStateChanged(int);

    //连接被触发
    void onWebSocketConnected();

    //连接断开被触发
    void onWebSocketDisconnected();

    //重连超过最大次数
    void onWebSocketReConnectOverMax();

    //连接出错被触发
    void onWebSocketError(QAbstractSocket::SocketError error);

    //连接被触发
    void onHttpConnected();

    //连接断开被触发
    void onHttpDisconnected();

public:
    //启动连接
    void StartDataChannel();

    //关闭连接
    void CloseDataChannel();

    //qml中可以调用该函数获取状态
    Q_INVOKABLE int getState();
    //qml中可以调用该函数获取服务器ip地址
    Q_INVOKABLE QString getHost();
    //qml中可以调用该函数获取token
    Q_INVOKABLE QString getToken();
    //qml中可以调用该函数获取一个根据mac地址计算的64位整数
    Q_INVOKABLE quint64 getMachineId();

    //qml中可以调用该函数设置用户信息，读取配置文件时，根据用户信息读取相应配置文件,发送连接信号前调用该函数
    Q_INVOKABLE void setUserInfo(QString userinfo);

    //qml中可以调用该函数设置传输时附带的用户token，暂时未生效
    Q_INVOKABLE void setUserToken(QString token);

    //qml中可以调用该函数获取配置文件中parent分类下的key对应的配置信息，
    Q_INVOKABLE QString getConfigValue(QString parent,QString key);

private:
    void connectSignals();

    //定时启动升级程序
    void startCheckUpdate();

    //加载日志输出配置信息
    void loadLogOutputConfig();

private slots:
    void onFinishedHttpReply(QNetworkReply* reply);
    void onFinishedHttpReplyNews(QNetworkReply* reply);
    void onFinishedWebSocketReply(const QByteArray & msg);

    void onTimeOutCheckUpdate();

    void onTimeOutCheckTest();

    //日志级别更新检查，30s检查一次
    void onTimeOutLogLevelUpdate();

private:
    int mState;                 //当前连接状态
    int mStateWebSocket;                 //当前连接状态
    int mStateHttp;                 //当前连接状态
    int mThreadCount;           //数据处理线程个数
    int mThreadIndex;            //数据处理线程索引
    QMap<std::string, int> mQidMap;

    QVector<DataProcess*> mDataProcess;
    QVector<QThread*> mDataProcessThread;
    HttpRequest mHttpRequest;
    HttpRequest mHttpRequestNews;
    WebSocketRequest mWebSockectRequest;


    //升级程序定时器
    QTimer *mTimerCheckUpdate;
    QProcess *mCheckUpdateProcess;

    //测试
    QTimer *mTimerCheckTest;

    //日志级别热切换
    QTimer *mTimerReLoadLogLevel;


    QString mUserName;//当前用户的用户名
    QString mUserToken;//当前用户的连接token
    int mIsNoCompress;           //数据是否是压缩的：0，数据是压缩数据，1,数据未压缩
};


#endif // DATACHANNEL_H
