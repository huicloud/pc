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

#ifndef APPLAUNCHER_H
#define APPLAUNCHER_H

#include <QObject>
#include <QProcess>
#include <QGuiApplication>
#include <QDebug>
class AppLauncher : public QObject
{
    Q_OBJECT
public:
    explicit AppLauncher(QObject *parent = 0);
    Q_INVOKABLE void lauch(const QString &program);
    Q_INVOKABLE void lauch(const QString &program, const QStringList &arguments);
    Q_INVOKABLE bool lauchDetached(const QString &program);
    Q_INVOKABLE bool isRunning();
    Q_INVOKABLE QString getApplicationPath();
    Q_INVOKABLE QString getProductId();
    Q_INVOKABLE QString getApplicationVersion();
    Q_INVOKABLE QString getApplicationName();
    Q_INVOKABLE QString getApplicationCopyright();
    Q_INVOKABLE QString getApplicationWebSite();
    Q_INVOKABLE bool isFileExits(const QString &filePath);
protected:
    QProcess *m_process;
signals:
    void errorOccurred(const QString error);
public slots:
    void onErrorOccurred(QProcess::ProcessError error);
};

#endif // APPLAUNCHER_H
