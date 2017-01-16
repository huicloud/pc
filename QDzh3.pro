TEMPLATE = app

QT += qml quick websockets webengine
CONFIG += c++11 warn_off
#DEFINES += PROTOBUF_USE_DLLS
#DEPENDPATH += google/install/lib

INCLUDEPATH +=/usr/local/include \
    google/install/include \
    src/cpp \
    src/cpp/snappy

RESOURCES += src/qml/main.qrc \
    src/qml/dzh.qrc \
    src/resources/js/js.qrc \
    src/resources/images/images.qrc \
    src/resources/font/font.qrc

mac: LIBS += -L /usr/local/lib -lprotobuf
#win32: LIBS += -L$$_PRO_FILE_PWD_/google/install/lib/ -llibprotobuf
win32:CONFIG(release, debug|release): LIBS += -L$$_PRO_FILE_PWD_/google/install/lib-win32-release -llibprotobuf -lUser32
else:win32:CONFIG(debug, debug|release): LIBS += -L$$_PRO_FILE_PWD_/google/install/lib-win32-debug -llibprotobufd -lUser32
win32: RC_FILE += dzh_win.rc
mac {
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.9
    QMAKE_INFO_PLIST = src/resources/info.plist
    ICON = src/resources/images/dzh.icns
    TARGET = QDZH3
}
# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    src/cpp/datachannel.h \
    src/cpp/dataprocess.h \
    src/cpp/generatetoken.h \
    src/cpp/yfloat.h \
    src/cpp/httprequest.h \
    src/cpp/logmessagehandler.h \
    src/cpp/websocketrequest.h \
    src/cpp/qframelesswindow.h \
    src/cpp/dzhurlschemehandler.h \
    src/cpp/dzhwebengineprofile.h \
    src/cpp/tablemodel.h \
    src/cpp/treemodel.h \
    src/cpp/applauncher.h \
    src/cpp/version.h \
    src/cpp/dzhmainwindow.h \
    src/cpp/singletonapplication.h \
    src/cpp/snappy/snappy-c.h \
    src/cpp/snappy/snappy-internal.h \
    src/cpp/snappy/snappy-sinksource.h \
    src/cpp/snappy/snappy-stubs-internal.h \
    src/cpp/snappy/snappy.h \
    src/cpp/snappy/snappy-stubs-public.h \
    src/cpp/snappystream.h \
    src/cpp/configuresetting.h \
    src/cpp/filesetting.h \
    src/cpp/singleton/requesturlmap.h \
    src/cpp/proto/CldDanShangPinShuXing.pb.h \
    src/cpp/proto/CldF10ShuJu.pb.h \
    src/cpp/proto/CldForecastsShuJu.pb.h \
    src/cpp/proto/CldNewsShuJu.pb.h \
    src/cpp/proto/CldSanBanData.pb.h \
    src/cpp/proto/dzh.block.pb.h \
    src/cpp/proto/dzhNewsInfo.pb.h \
    src/cpp/proto/dzhoutput.pb.h \
    src/cpp/proto/dzhpbtable.pb.h \
    src/cpp/proto/dzhtoken.pb.h \
    src/cpp/proto/dzhua.pb.h \
    src/cpp/proto/dzhyun.blockstatistics.pb.h \
    src/cpp/proto/dzhyun.counter.pb.h \
    src/cpp/proto/dzhyun.dxspirit.pb.h \
    src/cpp/proto/dzhyun.gupiaolianxu.pb.h \
    src/cpp/proto/dzhyun.gupiaoqiepian.pb.h \
    src/cpp/proto/dzhyun.historytrends.pb.h \
    src/cpp/proto/dzhyun.hkdyna.pb.h \
    src/cpp/proto/dzhyun.jianpanbao.pb.h \
    src/cpp/proto/dzhyun.paixu.pb.h \
    src/cpp/proto/dzhyun.pc.selfstocksync.pb.h \
    src/cpp/proto/dzhyun.stkdata.pb.h \
    src/cpp/proto/dzhyun.topicinvest.pb.h \
    src/cpp/proto/dzhyun.xuangu.pb.h \
    src/cpp/proto/dzhyun.zhibiao.pb.h \
    src/cpp/proto/dzhyun.zhibiaojisuan.pb.h \
    src/cpp/proto/dzhyun.zhubi.pb.h \
    src/cpp/proto/MSG.pb.h \
    src/cpp/proto/dzhyun.user.prop.pb.h \
    src/cpp/proto/dzhyun.sysmsg.pb.h


