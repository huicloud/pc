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

#include "datachannel.h"
#include "generatetoken.h"
#include "logmessagehandler.h"
#include <QUrl>
#include <QString>
#include <QUrlQuery>
#include <QtDebug>
#include <QDir>
#include <QThread>
#include <QNetworkReply>
#include <QTextCodec>
#include <QNetworkInterface>
#include <QGuiApplication>
#include "proto/dzhua.pb.h"
#include "proto/MSG.pb.h"
#include "snappystream.h"
#include "snappy/snappy.h"


DataChannel::DataChannel(QObject *parent) : QObject(parent),mState(Ready)
{
    mCheckUpdateProcess = Q_NULLPTR;
    mTimerCheckUpdate = Q_NULLPTR;

    //token初始化
    GenerateToken::getInstance().init();
    //测试重连机制
    //mTimerCheckTest = new QTimer(this);
    //mTimerCheckTest->start(1000);

    //日志级别检查
    mTimerReLoadLogLevel = Q_NULLPTR;
}

//datachannel启动信号接收处理
void DataChannel::onStartDataChannel(){
    //QTime time;
    qInfo() << "DataChannel onStartDataChannel";
    this->StartDataChannel();
}

//datachannel启动信号接收处理
void DataChannel::onStopDataChannel(){

    qInfo() << "DataChannel onStopDataChannel";
    this->CloseDataChannel();
}

void DataChannel::StartDataChannel(){
    //先关闭
    this->CloseDataChannel();

    //加载日志输出配置信息
    loadLogOutputConfig();

    mState = Ready;
    //加载配置
    QString host = ConfigureSetting::getInstance()->getHost();
    mIsNoCompress = ConfigureSetting::getInstance()->getIsNoCompress();

    mThreadCount = ConfigureSetting::getInstance()->getThreadCount();
    mThreadIndex = 0;

    //创建处理线程
    for(int i = 0;i < mThreadCount;i++){
        QThread *thread = new QThread();
        DataProcess *dp = new DataProcess();
        dp->moveToThread(thread);
        thread->start();
        mDataProcess.push_back(dp);
        mDataProcessThread.push_back(thread);
    }


    int updateInterval = ConfigureSetting::getInstance()->getCheckUpdateInterval();

    //升级程序定时器
    if (!mCheckUpdateProcess){
        mCheckUpdateProcess = new QProcess(this);
        qDebug() << "mCheckUpdateProcess  is null,so to new.";
    }
    if(!mTimerCheckUpdate){
        mTimerCheckUpdate = new QTimer(this);
        qDebug() << "mTimerCheckUpdate  is null,so to new.";
    }
    if(!mTimerReLoadLogLevel){
        mTimerReLoadLogLevel = new QTimer(this);
        qDebug() << "mTimerReLoadLogLevel  is null,so to new.";
    }



    if(mTimerCheckUpdate){
       mTimerCheckUpdate->start(updateInterval*1000);
       qDebug() << "Program will trying to update by " << updateInterval << " s.";
    }else{
       qDebug() << "mTimerCheckUpdate is null,will not to update program.";
    }

    mTimerReLoadLogLevel->start(30000);//30s

    //连接信号和槽函数
    this->connectSignals();

    mStateWebSocket = DisConnected;
    mStateHttp = DisConnected;
    //http初始化
    mHttpRequest.init();
    mHttpRequestNews.init();
    mWebSockectRequest.StartConnection();

    startCheckUpdate();
    qDebug() << "StartDataChannel end.";
}

void DataChannel::CloseDataChannel(){
    mWebSockectRequest.CloseConnection();
    if(mTimerCheckUpdate){
       mTimerCheckUpdate->stop();
    }
    if(mTimerReLoadLogLevel){
       mTimerReLoadLogLevel->stop();
    }


    //处理线程
    QThread *thread;
    DataProcess *dp;
    int threadCount = mDataProcessThread.size();
    for(int i = 0;i < threadCount;i++){
        thread = mDataProcessThread.at(i);

        thread->exit();
        thread->wait();
        delete thread;

        dp = mDataProcess.at(i);
        delete dp;
    }

    mDataProcess.clear();
    mDataProcessThread.clear();

    qDebug() << "CloseDataChannel end.";
}

