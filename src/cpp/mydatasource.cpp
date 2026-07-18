#include "mydatasource.h"
#include <QDebug>
#include <QDateTime>
#include <QNetworkInterface>
#include <QTime>
#include <QRandomGenerator>

// ============================================================
// 字段映射表：你的数据源字段名 -> 大智慧字段名
// 在 mapField() 中使用：把你的 API 返回对象按此表转换成 DZH 格式
// ============================================================
static const struct { const char *from; const char *to; } sFieldMap[] = {
    // ===== 行情快照 / 列表 =====
    { "code",               "Obj" },
    { "name",               "ZhongWenJianCheng" },
    { "price",              "ZuiXinJia" },
    { "pct",                "ZhangFu" },
    { "change",             "ZhangDie" },
    { "preClose",           "ZuoShou" },
    { "volume",             "ChengJiaoLiang" },
    { "amount",             "ChengJiaoE" },
    { "turnoverRate",       "HuanShouLv" },
    { "amplitude",          "ZhenFu" },
    { "high",               "ZuiGaoJia" },
    { "low",                "ZuiDiJia" },
    { "open",               "KaiPanJia" },
    { "precision",          "XiaoShuWei" },
    { "type",               "LeiXing" },
    { "volumeUnit",         "ChengJiaoLiangDanWei" },
    { "floatShare",         "LiuTongAGu" },
    { "rzrqFlag",           "RongZiRongQuanBiaoJi" },
    { "speed5min",          "FenZhongZhangFu5" },

    // ===== K线 =====
    { "time",               "ShiJian" },
    { "openPrice",          "KaiPanJia" },
    { "highPrice",          "ZuiGaoJia" },
    { "lowPrice",           "ZuiDiJia" },
    { "closePrice",         "ShouPanJia" },

    // ===== 分时 =====
    { "avgPrice",           "JunJia" },
    { "leadIndex",          "LingXianZhiBiao" },
    { "tradePrice",         "ChengJiaoJia" },

    // ===== 逐笔 / 盘口 =====
    { "tradeTime",          "ShiJian" },
    { "tradeVol",           "Liang" },
    { "totalVol",           "ZongLiang" },
    { "orderCount",         "BiShu" },
    { "direction",          "FangXiang" },
    { "queuePrice",         "Jia" },

    // ===== 资金流 =====
    { "inflow",             "LiuRu" },
    { "outflow",            "LiuChu" },
    { "netInflow",          "JingLiuRu" },

    // ===== 财务 / F10 =====
    { "revenue",            "ZhuYingShouRu" },
    { "opProfit",           "ZhuYingLiRun" },
    { "totalProfit",        "LiRunZongE" },
    { "netProfit",          "JingLiRun" },
    { "operCashFlow",       "JingYingXianJinLiuLiang" },
    { "investCashFlow",     "TouZiXianJinLiuLiang" },
    { "finanCashFlow",      "ChouZiXianJinLiuLiang" },
    { "cashIncrease",       "XianJinZengJiaE" },
    { "totalShare",         "ZongGuBen2" },
    { "equity",             "GuDongQuanYi" },
    { "capitalReserve",     "ZiBenGongJiJin" },
    { "listDate",           "ShangShiRiQi" },

    // ===== 基金 =====
    { "reportDate",         "JJBaoGaoQi" },
    { "fundCode",           "JJJiJinDaiMa" },
    { "netAsset",           "JJQiMoZiChanJingZhi" },
    { "stockValue",         "JJGuPiaoShiZhi" },
    { "stockRatio",         "JJGuPiaoBiLi" },

    // ===== 股票基础信息（getStockInfo 用）=====
    { "financing",          "RongZiRongQuanBiaoJi" },
    { "share",              "LiuTongAGu" },
    { "lastClose",          "ZuoShou" },
};
static const int sFieldMapCount = sizeof(sFieldMap) / sizeof(sFieldMap[0]);

// ============================================================
MyDataSource::MyDataSource(QObject *parent)
    : QObject(parent)
    , mState(DisConnected)
    , mHeartBeat(0)
    , mMockTimer(nullptr)
{
    initFieldMap();
}

MyDataSource::~MyDataSource()
{
    if (mMockTimer) {
        mMockTimer->stop();
        delete mMockTimer;
    }
}

