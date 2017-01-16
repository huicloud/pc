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

#include <QFile>
#include <QTextCodec>
#include "applauncher.h"
#include "version.h"

#define G2U(s)(QTextCodec::codecForName("GBK")->toUnicode(s))

AppLauncher::AppLauncher(QObject *parent) : QObject(parent), m_process(new QProcess(this))
{
    connect(m_process, SIGNAL(errorOccurred(QProcess::ProcessError)), this, SLOT(onErrorOccurred(QProcess::ProcessError)), Qt::UniqueConnection);
}

void AppLauncher::lauch(const QString &program){
   m_process->start("\"" +program + "\"");
}

void AppLauncher::lauch(const QString &program, const QStringList &arguments){
    m_process->start("\"" +program + "\"", arguments);
}

bool AppLauncher::lauchDetached(const QString &program){
  return m_process->startDetached("\"" +program + "\"");
}

bool AppLauncher::isRunning(){
    return m_process->state() == QProcess::Running ? true: false;
}

QString AppLauncher::getApplicationPath(){
    return qApp->applicationDirPath();
}

QString AppLauncher::getProductId(){
    return "322";
}

QString AppLauncher::getApplicationVersion(){
    return G2U(PRODUCT_VERSION_STR);
}

QString AppLauncher::getApplicationName(){
    return G2U(FILE_DESCRIPTION);
}

QString AppLauncher::getApplicationCopyright(){
    return G2U(LEGAL_COPYRIGHT);
}

QString AppLauncher::getApplicationWebSite(){
    return G2U(ORGANIZATION_DOMAIN);
}


bool AppLauncher::isFileExits(const QString &filePath){
    if (QFile::exists(filePath)){
        return true;
    }else{
        return false;
    }
}

void AppLauncher::onErrorOccurred(QProcess::ProcessError error){
    //TODO 捕获程序的错误（start方法才有效）
    //this->errorOccurred("");
}
