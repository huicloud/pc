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

#ifndef FILESETTING_H
#define FILESETTING_H

#include <QObject>
#include <QTextStream>
#include <QFile>
#include <QNetworkAccessManager>
/**
 * @brief qml 控件类，支持文件读写和url请求下载文件
 * 图片下载使用实例
 * import Dzh.FileSetting 1.0
 *
 * FileSetting{
        id:mytest
        source: "./cache/mytest.jpg"
        url:"http://p0.qhimg.com/t01a978ab1294700e36.jpg"
        onError:{
            console.log("onResponse"+msg);
        }
        onResponse: {
            console.log("onResponse");
            if(mytest.source === "./cache/mytest.jpg"){
                mytest.url = "http://img01.taopic.com/141002/240423-14100210124112.jpg"
                mytest.source = "cache/test/mytest.jpg"
                mytest.request();
            }
        }
    }
    //source:支持目录创建

   //文件读写使用实例
   import Dzh.FileSetting 1.0

   FileSetting{
        id:mytest
        source: "./cache/mytest.dat"
        onError:{
            console.log("onResponse"+msg);
        }
    }
    mytest.write("test",FileSetting.TYPE_BINARY);//保存为二进制文件
    mytest.write("test");//无参数或FileSetting.TYPE_TEXT保存为文本文件

    mytest.read(FileSetting.TYPE_BINARY);//读二进制文件返回文本字符串
    mytest.read();//无参数或FileSetting.TYPE_TEXT //读文本文件返回文本字符串

    //source:支持目录创建
 */
class FileSetting : public QObject
{
    Q_OBJECT
    Q_ENUMS(FILETYPE)
public:
    enum FILETYPE{
        TYPE_TEXT,  //文本文件
        TYPE_BINARY //二进制文件
    };

    //文件名称
    Q_PROPERTY(QString source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)

    //http请求地址
    Q_PROPERTY(QString url
               READ url
               WRITE setUrl
               NOTIFY urlChanged)
    explicit FileSetting(QObject *parent = 0);

    //根据source，进行文件读写,写文件时，如果文件存在，会覆盖掉老文件
    Q_INVOKABLE QString read(FILETYPE type = TYPE_TEXT);
    Q_INVOKABLE bool write(const QString& data,FILETYPE type = TYPE_TEXT);

    //根据url，请求文件，保存到source，然后触发response
    Q_INVOKABLE void request();

    //根据系统类型，获取文件绝对路径
    Q_INVOKABLE QString getPath();


    QString source() { return mSource; }
    QString url() { return mUrl; }

public slots:
    void setSource(const QString& source) { mSource = source; }
    void setUrl(const QString& url) { mUrl = url; }
    void replyFinished(QNetworkReply *reply);

signals:
    void sourceChanged(const QString& source);
    void urlChanged(const QString& url);
    void error(const QString& msg); //出错时触发
    void response();//request 返回时触发

private:
    bool isDirExist(QString fullPath);

private:
    QString mSource;
    QString mUrl;
};

#endif // FILESETTING_H
