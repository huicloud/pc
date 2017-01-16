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

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QThread>
#include <QtQml>
#include <QQuickView>
#include <QSharedMemory>
#include "datachannel.h"
#include "yfloat.h"
#include "qframelesswindow.h"
#include "dzhmainwindow.h"
#include "tablemodel.h"
#include "treemodel.h"
#include <QtWebEngine/qtwebengineglobal.h>
#include "dzhwebengineprofile.h"
#include "applauncher.h"
#include "singletonapplication.h"
#include "filesetting.h"
#include "configuresetting.h"

DataChannel * channel = NULL;
AppLauncher * appLauncher = NULL;

static QObject *datachannel_singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return channel;
}

static QObject *appLauncher_singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return appLauncher;
}

void SetTopWindow(){
#ifdef Q_OS_WIN
    //程序已经运行，则将窗口置顶后，退出本次启动
    HWND hWnd = FindWindow(NULL, TEXT("大智慧-舵手版"));
    if(NULL != hWnd){
        HWND hForeWnd = GetForegroundWindow();
        DWORD dwForeID = GetWindowThreadProcessId(hForeWnd, NULL);
        DWORD dwCurID = GetCurrentThreadId();
        AttachThreadInput(dwCurID, dwForeID, TRUE);
        if(IsZoomed(hWnd)){
            SendMessage(hWnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
            //ShowWindow(hWnd, SW_MAXIMIZE);
        }else{
            SendMessage(hWnd, WM_SYSCOMMAND, SC_RESTORE, 0);
            //ShowWindow(hWnd, SW_SHOWNORMAL);
        }
        SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
        SetForegroundWindow(hWnd);
        AttachThreadInput(dwCurID, dwForeID, FALSE);
        //HWND top = GetLastActivePopup(hwnd);
        //if(NULL != top && GetForegroundWindow() != top)
        //{
        //    SetForegroundWindow(top);
        //}
    }
#endif
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    SingletonApplication app(argc, argv);
    if (app.isRunning()){
        SetTopWindow();
        exit(0);
    }

    /* 使用新的单例判断方式, mac沙盒机制下 lock.create 错误信息为：QSharedMemory::create: unable to make key
    QGuiApplication app(argc, argv);
    bool isSingle = false;
    static QSharedMemory lock("B040617F-50AC-4BF1-89F0-18CC977CEFAA");

    if(lock.attach(QSharedMemory::ReadOnly)) {
        lock.detach();
    }

    if(lock.create(1))
        isSingle = true;

    if(!isSingle){
        SetTopWindow();
        exit(0);
    }*/

#ifdef Q_OS_WIN
    int isSoftwareOpenGL = ConfigureSetting::getInstance()->getIsSoftwareOpenGL();
    if(isSoftwareOpenGL){
        //处理部分显卡加载浏览器崩溃的问题
        QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
    }
#endif

    app.setApplicationName("QDZH3");
    app.setOrganizationName("Shanghai DZH Ltd.");
    app.setApplicationVersion("1.0");

    QtWebEngine::initialize();

    QThread dataThread;
    channel = new DataChannel(&dataThread);
    QObject::connect(channel, SIGNAL(startDataChannel()), channel, SLOT(onStartDataChannel()));
    QObject::connect(channel, SIGNAL(stopDataChannel()), channel, SLOT(onStopDataChannel()));
    dataThread.start();

    appLauncher = new AppLauncher();

    //QStockModel blockModel;
    SqlMenuEntry blockModel;
    QQmlApplicationEngine engine;
    QQmlContext *qmlContext = engine.rootContext();
    qmlContext->setContextProperty("blockModel", &blockModel);

    //    QThread *modelThread = new QThread();
    //    blockModel.moveToThread(modelThread);
    //    modelThread->start();

    //向qml注册新窗口类型
    qmlRegisterType<FileSetting>("Dzh.FileSetting", 1, 0, "FileSetting");
    qmlRegisterType<QFrameLessWindow>("Dzh.FrameLessWindow", 1, 0, "FrameLessWindow");
    qmlRegisterType<DZHMainWindow>("Dzh.MainWindow", 1, 0, "MainWindow");
    qmlRegisterSingletonType<DataChannel>("Dzh.Data", 1, 0, "Channel", datachannel_singletontype_provider);
    qmlRegisterType<DZHWebEngineProfile>("Dzh.DZHWebEngineProfile", 1, 0, "DZHWebEngineProfile");
    qmlRegisterSingletonType<AppLauncher>("Dzh.AppLauncher", 1, 0, "AppLauncher", appLauncher_singletontype_provider);
    engine.load(QUrl(QStringLiteral("qrc:/dzh/components/Login.qml")));
    //启动连接,由qml控制
    //emit channel->startDataChannel();
    int ret = app.exec();
    dataThread.exit();
    return ret;
}

