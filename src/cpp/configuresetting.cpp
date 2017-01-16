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

#include "configuresetting.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QGuiApplication>

ConfigureSetting* ConfigureSetting::mPtrInstance = Q_NULLPTR;

ConfigureSetting::ConfigureSetting()
{
    mPtrSetting = Q_NULLPTR;
}

ConfigureSetting * ConfigureSetting::getInstance(){

//    static ConfigureSetting mInstance;
//    return mInstance;
    if(!mPtrInstance){
        mPtrInstance = new ConfigureSetting();
        mPtrInstance->setSettingUserInfo("");
    }
    return mPtrInstance;
}

QSettings& ConfigureSetting::getSetting(){
    return *mPtrSetting;
}

//设置用户信息，根据用户信息读取配置文件
void ConfigureSetting::setSettingUserInfo(QString userinfo){
    qInfo() << "ConfigureSetting::setSettingUserInfo user:"<<userinfo;
    if(userinfo.length()>0){
        isDirExist(userinfo);
        mSettingFileName = getFileFullPathBySystem()+userinfo+"/dzhyun.ini";
    }else{
        mSettingFileName = getFileFullPathBySystem()+"dzhyun.ini";
    }
    QFile qfile(mSettingFileName);

    qInfo() << "ConfigureSetting::filepath"<<mSettingFileName;
    if(!qfile.exists()){
        qInfo() << "ConfigureSetting::dzhyun.ini is not exist!";
    }

    if(mPtrSetting){
        if(mUserInfo.compare(userinfo) != 0){
            //用户改变了
            mMutex.lock();
            delete mPtrSetting;
            mPtrSetting = Q_NULLPTR;
            mPtrSetting = new QSettings(mSettingFileName,QSettings::IniFormat);
            mMutex.unlock();
            qInfo() << "ConfigureSetting::setSettingUserInfo user change,so new QSettings().old:" << mUserInfo << " new:" << userinfo;
            mUserInfo = userinfo;
        }
    } else {
        mUserInfo = userinfo;
        mMutex.lock();
        mPtrSetting = new QSettings(mSettingFileName,QSettings::IniFormat);
        mMutex.unlock();
        qInfo() << "ConfigureSetting::setSettingUserInfo first new QSettings().";
    }
}

//目录及文件检查
bool ConfigureSetting::isDirExist(QString fullPath)
{
    QString parentPath = this->getFileFullPathBySystem();
    QDir dir(parentPath);
    QString sourceFile = parentPath + "dzhyun.ini";
    QString destFile = parentPath + fullPath + "/dzhyun.ini";

    if(dir.exists(fullPath))
    {
        //判断文件是否存在，不存在将当前目录下文件复制到用户目录下
        if(!QFile::exists(destFile)){
            if(!QFile::copy(sourceFile, destFile))
            {
                qDebug()<< "copy dzhyun.ini false";
            }
        }
        return true;
    }
    else
    {
       bool ok = dir.mkpath(fullPath);//创建用户子目录
       //判断文件是否存在，不存在将当前目录下文件复制到用户目录下
       if(!QFile::copy(sourceFile, destFile))
       {
           qDebug()<< "copy dzhyun.ini false";
       }
       return ok;
    }
}

//获取配置文件路径
QString ConfigureSetting::getFileFullPathBySystem(){
    QString filePath;
    filePath = QGuiApplication::applicationDirPath() + "/";
#ifdef Q_OS_MAC
    filePath = QGuiApplication::applicationDirPath() +"/../Resources/";
#endif

    qDebug()<<"ConfigureSetting::getFileFullPathBySystem():"<<filePath;
    return filePath;
}

QString ConfigureSetting::getConfigValue(QString parent,QString key){
    QString value = "";
    QString strKey;
    strKey.append(parent).append("/").append(key);
    if(mPtrSetting){
        value = mPtrSetting->value(strKey).toString();
    }
    qInfo() << "ConfigureSetting::getConfigValue()" << strKey << value;
    return value;
}

//获取云平台地址
QString ConfigureSetting::getHost(){
    QString host = "gw.yundzh.com";;
    if(mPtrSetting){
        host = mPtrSetting->value("DzhYun/service").toString();
        if(host.isNull() || host.isEmpty()){
            host = "gw.yundzh.com";
        }
    }
    qInfo() << "ConfigureSetting::getHost()"<<host;
    return host;
}

//获取请求数据是否压缩标志
int ConfigureSetting::getThreadCount(){
    int ret = 1;
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhYun/threadCount").toInt();
        if(ret <= 0){
            ret = 1;
        }
    }
    qInfo() << "ConfigureSetting::getThreadCount()"<<ret;
    return ret;
}

//获取检查更新版本定时器
int ConfigureSetting::getCheckUpdateInterval(){
    int ret = 1800;//默认30分钟
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhYun/checkUpdateInterval").toInt();
        //大于1天时
        if(ret <= 0 || ret > 86400){
            ret = 1800;//默认30分钟
        }
    }
    qInfo() << "ConfigureSetting::getCheckUpdateInterval()" << ret << "s.";
    return ret;
}

//获取请求数据是否压缩标志
int ConfigureSetting::getDzhYunType(){
    int ret = 0;
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhYun/yuntype").toInt();
    }
    qInfo() << "ConfigureSetting::getDzhYunType()"<<ret;
    return ret;
}

//获取请求数据是否压缩标志
int ConfigureSetting::getIsNoCompress(){
    int ret = 0;
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhYun/isNoCompress").toInt();
    }
    qInfo() << "ConfigureSetting::getIsNoCompress()"<<ret;
    return ret;
}

//获取websocket心跳时间
int ConfigureSetting::getHeartTime(){
    int ret = 3;
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhYun/heartTime").toInt();
        if(ret == 0){
            ret = 3;
        }
    }
    qInfo() << "ConfigureSetting::getHeartTime()" << ret << "s.";
    return ret;
}

//获取日志是否输出到文件
int ConfigureSetting::getIsOutputLogToFile(){
    int ret = 0;
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhLog/isOutputLogToFile").toInt();
    }
    qInfo() << "ConfigureSetting::getIsOutputLogToFile()"<<ret;
    return ret;
}

//获取日志输出级别
int ConfigureSetting::getLogOutputLevel(){
    int ret = 3;
    mMutex.lock();
    delete mPtrSetting;
    mPtrSetting = Q_NULLPTR;
    mPtrSetting = new QSettings(mSettingFileName,QSettings::IniFormat);
    mMutex.unlock();
    if(mPtrSetting){
        if(!mPtrSetting->value("DzhLog/logOutputLevel").isNull()){
            ret = mPtrSetting->value("DzhLog/logOutputLevel").toInt();
            if(ret < 0){
                ret = 3;
            }
        }
    }
    qDebug() << "ConfigureSetting::getLogOutputLevel()"<<ret;
    return ret;
}

//
int ConfigureSetting::getIsSoftwareOpenGL(){
    int ret = 0;
    if(mPtrSetting){
        ret = mPtrSetting->value("DzhClient/isSoftwareOpenGL").toInt();
    }
    qInfo() << "ConfigureSetting::getIsSoftwareOpenGL()"<<ret;
    return ret;
}