void MyDataSource::initFieldMap()
{
    for (int i = 0; i < sFieldMapCount; i++) {
        mFieldMap.insert(sFieldMap[i].from, sFieldMap[i].to);
    }
}

// ============================================================
// QML 调用的属性接口
// ============================================================
int MyDataSource::getState() { return mState; }

QString MyDataSource::getHost() { return QStringLiteral("127.0.0.1"); }

QString MyDataSource::getToken() { return QStringLiteral("mock-token"); }

quint64 MyDataSource::getMachineId()
{
    quint64 ret = 0;
    QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();
    foreach (QNetworkInterface iface, ifaces) {
        if (!iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            QString mac = iface.hardwareAddress();
            if (!mac.isEmpty()) {
                QString str2 = mac.replace(QStringLiteral(":"), QString());
                bool ok = false;
                ret = str2.toLongLong(&ok, 16);
                if (ok) return ret;
            }
        }
    }
    return QRandomGenerator::global()->generate();
}

void MyDataSource::setUserInfo(QString userinfo) { mUserInfo = userinfo; }
void MyDataSource::setUserToken(QString token)  { mUserToken = token; }

QString MyDataSource::getConfigValue(QString parent, QString key)
{
    Q_UNUSED(parent);
    Q_UNUSED(key);
    return QString();
}

// ============================================================
// 启动 / 关闭
// ============================================================
void MyDataSource::onStartDataChannel()
{
    qInfo() << "MyDataSource onStartDataChannel";
    mState = Connected;
    emit open();

    // 准备一些 Mock 股票数据，方便 UI 直接看到效果
    mMockStocks.clear();
    const char *codes[]  = {"SH600000","SH600036","SH600519","SH601318","SH601398",
                            "SZ000001","SZ000858","SZ002415","SZ300750","SZ000333"};
    const char *names[]  = {"浦发银行","招商银行","贵州茅台","中国平安","工商银行",
                            "平安银行","五粮液","海康威视","宁德时代","美的集团"};
    double  pre[]        = {8.50, 35.20, 1800.0, 45.0, 5.20,  12.0, 150.0, 35.0, 200.0, 60.0};

    for (int i = 0; i < 10; i++) {
        MockStock s;
        s.code = codes[i];
        s.name = names[i];
        s.preClose = pre[i];
        s.price    = pre[i] * (1.0 + (i % 5 - 2) * 0.01);
        s.change   = s.price - s.preClose;
        s.pct      = s.change / s.preClose * 100.0;
        s.volume   = 1000000 + i * 500000;
        s.amount   = s.volume * s.price;
        s.precision = 2;
        mMockStocks.append(s);
    }

    // Mock 定时刷新：每秒推送一次行情，模拟实时数据
    if (!mMockTimer) {
        mMockTimer = new QTimer(this);
        connect(mMockTimer, &QTimer::timeout, this, &MyDataSource::onTickMock);
    }
    mMockTimer->start(1000);
}

void MyDataSource::onStopDataChannel()
{
    qInfo() << "MyDataSource onStopDataChannel";
    if (mMockTimer) mMockTimer->stop();
    mState = DisConnected;
    emit close();
}

// ============================================================
// 模拟实时行情推送（订阅模式）
// ============================================================
void MyDataSource::onTickMock()
{
    mHeartBeat++;

    for (int i = 0; i < mMockStocks.size(); i++) {
        MockStock &s = mMockStocks[i];
        double delta = (QRandomGenerator::global()->generateDouble() - 0.5) * 0.02 * s.preClose;
        s.price += delta;
        s.change = s.price - s.preClose;
        s.pct    = s.change / s.preClose * 100.0;
        s.volume += QRandomGenerator::global()->bounded(10000, 50000);
        s.amount  = s.volume * s.price;
    }

    // 这里不主动 emit message（订阅由 send 时的 sub=1 标记来建立）
    // 真正实现时应该维护一个订阅列表，定期推送
}

