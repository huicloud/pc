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

#include "dataprocess.h"
#include <QDebug>
#include <QThread>
#include <QTime>
#include <QJsonObject>
#include "proto/dzhua.pb.h"
#include "proto/MSG.pb.h"
#include <string>
#include "snappystream.h"
#include "singleton/requesturlmap.h"


enum EnumID {
  Err_ParseFromArray = 1,
  Err_ParseFromString = 2,
};


QJsonValue msg2json(const dzhyun::MSG & msg);
QJsonValue table2json(const dzhyun::MSG & msg);

DataProcess::DataProcess(QObject *parent) : QObject(parent)
{

}

void DataProcess::onBinaryMessageReceived(char*pUa,bool isParseRight)
{
    QTime time;
    //qDebug()<<"DataProcess Thread:" << QThread::currentThreadId() << " " << time.currentTime() << " DataProcess Start.";
    time.start();
    dzhyun::UAResponse *ua = (dzhyun::UAResponse *)pUa;
    dzhyun::MSG msg;
    if (!isParseRight){
        qWarning() << "DataProcess ParseFromArray failed.";
        QJsonObject obj;
        obj["Err"] = Err_ParseFromArray;
        emit message(obj);
        return;
    }


    if (ua->err() != 0){
        QJsonObject obj;
        QString qid = QString(ua->qid().c_str());
        obj["Qid"] = qid;
        obj["Data"] = ua->data().c_str();
        obj["Err"] = ua->err();
        QString requestUrl = RequestUrlMap::getInstance().getRequestUrl(qid);
        if(requestUrl.length() > 0){
            qWarning() << "DataProcess parse UA failed." << ua->qid().c_str() << ua->data().c_str() << " url:" << requestUrl; 
        }
        emit message(obj);
        return;
    }
    QString tempQid("qid=");
    tempQid.append(ua->qid().c_str());
    //qDebug() << "DataProcess Recv" << tempQid << "Counter:" << ua->counter();

    if (!msg.ParseFromString(ua->data())){
        QJsonObject obj;
        QString qid = QString(ua->qid().c_str());
        obj["Qid"] = qid;
        obj["Err"] = Err_ParseFromString;

        qWarning() << "DataProcess ParseFromString failed" << ua->qid().c_str() << ua->data().c_str() << " url:" << RequestUrlMap::getInstance().getRequestUrl(qid);
        emit message(obj);
        return;
    }


    QJsonValue val;
    if (msg.id() == dzhyun::EnumID::IDTbl) {
        val = table2json(msg);
    }else{
        val = msg2json(msg);
    }


    if (!val.isNull()){
        QJsonObject obj;
        QString qid = QString(ua->qid().c_str());
        obj["Qid"] = qid;
        obj["ObjCount"] = msg.objcount();
        obj["Data"] = val;
        obj["Err"] = ua->err();
        obj["Counter"] = (qint32) ua->counter();

        //qDebug() <<"DataProcess Thread:" << QThread::currentThreadId() << "Data " << obj;
        emit message(obj);
    } else {
        QString temp("qid=");
        temp.append(ua->qid().c_str());
        QString qid = QString(ua->qid().c_str());
        qWarning() <<"DataProcess can't parse msg:" << temp <<  " url:" << RequestUrlMap::getInstance().getRequestUrl(qid);
    }
    //删除分配的内存
    delete ua;

    int workMilliSeconds = time.elapsed();
    qDebug() << time.currentTime() << "DataProcess work for" << tempQid << "counter:" << ua->counter() << ",Spend time:" << workMilliSeconds << "ms.";
}
