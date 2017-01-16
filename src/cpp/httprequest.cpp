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

#include "httprequest.h"
#include "generatetoken.h"
#include "datachannel.h"
#include <QUrl>
#include <QUrlQuery>


HttpRequest::HttpRequest(QObject *parent) : QObject(parent)
{

}

void HttpRequest::setConfigName(QString name){
    mConfigFileName = name;
}

void HttpRequest::init(){
    //加载配置
    QString host = ConfigureSetting::getInstance()->getHost();
    mHeartTime = ConfigureSetting::getInstance()->getHeartTime();

    //定时器设置
    mTimerCheckConnect = new QTimer(this);
    if(mTimerCheckConnect){
       mTimerCheckConnect->start(1000);
    }

    mhost = "http://" + host;
    //创建一个管理器
    mManager = new QNetworkAccessManager(this);
    if(mManager == Q_NULLPTR){
        return;
    }
    //连接请求结束信号
    connect(mManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onFinishedHttpReply(QNetworkReply*)));
    connect(mManager,SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)),this,SLOT(onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)));
    mState = DataChannel::Connected;
    emit openToChannel();
}

bool HttpRequest::send(const QString & url, const QJsonObject & params){
    QTime time;
    if (mState != DataChannel::Connected)
        return false;

    QUrlQuery query;
    query.addQueryItem("output", "pb");

    for(auto i = params.begin(); i != params.end(); i++){
        query.addQueryItem(i.key(), i.value().toVariant().toString());
    }


    QString queryType = "/quote/min";

    QByteArray cmd;
   // cmd.append("/stkdata?market=SH&field=ZuiXinJia&orderby=ZhangFu&desc=true&sub=1&count=30");
    if(url.compare("/quote/kline") == 0){
        //cmd.append(queryType);
        //query.addQueryItem("sub", "1");
        //cmd.append("/stkdata?market=SH&field=ZuiXinJia&orderby=ZhangFu&desc=true&sub=1&count=30");
        cmd.append(url);
        cmd.append('?');
        cmd.append(query.toString());
    }
    else {


        cmd.append(url);
        cmd.append('?');
        cmd.append(query.toString());
    }

    if(mManager == Q_NULLPTR){
        return false;
    }
    //创建一个请求
    QNetworkRequest request;
    QString token = GenerateToken::getInstance().getToken();

    //QString url = "http://gw.yundzh.com" + cmd + "&token=00000017:1466042106:91a16c84cd7257bb6c29d0bad5bb4a80219ba876";
    cmd.append("&token=").append(token);

    QString urlRequest;// = mhost;// + cmd + "&token=" + token;
    urlRequest.append(mhost).append(cmd);

    request.setUrl(QUrl(urlRequest));

    //发送GET请求
    mManager->get(request);

    qInfo() << "Http Send " << time.currentTime() << " Request:" << urlRequest << time.currentTime();
    return true;
}

bool HttpRequest::sendRequestNews(const QString & url){
    QTime time;
    if (mState != DataChannel::Connected)
        return false;

    if(mManager == Q_NULLPTR){
        return false;
    }
    //创建一个请求
    QNetworkRequest request;
    request.setUrl(QUrl(url));

    //发送GET请求
    mManager->get(request);

    qInfo() << "Http Send Request News" << time.currentTime() << " Request:" << url << time.currentTime();
    return true;
}

void HttpRequest::onFinishedHttpReply(QNetworkReply* reply)
{
    emit finishedHttpReply(reply);
}

void HttpRequest::onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility accessible){
    QTime time;
    qDebug() << "Http onNetworkAccessibleChanged " << time.currentTime() << " :" << accessible;
    if(accessible != 1){
        mState = DataChannel::DisConnected;
        emit closeToChannel();
    }else {
        mState = DataChannel::Connected;
        emit openToChannel();
    }
}