//加载日志配置
void DataChannel::loadLogOutputConfig(){

    int isOutputLogToFile = ConfigureSetting::getInstance()->getIsOutputLogToFile();
    gLogOutputLevel = ConfigureSetting::getInstance()->getLogOutputLevel();
    if(isOutputLogToFile){
        //重定向日志输出到文件
        qInstallMessageHandler(logMessageOutput);
    }else{
        qInstallMessageHandler(logMessageOutputToStd);
    }

}

void DataChannel::connectSignals(){

    //websocket信号连接
    connect(&mWebSockectRequest,SIGNAL(finishedRecvToChannel(const QByteArray &)),this,SLOT(onFinishedWebSocketReply(const QByteArray &)),Qt::UniqueConnection);
    connect(&mWebSockectRequest, SIGNAL(openToChannel()), this, SLOT(onWebSocketConnected()),Qt::UniqueConnection);
    connect(&mWebSockectRequest, SIGNAL(closeToChannel()), this, SLOT(onWebSocketDisconnected()),Qt::UniqueConnection);
    connect(&mWebSockectRequest, SIGNAL(errorToChannel(QAbstractSocket::SocketError)), this, SLOT(onWebSocketError(QAbstractSocket::SocketError)),Qt::UniqueConnection);
    connect(&mWebSockectRequest, SIGNAL(stateChangeToChannel(int)), this, SLOT(onWebSocketStateChanged(int)),Qt::UniqueConnection);
    connect(&mWebSockectRequest, SIGNAL(reConnectOverMaxToChannel()), this, SLOT(onWebSocketReConnectOverMax()),Qt::UniqueConnection);


    //创建处理线程
    for(int i = 0;i < mThreadCount;i++){
        DataProcess *dp = mDataProcess.at(i);
        connect(dp,SIGNAL(binaryMessageReceived(char*,bool)),dp,SLOT(onBinaryMessageReceived(char*,bool)),Qt::UniqueConnection);
        connect(dp,SIGNAL(message(const QJsonValue)),this,SLOT(onMessage(const QJsonValue)),Qt::UniqueConnection);
    }

    //http信号连接
    connect(&mHttpRequest,SIGNAL(finishedHttpReply(QNetworkReply*)),this,SLOT(onFinishedHttpReply(QNetworkReply*)),Qt::UniqueConnection);
    connect(&mHttpRequest, SIGNAL(openToChannel()), this, SLOT(onHttpConnected()),Qt::UniqueConnection);
    connect(&mHttpRequest, SIGNAL(closeToChannel()), this, SLOT(onHttpDisconnected()),Qt::UniqueConnection);

    //http新闻信号连接
    connect(&mHttpRequestNews,SIGNAL(finishedHttpReply(QNetworkReply*)),this,SLOT(onFinishedHttpReplyNews(QNetworkReply*)),Qt::UniqueConnection);

    //升级程序
    connect(mTimerCheckUpdate,SIGNAL(timeout()), this, SLOT(onTimeOutCheckUpdate()),Qt::UniqueConnection);

    //日志级别检查
    connect(mTimerReLoadLogLevel,SIGNAL(timeout()), this, SLOT(onTimeOutLogLevelUpdate()),Qt::UniqueConnection);


    //测试重连机制
    //connect(mTimerCheckTest,SIGNAL(timeout()), this, SLOT(onTimeOutCheckTest()),Qt::UniqueConnection);
}

void DataChannel::send(const QString &url, const QJsonObject & params)
{
    bool bRet;
    if(mState == Connected){

        if(mStateWebSocket == Connected){
            bRet = mWebSockectRequest.send(url,params);
        } else if(mStateHttp == Connected){
            bRet = mHttpRequest.send(url,params);
        }

        //bRet = mHttpRequest.send(url,params);
    }

}

//通过http，发送个股新闻公告请求
void DataChannel::sendNews(const QString &url)
{
    mHttpRequestNews.sendRequestNews(url);
    QTime time;
    qDebug()<<"DataChannel sendNews " << time.currentTime();
}


void DataChannel::onWebSocketStateChanged(int state){
    /*
    qDebug() << "QWebSocket state changed,now:" << state;
    int lastStateWebSocket = mStateWebSocket;
    mStateWebSocket = state;
    if(mStateWebSocket != lastStateWebSocket){
        //websocket状态变化
        int lastState = mState;
        if(mStateWebSocket == Connected || mStateHttp == Connected){
            mState = Connected;
        } else if (mStateWebSocket == DisConnected && mStateHttp == DisConnected){
            mState = DisConnected;
        }
        if(lastState != mState){
            emit stateChanged();
        }
    }
    */
}

