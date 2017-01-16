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

#ifndef LOGMESSAGEHANDLER_H
#define LOGMESSAGEHANDLER_H

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <QByteArray>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QDateTime>
#include <QGuiApplication>

//默认打印日志级别
int gLogOutputLevel = 3;
QString gFileName = "";
QString gLastDate = "";
QString gFileDateName = "";
enum DzhMsgType { DzhFatalMsg, DzhCriticalMsg, DzhWarningMsg, DzhInfoMsg, DzhDebugMsg };

//转换qt日志级别到自定义级别，并判断是否需要输出该日志
int isOutputLog(QtMsgType type,QString &headText){
    int inputLogLevel = gLogOutputLevel;
    switch(type)
    {
    case QtDebugMsg://0 qDebug()
        inputLogLevel = DzhDebugMsg;
        headText = QString("Debug:");
        break;

    case QtWarningMsg://1 qWarning()
        inputLogLevel = DzhWarningMsg;
        headText = QString("Warning:");
        break;

    case QtCriticalMsg://2 qCritical()
        inputLogLevel = DzhCriticalMsg;
        headText = QString("Critical:");
        break;
    case QtFatalMsg://3 qFatal()
        inputLogLevel = DzhFatalMsg;
        headText = QString("Fatal:");
        break;

    case QtInfoMsg://4 qInfo()
        inputLogLevel = DzhInfoMsg;
        headText = QString("Info:");
        break;
    default:
        inputLogLevel = DzhDebugMsg;
        headText = QString("Debug:");

    }
    if(inputLogLevel > gLogOutputLevel){
        return 0;
    } else {
        return 1;
    }
}



//输出日志到文件
void logMessageOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg){
    static QMutex mutex;
    QString text;
    if(!isOutputLog(type,text)){
        return;
    }

    mutex.lock();

    if(gFileName.length() == 0){
        gFileName = QGuiApplication::applicationDirPath() + "/";
#ifdef Q_OS_MAC
        gFileName = QGuiApplication::applicationDirPath() +"/../Resources/";
#endif
        //创建log目录
        QDir dir(gFileName);
        if(!dir.exists("log"))
        {
            if(dir.mkpath("log")){
                gFileName.append("log/");
            }
        }else{
            gFileName.append("log/");
        }

    }
    QString currentDate = QDateTime::currentDateTime().toString("yyyy-MM-dd");
    if(currentDate.compare(gLastDate) != 0){
        gFileDateName = currentDate;
        gLastDate = currentDate;

        //创建log目录
        QDir dir(gFileName);

        //删除过期文件
        foreach(QFileInfo mfi ,dir.entryInfoList())
        {
          if(mfi.isFile())
          {
              QString fileName = mfi.baseName();
              QDateTime fileDate;
              fileDate = QDateTime::fromString(fileName, "yyyy-MM-dd");

              if(fileDate.daysTo(QDateTime::currentDateTime()) > 10){
                  //删除文件
                  dir.remove(mfi.fileName());
              }
          }
        }
    }

    QString context_info = QString("File:(%1) Line:(%2)").arg(QString(context.file)).arg(context.line);
    QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss ddd");
    QString current_date = QString("(%1)").arg(current_date_time);
    QString message = QString("%1 %2 %3 %4").arg(current_date).arg(text).arg(msg).arg(context_info);



    QFile logFile(gFileName+gFileDateName+".log");
    logFile.open(QIODevice::WriteOnly | QIODevice::Append);
    if(logFile.isOpen()){
        QTextStream text_stream(&logFile);
        text_stream << message << "\r\n";
        logFile.close();
    }

    mutex.unlock();
}

//输出日志到控制台
void logMessageOutputToStd(QtMsgType type, const QMessageLogContext &context, const QString &msg){
    QString text;
    if(!isOutputLog(type,text)){
        return;
    }

    QString context_info = QString("File:(%1) Line:(%2)").arg(QString(context.file)).arg(context.line);
    QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss ddd");
    QString current_date = QString("(%1)").arg(current_date_time);
    QString message = QString("%1 %2 %3 %4").arg(current_date).arg(text).arg(msg).arg(context_info);

    QByteArray localMsg = message.toLocal8Bit();
    std::cout << localMsg.constData() << std::endl;
    //fprintf(stderr, "%s\n", localMsg.constData());
}

#endif // LOGMESSAGEHANDLER_H
