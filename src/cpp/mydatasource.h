#ifndef MYDATASOURCE_H
#define MYDATASOURCE_H

#include <QObject>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QString>
#include <QMap>
#include <QTimer>

class MyDataSource : public QObject
{
    Q_OBJECT
    Q_ENUMS(State)

public:
    enum State {
        Ready,
        Connecting,
        Connected,
        DisConnected
    };

    explicit MyDataSource(QObject *parent = nullptr);
    ~MyDataSource();

    Q_INVOKABLE int getState();
    Q_INVOKABLE QString getHost();
    Q_INVOKABLE QString getToken();
    Q_INVOKABLE quint64 getMachineId();
    Q_INVOKABLE void setUserInfo(QString userinfo);
    Q_INVOKABLE void setUserToken(QString token);
    Q_INVOKABLE QString getConfigValue(QString parent, QString key);

signals:
    void message(const QJsonValue data);
    void open();
    void close();
    void reconnectfail();
    void error(int err);
    void stateChanged();
    void startDataChannel();
    void stopDataChannel();
    void messageNews(const QString data);

public slots:
    void send(const QString &url, const QJsonObject &params);
    void sendNews(const QString &url);
    void onStartDataChannel();
    void onStopDataChannel();

private slots:
    void onTickMock();

private:
    void initFieldMap();
    QJsonObject buildResponse(const QString &qid, const QJsonValue &data, int err = 0, int counter = 0, int objCount = 0);
    QJsonObject makeJsonTbl(const QJsonArray &head, const QJsonArray &data);

    QJsonValue handleStkData(const QJsonObject &params);
    QJsonValue handleKline(const QJsonObject &params);
    QJsonValue handleZTrend(const QJsonObject &params);
    QJsonValue handleBlock(const QJsonObject &params);
    QJsonValue handleTick(const QJsonObject &params);
    QJsonValue handleStockInfo(const QJsonObject &params);

    QJsonObject mapField(const QJsonObject &src);

    int mState;
    int mHeartBeat;
    QString mUserInfo;
    QString mUserToken;
    QMap<QString, QString> mFieldMap;
    QTimer *mMockTimer;

    struct MockStock {
        QString code;
        QString name;
        double preClose;
        double price;
        double change;
        double pct;
        double volume;
        double amount;
        int precision;
    };
    QList<MockStock> mMockStocks;

    QMap<QString, QList<double>> mKlineCache;
};

#endif