void DataChannel::onWebSocketConnected(){
    qInfo() << "DataChannel onConnected to UI:";
    mStateWebSocket = Connected;
    if(mState != Connected){
        mState = Connected;
        emit open();

    }
}

void DataChannel::onWebSocketDisconnected(){
    QTime time;
    qInfo() << time.currentTime() << "DataChannel onDisconnected:";

    mStateWebSocket = DisConnected;
    if(mStateHttp == DisConnected){
        mState = DisConnected;
        emit close();
        qInfo() << time.currentTime() << "DataChannel onDisconnected to UI:";
    }
}

void DataChannel::onWebSocketReConnectOverMax(){
    qInfo() << "DataChannel onWebSocketReConnectOverMax, emit reconnectfail.";
    this->CloseDataChannel();
    emit reconnectfail();
}



void DataChannel::onWebSocketError(QAbstractSocket::SocketError err){
    //mChannel.close();
    //mState = DisConnected;
    emit error(err);
    QTime time;
    qWarning() << time.currentTime() << "QWebSocket onError:" << err;
}

//连接被触发
void DataChannel::onHttpConnected(){
    /*
    mStateHttp = DataChannel::Connected;
    if(mState != Connected){
        mState = Connected;
        emit open();
        qDebug() << "DataChannel onHttpConnected to UI:";
    }
    */
}

//连接断开被触发
void DataChannel::onHttpDisconnected(){

    QTime time;
    qInfo() << time.currentTime() << "DataChannel onHttpDisconnected:";

    mStateHttp = DataChannel::DisConnected;
    if(mStateWebSocket == DisConnected){
        mState = DisConnected;
        emit close();
        qInfo() << time.currentTime() << "DataChannel onHttpDisconnected to UI:";
    }
}

void DataChannel::onFinishedWebSocketReply(const QByteArray & msg){
    QTime time;
    //qDebug() << "QWebSocket Recv " << time.currentTime();
    bool isParseRight = true;

    dzhyun::UAResponse *ua = new dzhyun::UAResponse;

    if(mIsNoCompress == 0){
        //压缩数据
        std::string uncompressed;
        snappy::Uncompress(msg.data(), msg.size(), &uncompressed);
        //qInfo()<< "DataChannel data1:" << msg.size() << uncompressed.c_str();

        if (!ua->ParseFromString(uncompressed)){
            qWarning() << "DataChannel ParseFromString false.";
            isParseRight = false;
        }
    }else{
        if (!ua->ParseFromArray(msg.data(),msg.size())){
            qWarning() << "DataChannel ParseFromString false.";
            isParseRight = false;
        }
        //qInfo()<< "DataChannel data1:" << msg.size() << msg;
    }

    //分发数据处理到线程
    mThreadIndex++;
    mThreadIndex %= mThreadCount;

    int index = mThreadIndex;
    if(index >= mThreadCount){
        index--;
    }

    if(isParseRight) {
        if (mQidMap.contains(ua->qid())){
            index = mQidMap.value(ua->qid());
            //qDebug() << "DataChannel find qid"<< index;
        }else{
            //qDebug() << "DataChannel put qid"<<ua->qid().c_str()<< index;
            mQidMap.insert(ua->qid(),index);
        }
    }

    //qDebug() << "DataChannel onBinaryMessageReceived put to thread" << index<<isParseRight<<ua->data().length();
    emit mDataProcess.at(index)->binaryMessageReceived((char*)ua,isParseRight);
}

void DataChannel::onFinishedHttpReply(QNetworkReply* reply)
{

    QByteArray data = reply->readAll();
    //这里会输出百度首页的HTML网页代码
    //qDebug() << "replyFinished " << data;
    //分发数据处理到线程
    mThreadIndex++;
    mThreadIndex %= mThreadCount;

    int index = mThreadIndex;
    if(index >= mThreadCount){
        index--;
    }
    //qDebug() << "DataChannel onBinaryMessageReceived put to thread" << index;
    //http暂时未用
    //emit mDataProcess.at(index)->binaryMessageReceived(data);
}

QByteArray  intToByte(int i){
    QByteArray abyte0;
    abyte0.resize(4);
    abyte0[0] = (uchar)  (0x000000ff & i);
    abyte0[1] = (uchar) ((0x0000ff00 & i) >> 8);
    abyte0[2] = (uchar) ((0x00ff0000 & i) >> 16);
    abyte0[3] = (uchar) ((0xff000000 & i) >> 24);
    return abyte0;
}

