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

#ifndef GENERATETOKEN_H
#define GENERATETOKEN_H
#include <QString>

class GenerateToken
{
private:
    GenerateToken();
    GenerateToken(const GenerateToken &);
    GenerateToken & operator = (const GenerateToken &);

public:
    void init();
    QString getToken();

    static GenerateToken& getInstance();


private:

    void calculateToken();

private:
    QString appid;
    QString secret_key;
    qint64 token_expired_time;
    QString expired_time;
    QString short_id;
    QString rawMask;    //rawMask = appid + "_" + expired_time + "_" + secret_key
    QString mask;       //mask = hamc_shal(rawMask,secret_key);
    QString hex_mask;   //hex_mask = hex_encode(mask);
    QString token;      //token = short_id + ":" + expired_time + ":" + hex_mask
};

#endif // GENERATETOKEN_H