SOURCES += \
    src/cpp/datachannel.cpp \
    src/cpp/dataprocess.cpp \
    src/cpp/generatetoken.cpp \
    src/cpp/main.cpp \
    src/cpp/pb2json.cpp \
    src/cpp/table2json.cpp \
    src/cpp/httprequest.cpp \
    src/cpp/websocketrequest.cpp \
    src/cpp/qframelesswindow.cpp \
    src/cpp/dzhurlschemehandler.cpp \
    src/cpp/dzhwebengineprofile.cpp \
    src/cpp/tablemodel.cpp \
    src/cpp/treemodel.cpp \
    src/cpp/applauncher.cpp \
    src/cpp/dzhmainwindow.cpp \
    src/cpp/singletonapplication.cpp \
    src/cpp/snappy/snappy-c.cc \
    src/cpp/snappy/snappy-sinksource.cc \
    src/cpp/snappy/snappy-stubs-internal.cc \
    src/cpp/snappy/snappy.cc \
    src/cpp/snappystream.cpp \
    src/cpp/configuresetting.cpp \
    src/cpp/filesetting.cpp \
    src/cpp/singleton/requesturlmap.cpp \
    src/cpp/proto/CldDanShangPinShuXing.pb.cc \
    src/cpp/proto/CldF10ShuJu.pb.cc \
    src/cpp/proto/CldForecastsShuJu.pb.cc \
    src/cpp/proto/CldNewsShuJu.pb.cc \
    src/cpp/proto/CldSanBanData.pb.cc \
    src/cpp/proto/dzh.block.pb.cc \
    src/cpp/proto/dzhNewsInfo.pb.cc \
    src/cpp/proto/dzhoutput.pb.cc \
    src/cpp/proto/dzhpbtable.pb.cc \
    src/cpp/proto/dzhtoken.pb.cc \
    src/cpp/proto/dzhua.pb.cc \
    src/cpp/proto/dzhyun.blockstatistics.pb.cc \
    src/cpp/proto/dzhyun.counter.pb.cc \
    src/cpp/proto/dzhyun.dxspirit.pb.cc \
    src/cpp/proto/dzhyun.gupiaolianxu.pb.cc \
    src/cpp/proto/dzhyun.gupiaoqiepian.pb.cc \
    src/cpp/proto/dzhyun.historytrends.pb.cc \
    src/cpp/proto/dzhyun.hkdyna.pb.cc \
    src/cpp/proto/dzhyun.jianpanbao.pb.cc \
    src/cpp/proto/dzhyun.paixu.pb.cc \
    src/cpp/proto/dzhyun.pc.selfstocksync.pb.cc \
    src/cpp/proto/dzhyun.stkdata.pb.cc \
    src/cpp/proto/dzhyun.topicinvest.pb.cc \
    src/cpp/proto/dzhyun.xuangu.pb.cc \
    src/cpp/proto/dzhyun.zhibiao.pb.cc \
    src/cpp/proto/dzhyun.zhibiaojisuan.pb.cc \
    src/cpp/proto/dzhyun.zhubi.pb.cc \
    src/cpp/proto/MSG.pb.cc \
    src/cpp/proto/dzhyun.user.prop.pb.cc \
    src/cpp/proto/dzhyun.sysmsg.pb.cc
FORMS +=

DISTFILES += \
    dzh_win.rc
