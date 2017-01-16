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

#include "generatetoken.h"
#include "configuresetting.h"
#include <QDateTime>
#include <QDebug>
#include <QCryptographicHash>
#include <QMessageAuthenticationCode>

GenerateToken::GenerateToken()
{

}

QString GenerateToken::getToken()
{
    //判断当前token是否过期
    QDateTime date;
    date = date.currentDateTime();
    qint64 time = date.toTime_t();
    if(time >= this->token_expired_time){
        //token过期，重新计算
        //qDebug() << "Token过期，time:" << time << " >= " << this->token_expired_time;
        this->token_expired_time = time + 86400;//有效期1天
        this->expired_time.setNum(this->token_expired_time);
        this->calculateToken();
        return token;
    } else {
        //qDebug() << "time:" << time << " <= " << this->token_expired_time;
        return token;
    }
}

GenerateToken& GenerateToken::getInstance(){

    static GenerateToken mGenerateToken;
    return mGenerateToken;
}

void GenerateToken::init()
{
    QDateTime date;
    date = date.currentDateTime();
    this->token_expired_time = date.toTime_t();

    int mType = ConfigureSetting::getInstance()->getDzhYunType();
    qInfo()<< "DzhYun/yuntype:"<< mType;

    //模拟数据 TODO   appid secretkey 请从大智慧金融信息云http://yun.gw.com.cn/index.html申请
    if(mType == 1){
        //alpha环境
        this->appid = "xxxxxxxxxxxxxxxxxxxxxxxxxxx";
        this->secret_key = "xxxxxxxxxxxx";
        this->short_id = "0000000x";

    } else if(mType == 2){
        //beta环境
        this->appid = "xxxxxxxxxxxxxxxxxxxxxxxxxxx";
        this->secret_key = "xxxxxxxxxxxx";
        this->short_id = "0000000x";
    } else{
        //外网环境
        this->appid = "xxxxxxxxxxxxxxxxxxxxxxxxxxx";
        this->secret_key = "xxxxxxxxxxxx";
        this->short_id = "0000000x";
    }

    //有效期1天
    this->token_expired_time = date.toTime_t() + 86400;
    this->expired_time.setNum(this->token_expired_time);

    this->calculateToken();
}

//本地计算token
void GenerateToken::calculateToken(){
    rawMask = appid + "_" + expired_time + "_" + secret_key;

    QMessageAuthenticationCode code(QCryptographicHash::Sha1);
    code.setKey(secret_key.toLatin1());
    code.addData(rawMask.toLatin1());

    token = short_id + ":" + expired_time + ":" + code.result().toHex();
}
