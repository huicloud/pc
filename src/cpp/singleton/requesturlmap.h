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

#ifndef REQUESTURLMAP_H
#define REQUESTURLMAP_H
#include <QString>
#include <QMap>
#include <QJsonObject>

class RequestUrlMap
{
private:
    RequestUrlMap();
    RequestUrlMap(const RequestUrlMap &);
    RequestUrlMap & operator = (const RequestUrlMap &);

public:
    QString getRequestUrl(QString qid);
    void putRequestUrl(const QString &qid,const QString &url);
    void putRequestUrl(const QString &url, const QJsonObject &params);

    static RequestUrlMap& getInstance();

private:
    QMap<QString, QString> mMap;//qid:requesturl
};

#endif
