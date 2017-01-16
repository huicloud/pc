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

#include "websocketrequest.h"
#include "datachannel.h"
#include "generatetoken.h"
#include <QUrl>
#include <string>
#include <QUrlQuery>
#include <QDebug>
#include <QDir>
#include <QNetworkReply>
#include <snappy/snappy.h>
#include "singleton/requesturlmap.h"

WebSocketRequest::WebSocketRequest(QObject *parent) : QObject(parent)
{
     mTimerCheckConnect = Q_NULLPTR;
     mReConnectCountNow = 0;
     mReConnectCountMax = 3;
     mWebSocketConnettingMaxTime = 10;
     mWebSocketConnettingTimeNow = 0;
}

void WebSocketRequest::setConfigName(QString name){
    mConfigFileName = name;
}

//启动连接
void WebSocketRequest::StartConnection(){
    //先关闭
    this->CloseConnection();
    mReConnectCountNow = 0;
    mState = DataChannel::Ready;
    QString token = GenerateToken::getInstance().getToken();
    //qInfo()<<"Token:" << token ;
    qInfo()<<"StartConnection ConfigFile:" << mConfigFileName ;
    //加载配置
    QString host = ConfigureSetting::getInstance()->getHost();

    qInfo() << "dzhyun host:" << host;
    mHeartTime = ConfigureSetting::getInstance()->getHeartTime();
    qInfo() << "mHeartTime:" << mHeartTime;

    mIsNoCompress = ConfigureSetting::getInstance()->getIsNoCompress();
    qInfo() << "WebSocket::isNoCompress:" << mIsNoCompress;

    //设置默认值为真
    mIsRecvPing = 0;
    QDateTime date;
    date = date.currentDateTime();
    mLastSendPingTime = 0;
    mLastRecvPingTime = 0;
    mPingCostTime = 0;

    //定时器创建
    if(!mTimerCheckConnect){
        mTimerCheckConnect = new QTimer(this);
    }

    //连接信号和槽函数
    this->connectSignals();

    mhost = "ws://" + host + "/ws?token=";
    this->connectWebSocket(mhost + token);


    //定时器启动
    if(mTimerCheckConnect){
       mTimerCheckConnect->start(mHeartTime*1000);
       mWebSocketConnettingMaxTime = mHeartTime*2;
    }
}

//断开连接
void WebSocketRequest::CloseConnection(){
    if(mTimerCheckConnect){
        //定时器关闭
        mTimerCheckConnect->stop();
    }
    this->closeWebSocket();
}

void WebSocketRequest::connectSignals(){

    connect(&mChannel, SIGNAL(connected()), this, SLOT(onConnected()),Qt::UniqueConnection);
    connect(&mChannel, SIGNAL(binaryMessageReceived(QByteArray)), this, SLOT(onFinished(QByteArray)),Qt::UniqueConnection);
    connect(&mChannel, SIGNAL(stateChanged(QAbstractSocket::SocketState)), this, SLOT(onStateChanged(QAbstractSocket::SocketState)),Qt::UniqueConnection);
    connect(&mChannel, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onError(QAbstractSocket::SocketError)),Qt::UniqueConnection);
    connect(&mChannel, SIGNAL(disconnected()), this, SLOT(onDisconnected()),Qt::UniqueConnection);

    //连接检查定时器
    connect(mTimerCheckConnect,SIGNAL(timeout()), this, SLOT(onTimeOut()),Qt::UniqueConnection);
    connect(this,SIGNAL(sendPing(const QByteArray)),&mChannel,SLOT(ping(const QByteArray)),Qt::UniqueConnection);
    connect(&mChannel,SIGNAL(pong(quint64,QByteArray)),this,SLOT(onPong(quint64,QByteArray)),Qt::UniqueConnection);
}

bool WebSocketRequest::send(const QString &url, const QJsonObject & params)
{
    QTime time;
    if (mState != DataChannel::Connected)
        return false;

    QUrlQuery query;
    query.addQueryItem("output", "pb");

    if(mIsNoCompress == 0){
        query.addQueryItem("compresser", "snappy");
    }

    QString qidMapKey;
    for(auto i = params.begin(); i != params.end(); i++){
        query.addQueryItem(i.key(), i.value().toVariant().toString());
        if(i.key().compare("qid") == 0){
            qidMapKey = i.value().toVariant().toString().trimmed();
        }
    }

    QByteArray cmd;

    cmd.append(url);
    cmd.append('?');
    cmd.append(query.toString());

    QString temp;
    temp.append(url).append("?").append(query.toString(QUrl::FullyDecoded));
    qDebug() << time.currentTime() << "QWebSocket Send Request:" << temp;

    //保存登录请求
    RequestUrlMap::getInstance().putRequestUrl(qidMapKey,temp);

    mChannel.sendBinaryMessage(cmd);
    return true;
}

