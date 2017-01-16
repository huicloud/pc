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

#include "requesturlmap.h"
#include <QDebug>

RequestUrlMap::RequestUrlMap()
{

}

QString RequestUrlMap::getRequestUrl(QString qid)
{
    return mMap[qid.trimmed()];
}

void RequestUrlMap::putRequestUrl(const QString &qid,const QString &url)
{
    if(qid.length() > 0){
        if(url.startsWith("/cancel")){
            //删除对应的qid
            mMap.remove(qid.trimmed());
            //qInfo()<<"PutRequestUrl"<< qid <<url;
        } else {
            mMap[qid.trimmed()] = url;
            //qInfo()<<"PutRequestUrl"<< qid <<url;
        }
    }
}

void RequestUrlMap::putRequestUrl(const QString &url, const QJsonObject &params)
{
    for(auto i = params.begin(); i != params.end(); i++){
        if(i.key().compare("qid") == 0){
            mMap[i.value().toVariant().toString().trimmed()] = url;
            qInfo()<<"PutRequestUrl"<< i.key() <<":"<<i.value().toVariant().toString().trimmed();
            break;
        }
    }
}

RequestUrlMap& RequestUrlMap::getInstance()
{
    static RequestUrlMap mRequestUrlMap;
    return mRequestUrlMap;
}