void DataChannel::onFinishedHttpReplyNews(QNetworkReply* reply)
{
    QTime time;
    qDebug()<<"DataChannel onFinishedHttpReplyNews " << time.currentTime() << " Start.";
    time.start();

    QByteArray dataComp = reply->readAll();
    int headLen = 102400;
    QByteArray dataHead;
    dataHead.append(intToByte(headLen));
    dataHead.append(dataComp);

    QByteArray data = qUncompress(dataHead);

    //转成gbk格式
    QTextCodec *gbk = QTextCodec::codecForName("gb18030");
    QString strNews = gbk->toUnicode(data);

    emit messageNews(strNews);

    int workMilliSeconds = time.elapsed();
    qDebug() <<"DataChannel onFinishedHttpReplyNews " << "Stop, work for " << workMilliSeconds << "ms.";
}

//线程处理完数据后触发
void DataChannel::onMessage(const QJsonValue data){
    emit message(data);
}

int DataChannel::getState(){
    return mState;
}

QString DataChannel::getHost(){
    return ConfigureSetting::getInstance()->getHost();
}

QString DataChannel::getConfigValue(QString parent,QString key){
    return ConfigureSetting::getInstance()->getConfigValue(parent,key);
}

QString DataChannel::getToken(){
    return GenerateToken::getInstance().getToken();
}

quint64 DataChannel::getMachineId(){
    quint64 retMachineId;
    QString  strMac;
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();//获取所有网卡信息
    foreach(QNetworkInterface iface,ifaces){
        if ( !iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            //获取当前有效网卡
            strMac = iface.hardwareAddress();
            if (!strMac.isEmpty()){
                qDebug() << "First getMachineId mac:" << strMac;
                break;
            }
        }
    }

    //获取失败，返回一个随机数
    if(strMac.isEmpty()) {
        qsrand(QTime(0, 0, 0).secsTo(QTime::currentTime()));
        retMachineId = qrand();
        qInfo() << "get getMachineId err,so return rand:" << retMachineId;
    } else {
        QString str2 = strMac.replace(QRegExp(":"), "");
        bool ok;
        retMachineId = str2.toLongLong(&ok,16);
        qDebug()<< "get mac:"<<str2<<" return:"<<retMachineId;
    }

    return retMachineId;
}

//qml中可以调用该函数设置用户信息，读取配置文件时，根据用户信息读取相应配置文件
void DataChannel::setUserInfo(QString userinfo){
    mUserName = userinfo;
    ConfigureSetting::getInstance()->setSettingUserInfo(userinfo);
}

//qml中可以调用该函数设置传输时附带的用户token，暂时未生效
void DataChannel::setUserToken(QString token){
    mUserToken = token;
}

void DataChannel::startCheckUpdate(){
    //定时调用升级程序
    QString program = "./dzhtool.exe";
    QStringList arguments;
    arguments << "-f" << "./dzhupdatedown.lua";
    if(mCheckUpdateProcess){
        mCheckUpdateProcess->start(program, arguments);
        qDebug() << "Program trying to update now.";
    }
}

void DataChannel::onTimeOutCheckUpdate(){
    qInfo() << "Program trying to update.";
#ifdef Q_OS_WIN32
    qInfo() << "Program trying to update on win32.";
    startCheckUpdate();
#endif

#ifdef Q_OS_WIN64
    qInfo() << "Program trying to update on win64.";
    startCheckUpdate();
#endif

#ifdef Q_OS_MAC
    //qInfo << "Program will not trying to update on mac.";
#endif

#ifdef Q_OS_LINUX
    //qInfo << "Program will not trying to update on linux.";
#endif

}

int gTimeOutCount = 0;
void DataChannel::onTimeOutCheckTest(){

    qInfo()<<"timeoutcount:"<<gTimeOutCount;
    if(gTimeOutCount%60 == 0){
        this->onStopDataChannel();
        qInfo()<<"main: stop";
    } else if(gTimeOutCount%60 == 30){
        this->onStartDataChannel();
        qInfo()<<"main: start";
    }
    gTimeOutCount++;
}

void DataChannel::onTimeOutLogLevelUpdate(){
    gLogOutputLevel = ConfigureSetting::getInstance()->getLogOutputLevel();
}
