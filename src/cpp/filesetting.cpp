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

#include "filesetting.h"
#include <QImage>
#include <QNetworkReply>
#include <QDebug>
#include <QDir>
#include "configuresetting.h"

FileSetting::FileSetting(QObject *parent) : QObject(parent)
{

} 

QString FileSetting::getPath(){
    QString filePath = ConfigureSetting::getInstance()->getFileFullPathBySystem();

    filePath = filePath + this->mSource;
    qDebug()<<"FileSetting::getPath()"<<filePath;
    return filePath;
}

QString FileSetting::read(FILETYPE type)
{
    QString filePath = this->getPath();
    if (filePath.isEmpty()){
        emit error("source is empty");
        return QString();
    }

    QFile file(filePath);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {

        if(type == TYPE_BINARY){
            QDataStream in(&file);
            in >> fileContent;
        }else{
            QString line;
            QTextStream t( &file );
            do {
                line = t.readLine();
                fileContent += line;
             } while (!line.isNull());
        }

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

bool FileSetting::write(const QString& data,FILETYPE type)
{
    QString filePath = this->getPath();
    if (filePath.isEmpty())
    {
        emit error("source is empty");
        return false;
    }
    this->isDirExist(filePath);
    QFile file(filePath);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)){
        emit error("source open error");
        return false;
    }
    if(type == TYPE_BINARY){
        QDataStream out(&file);
        out << data;
    }else{
        QTextStream out(&file);
        out << data;
    }

    file.close();
    return true;
}

void FileSetting::request(){
    //获取网络图片
    QNetworkAccessManager *manager;
    manager = new QNetworkAccessManager(this);

    connect(manager, SIGNAL(finished(QNetworkReply*)),
                this, SLOT(replyFinished(QNetworkReply*)));
    manager->get(QNetworkRequest(QUrl(this->mUrl)));
    //qDebug()<<"FileSetting::request()"<<this->mUrl;
}

void FileSetting::replyFinished(QNetworkReply *reply)
{
    if(reply->error() == QNetworkReply::NoError)
    {
        QString filePath = this->getPath();
        QImage image;
        //获取字节流构造 QPixmap 对象
        image.loadFromData(reply->readAll());
        this->isDirExist(filePath);
        image.save(filePath);//保存图片
        //qDebug()<<"FileSetting::save()"<<this->mSource;
        emit this->response();
    }else{
        qDebug()<<"FileSetting::replyFinished err: "<<reply->errorString();
        emit error("FileSetting::replyFinished err: "+reply->errorString());
    }
}

//目录检查
bool FileSetting::isDirExist(QString fullPath)
{
    QString parentPath = ConfigureSetting::getInstance()->getFileFullPathBySystem();
    QDir dir(parentPath);
    QDir dirTemp(fullPath);

    QString pathFilter = dirTemp.dirName();
    QString path = fullPath.replace(pathFilter,"");

    if(dir.exists(path))
    {
        //判断文件是否存在，不存在将当前目录下文件复制到用户目录下
        //qDebug()<< "isDirExist true";
        return true;
    }
    else
    {
       bool ok = dir.mkpath(path);//创建用户子目录
       //判断文件是否存在，不存在将当前目录下文件复制到用户目录下
       //qDebug()<< "isDirExist mkpath"<<ok;
       return ok;
    }
}