// ============================================================
// 主入口：QML 通过 Channel.send(url, params) 调用
// ============================================================
void MyDataSource::send(const QString &url, const QJsonObject &params)
{
    if (mState != Connected) return;

    QString qid = params.value("qid").toString();
    QJsonValue result;
    int err = 0;
    int objCount = 0;
    int counter = mHeartBeat;

    // 根据 serviceUrl 分发到不同的处理函数
    if (url == QStringLiteral("/stkdata")) {
        result = handleStkData(params);
        objCount = result.toObject().value("data").toArray().size();
    } else if (url == QStringLiteral("/kline")) {
        result = handleKline(params);
        objCount = result.toArray().size();
    } else if (url == QStringLiteral("/ztrend")) {
        result = handleZTrend(params);
        objCount = result.toArray().size();
    } else if (url == QStringLiteral("/block")) {
        result = handleBlock(params);
        objCount = result.toArray().size();
    } else if (url == QStringLiteral("/tick")) {
        result = handleTick(params);
        objCount = result.toArray().size();
    } else if (url == QStringLiteral("/stockinfo")) {
        result = handleStockInfo(params);
        objCount = 1;
    } else {
        // 未实现的接口，返回空
        result = QJsonValue();
        err = 99;
        qWarning() << "MyDataSource: unsupported url" << url;
    }

    QJsonObject resp = buildResponse(qid, result, err, counter, objCount);
    emit message(resp);
}

void MyDataSource::sendNews(const QString &url)
{
    Q_UNUSED(url);
    emit messageNews(QStringLiteral("<html><body><p>Mock News Content</p></body></html>"));
}

// ============================================================
// 构造统一响应格式
// ============================================================
QJsonObject MyDataSource::buildResponse(const QString &qid,
                                         const QJsonValue &data,
                                         int err, int counter, int objCount)
{
    QJsonObject obj;
    obj["Qid"]      = qid;
    obj["Err"]      = err;
    obj["Counter"]  = counter;
    obj["ObjCount"] = objCount;
    obj["Data"]     = data;
    return obj;
}

// 构造表格格式（JsonTbl），这是 /stkdata 等列表接口 QML 期望的格式
QJsonObject MyDataSource::makeJsonTbl(const QJsonArray &head, const QJsonArray &data)
{
    QJsonObject tbl;
    tbl["head"] = head;
    tbl["data"] = data;
    QJsonObject wrapper;
    wrapper["JsonTbl"] = tbl;
    return wrapper;
}

// ============================================================
// 字段映射：把你自己的 API 返回对象转成大智慧字段名
// ============================================================
QJsonObject MyDataSource::mapField(const QJsonObject &src)
{
    QJsonObject dst;
    for (auto it = src.begin(); it != src.end(); ++it) {
        QString key = it.key();
        QString mappedKey = mFieldMap.value(key, key);
        dst[mappedKey] = it.value();
    }
    return dst;
}

// ============================================================
// 各个 serviceUrl 的处理
// ============================================================

// /stkdata —— 行情列表 / 快照
QJsonValue MyDataSource::handleStkData(const QJsonObject &params)
{
    Q_UNUSED(params);

    QJsonArray head = {
        "Obj", "ZhongWenJianCheng", "ZuiXinJia", "ZhangFu", "ZhangDie",
        "KaiPanJia", "ZuiGaoJia", "ZuiDiJia", "ChengJiaoLiang", "ChengJiaoE",
        "ZuoShou", "XiaoShuWei", "LeiXing", "FenZhongZhangFu5"
    };

    QJsonArray data;
    for (const MockStock &s : mMockStocks) {
        QJsonArray row = {
            s.code, s.name, s.price, s.pct, s.change,
            s.preClose * 1.001, s.price * 1.02, s.price * 0.98, s.volume, s.amount,
            s.preClose, s.precision, 1, s.pct * 0.2
        };
        data.append(row);
    }

    return makeJsonTbl(head, data);
}

