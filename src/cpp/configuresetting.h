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

#ifndef CONFIGURESETTING_H
#define CONFIGURESETTING_H
#include <QSettings>

class ConfigureSetting
{
private:
    ConfigureSetting();
    ConfigureSetting(const ConfigureSetting &);
    ConfigureSetting & operator = (const ConfigureSetting &);

public:
    void setSettingUserInfo(QString name);
    QSettings& getSetting();
    static ConfigureSetting * getInstance();


    //配置读取服务
    QString getHost();
    int getThreadCount();
    int getCheckUpdateInterval();
    int getDzhYunType();
    int getIsNoCompress();
    int getHeartTime();
    int getIsOutputLogToFile();
    int getLogOutputLevel();
    int getIsSoftwareOpenGL();

    //调用该函数获取配置文件中parent分类下的key对应的配置信息
    QString getConfigValue(QString parent,QString key);

    QString getFileFullPathBySystem();

private:

    bool isDirExist(QString fullPath);

private:
    QSettings *mPtrSetting;
    QString mSettingFileName;
    QString mUserInfo;

    static ConfigureSetting *mPtrInstance;

    QMutex mMutex;
};

#endif // CONFIGURESETTING_H