void WebSocketRequest::onConnected(){

    mState = DataChannel::Connected;
    mPingCostTime = 0;
    mLastSendPingTime = 0;
    mLastRecvPingTime = 0;
    qInfo() << "QWebSocket onConnected:";
    emit openToChannel();
}

void WebSocketRequest::onDisconnected(){
    QTime time;
    qInfo() << time.currentTime() << "QWebSocket onDisconnected:";
    mState = DataChannel::DisConnected;
    emit closeToChannel();
}

void WebSocketRequest::onError(QAbstractSocket::SocketError err){
    //mChannel.close();
    //mState = DataChannel::DisConnected;
    mState = DataChannel::DisConnected;
    emit errorToChannel(err);
    QTime time;
    qCritical() << time.currentTime() << "QWebSocket onError:" << err;
}

void WebSocketRequest::onStateChanged(QAbstractSocket::SocketState state){
    qInfo() << "QWebSocket state changed,now:" << state;
    int lastState = mState;
    if(state == QAbstractSocket::UnconnectedState){
        mState = DataChannel::DisConnected;
        //qDebug() << "QWebSocket disconnected,now reopen";
        //mChannel.open(QUrl(mhost));
    } else if(state == QAbstractSocket::ConnectedState){
        mState = DataChannel::Connected;
    } else if (state == QAbstractSocket::ConnectingState){
        mState = DataChannel::Connecting;
    }
    if(mState != lastState){
        emit stateChangeToChannel(mState);
    }
}

void WebSocketRequest::onPong(quint64 elapsedTime, const QByteArray &payload){
    //QWebSocket接收到ping的返回时，触发该信号源
    mIsRecvPing = elapsedTime/1000;
    mPingCostTime = elapsedTime/1000;
    QDateTime date;
    date = date.currentDateTime();
    mLastRecvPingTime = date.currentDateTime().toTime_t();

    //qDebug() << "QWebSocket onPong cost:" << elapsedTime << " recv:" << mLastRecvPingTime ;
}

void WebSocketRequest::connectWebSocket(const QString &host)
{
    mChannel.open(QUrl(host));
}

void WebSocketRequest::closeWebSocket()
{
    mChannel.close();
}

void WebSocketRequest::reConnect()
{
    mChannel.close();
    this->connectWebSocket(mhost + GenerateToken::getInstance().getToken());
}

void WebSocketRequest::onFinished(const QByteArray &data)
{
    emit finishedRecvToChannel(data);
}

void WebSocketRequest::onTimeOut(){

    //qInfo()<<"WebSocketRequest::onTimeOut()"<<mState;
    QDateTime date;
    date = date.currentDateTime();
    if(mState == DataChannel::Connecting){
        mWebSocketConnettingTimeNow = mWebSocketConnettingTimeNow + mHeartTime;
        if(mWebSocketConnettingTimeNow >= mWebSocketConnettingMaxTime){
            mState = DataChannel::DisConnected;
            mWebSocketConnettingTimeNow = 0;
        }
    }else{
        mWebSocketConnettingTimeNow = 0;
    }
    if(mState == DataChannel::Connected){
        mPingCostTime = mLastRecvPingTime - mLastSendPingTime;
        if(mPingCostTime < 0 || mPingCostTime > mHeartTime){
            //未收到或收到超时
            mState = DataChannel::DisConnected;
            qDebug() << "No recv Ping in time:cost:" << mPingCostTime << " lastsend:"<<mLastSendPingTime <<" lastrecv:"<<mLastRecvPingTime;
            qDebug() << "No recv Ping in time and return for HeartTime:" << mHeartTime << "s, Reconnect.";
        } else {
            mLastSendPingTime = date.currentDateTime().toTime_t();
            if(mLastRecvPingTime == 0){
                mLastRecvPingTime = mLastSendPingTime;
            }
            emit sendPing(QByteArray(""));
            //qDebug() << "Send Ping:"<<mLastSendPingTime;
            mReConnectCountNow = 0;
        }
    }

    if(mState == DataChannel::Ready || mState == DataChannel::DisConnected){
        if(mReConnectCountNow >= mReConnectCountMax){
            this->CloseConnection();
            qWarning() << "QWebSocket reconnect count over"<< mReConnectCountMax << ",so close websocket.";
            emit reConnectOverMaxToChannel();
            return;
        }
        this->reConnect();
        QTime time;
        qWarning() << time.currentTime() << "QWebSocket onTimeOut to reconnect:"<< mReConnectCountNow;
        mReConnectCountNow++;
    }
}