// /kline —— K线
QJsonValue MyDataSource::handleKline(const QJsonObject &params)
{
    Q_UNUSED(params);
    QJsonArray result;

    // 生成最近 60 根日K
    qint64 baseTime = QDateTime::currentSecsSinceEpoch() - 60 * 86400LL;
    double basePrice = 100.0;

    for (int i = 0; i < 60; i++) {
        double open  = basePrice + (QRandomGenerator::global()->generateDouble() - 0.5) * 5;
        double close = open + (QRandomGenerator::global()->generateDouble() - 0.5) * 6;
        double high  = qMax(open, close) + QRandomGenerator::global()->generateDouble() * 3;
        double low   = qMin(open, close) - QRandomGenerator::global()->generateDouble() * 3;
        double vol   = 100000 + QRandomGenerator::global()->bounded(500000);

        QJsonObject bar;
        bar["ShiJian"]     = (qint64)(baseTime + i * 86400LL);
        bar["KaiPanJia"]   = open;
        bar["ZuiGaoJia"]   = high;
        bar["ZuiDiJia"]    = low;
        bar["ShouPanJia"]  = close;
        bar["ChengJiaoLiang"] = vol;
        bar["ChengJiaoE"]  = vol * close;
        bar["lastClose"]   = basePrice;
        result.append(bar);

        basePrice = close;
    }
    return result;
}

// /ztrend —— 分时
QJsonValue MyDataSource::handleZTrend(const QJsonObject &params)
{
    Q_UNUSED(params);
    QJsonArray result;

    qint64 baseTime = QDateTime::currentDateTime().toTime_t();
    baseTime -= (baseTime % 300);
    double lastClose = 100.0;

    for (int i = 0; i < 48; i++) {
        double price = lastClose * (1.0 + (QRandomGenerator::global()->generateDouble() - 0.5) * 0.02);
        double avg   = lastClose * (1.0 + (QRandomGenerator::global()->generateDouble() - 0.5) * 0.01);
        double vol   = 10000 + QRandomGenerator::global()->bounded(50000);

        QJsonObject bar;
        bar["ShiJian"]       = (qint64)(baseTime + i * 300);
        bar["ZuiXinJia"]     = price;
        bar["JunJia"]        = avg;
        bar["ChengJiaoLiang"] = vol;
        bar["ChengJiaoE"]    = vol * price;
        bar["lastClose"]     = lastClose;
        result.append(bar);
    }
    return result;
}

// /block —— 板块列表
QJsonValue MyDataSource::handleBlock(const QJsonObject &params)
{
    Q_UNUSED(params);
    QJsonArray head = {"Obj", "ZhongWenJianCheng", "ZhangFu", "ChengJiaoE"};
    QJsonArray data;

    const char *names[] = {"银行板块","证券板块","科技板块","医药板块","新能源板块",
                           "消费板块","房地产板块","军工板块","煤炭板块","钢铁板块"};
    for (int i = 0; i < 10; i++) {
        QJsonArray row = {
            QString("BK%1").arg(i + 1, 4, 10, QChar('0')),
            names[i],
            (QRandomGenerator::global()->generateDouble() - 0.5) * 6.0,
            (double)QRandomGenerator::global()->bounded(1000000, 10000000)
        };
        data.append(row);
    }
    return makeJsonTbl(head, data);
}

// /tick —— 逐笔
QJsonValue MyDataSource::handleTick(const QJsonObject &params)
{
    Q_UNUSED(params);
    QJsonArray result;
    qint64 baseTime = QDateTime::currentSecsSinceEpoch();
    double basePrice = 100.0;

    for (int i = 0; i < 20; i++) {
        QJsonObject tick;
        tick["ShiJian"] = (qint64)(baseTime - i * 5);
        tick["JiaGe"]   = basePrice + (QRandomGenerator::global()->generateDouble() - 0.5) * 0.5;
        tick["Liang"]   = (double)QRandomGenerator::global()->bounded(10, 500);
        tick["FangXiang"] = QRandomGenerator::global()->bounded(0, 2);
        result.append(tick);
    }
    return result;
}

// /stockinfo —— 股票基础信息（对应 StockUtil.getStock）
QJsonValue MyDataSource::handleStockInfo(const QJsonObject &params)
{
    QString obj = params.value("obj").toString();
    QJsonObject info;

    info["Obj"] = obj;
    info["ZhongWenJianCheng"] = QStringLiteral("示例股票");
    info["LeiXing"] = 1;
    info["RongZiRongQuanBiaoJi"] = 1;
    info["ChengJiaoLiangDanWei"] = 100;
    info["LiuTongAGu"] = 100000;
    info["XiaoShuWei"] = 2;
    info["ZuoShou"] = 10.0;

    return info;
}
