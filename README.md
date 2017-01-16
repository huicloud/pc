大智慧舵手版
===========
大智慧舵手版是上海大智慧股份有限公司推出新一代的行情软件，依托于大智慧云平台提供的行情服务，是一套轻、快、精的跨平台的轻客户端软件。

下载体验[大智慧舵手版](http://downfile.gw.com.cn/pub/dsb/Qdzh.exe)

## 环境准备

### 1、开发工具
在Windows中需要下载并安装[VS Express 2013 for Desktop](https://download.microsoft.com/download/4/4/E/44ED2754-ABC4-443F-812B-42AFEF04D478/vs2013.5_dskexp_CHS.iso)以及[qt-opensource-windows-x86-msvc2013-5.7.0](http://download.qt.io/official_releases/qt/5.7/5.7.0/qt-opensource-windows-x86-msvc2013-5.7.0.exe)。如果你需要调试，还需要根据你的操作系统环境下载安装[wdksetup.exe](https://developer.microsoft.com/zh-cn/windows/hardware/windows-driver-kit)。  

在macOS中只需要安装[qt-opensource-mac-x64-clang-5.7.0](http://download.qt.io/official_releases/qt/5.7/5.7.0/qt-opensource-mac-x64-clang-5.7.0.dmg)即可。

### 2、Protobuf的编译
1) 在Windows系统中使用Microsoft Visual C++编译方式详见[https://github.com/google/protobuf/blob/master/cmake/README.md](https://github.com/google/protobuf/blob/master/cmake/README.md)
   > 为了顺利完成Protobuf的编译，需要先安装VS Express 2013 for Desktop。
    生成x86目标平台的VS Solution的cmake的参数是cmake -G "Visual Studio 12 2013"，加Win64表示支持64位系统。  
    同时需要在VS的Solution的Properties->Configuration Properties->C/C++->Code Generation->Runtime Library设置为/MD(release)/MDd(debug)。
2) 在Unix（macOS）系统中编译，详见[https://github.com/google/protobuf/blob/master/src/README.md](https://github.com/google/protobuf/blob/master/src/README.md)

## 发布部署
部署时需要用到的相关文件均已放在`Deployment`文件夹中。

1) `dzhyun.ini`。相关功能的配置说明  
```ini
[DzhYun]  
yuntype=1 //1是alpha，2是beta      
service=10.15.208.66 //服务器地址    
isNoCompress=1 //0请求数据是压缩数据，1数据未压缩  
heartTime=3 //websocket心跳时间，秒 
threadCount=10 //数据处理线程个数    
checkUpdateInterval=24 //检查升级间隔，小时
[WEB]
webHost=10.15.208.88  //web页面相关服务地址   
[DzhLog]    
isOutputLogToFile=1 //是否输出日志到文件     
logOutputLevel=2 //0-4 (debug,warning,critical,fatal,info)日志级别  
[DzhClient]     
isSoftwareOpenGL=0 //浏览器兼容配置，默认为0，有问题调成1
```

2) `PDFViewer `放的是[mozilla/pdf.js](https://github.com/mozilla/pdf.js)这个PDF预览组件，需要和最终生成的QDzh3.exe放在相同目录中（Mac版，则需要放在`QDZH3.app/Contents/Resources`中）。
3) `libEGL.dll`、`libGLESV2.dll`、`libGLESV2.dll`这三个dll使用的是Qt5.6中带的库，5.7的版本会是程序在运行时有明细的黑屏情况。
4) `msvcp120.dll`、`msvcp120.dll`为Windows系统中所需的VC++的运行库。   

由于QtCreator在Windows中的Debug速度很慢，基本都在Release中进行开发，故将在Windows中部署单独使用脚本处理:   
> `C:\Qt\Qt5.7.0\5.7\msvc2013\bin\windeployqt.exe -qmldir C:\Qt\Qt5.7.0\5.7\msvc2013\qml  QDzh3.exe`  

由于Qt的部署工具还未完善，上述命令处理后，除了需要Deployment中需要的文件之外，还需要手动从`C:\Qt\Qt5.7.0\5.7\msvc2013\qml`将`QtWebEngine`、`QtQuick`、`QtGraphicalEffects`这三个文件复制到部署目录中（完全覆盖即可）。更多内容详见官方文档[windows-deployment](http://doc.qt.io/qt-5/windows-deployment.html)。  
macOS中部署相对简单些。首先在QtCreator的项目Release版本的设置中增加自定义构建步骤，具体方法详见Qt官方文档[osx-deployment](http://doc.qt.io/qt-5/osx-deployment.html)，同时也需要手工复制源码下的`QtGraphicalEffects`、`QtWebEngine`至`QDZH3.app/Contents/Resources/qml`中。更多发布操作参见Apple官方文档[App Distribution Quick Start](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppStoreDistributionTutorial/Introduction/Introduction.html#//apple_ref/doc/uid/TP40013839)。

## 授权
客户端的数据均来自[大智慧金融信息云](http://yun.gw.com.cn/index.html)，要让客户端能够正确展示行情，首先需要获取大智慧金融信息云的相关授权，将获取到的appid和secretkey替换`generatetoken.cpp`中对应字段即可
```c++
void GenerateToken::init()
{
    QDateTime date;
    date = date.currentDateTime();
    this->token_expired_time = date.toTime_t();

    int mType = ConfigureSetting::getInstance()->getDzhYunType();
    qInfo()<< "DzhYun/yuntype:"<< mType;
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
```

## 登录
目前已实现支持大智慧账号、QQ以及微信账号的登录，开源版本中账号相关部分已使用模拟数据（可以通过搜索"TODO 账号"定位相关逻辑）替换，任意账号均可登录。如果需要接入自己的账号系统，请根据自身的业务规则修改对应的流程
