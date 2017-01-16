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

#ifndef TABLEMODEL_H
#define TABLEMODEL_H
#include <QAbstractListModel>
#include <QStringList>
#include <QMap>
#include <QMutex>
#include <iterator>
#include <QQmlContext>

class QStock
{
public:
    QStock();
    QStock(const QJsonObject &item);
    QStock(const QString &Head,
           const QString &XuHao,
           const QString &Obj,
           const QString &ZhongWenJianCheng,
           const QString &ZuiXinJia,
           const QString &ZhangDie,
           const QString &ZhangFu,
           const QString &ChengJiaoLiang,
           const QString &HuanShou,
           const QString &XianShou,
           const QString &ChengJiaoE,
           const QString &FenZhongZhangFu5,
           const QString &ZuoShou,
           const QString &KaiPanJia,
           const QString &ZuiGaoJia,
           const QString &ZuiDiJia,
           const QString &HangYe,
           const QString &ShiYingLv,
           const QString &ShiJingLv,
           const QString &ShiXiaoLv,
           const QString &WeiTuoMaiRuJia1,
           const QString &WeiTuoMaiChuJia1,
           const QString &NeiPan,
           const QString &WaiPan,
           const QString &ZhenFu,
           const QString &LiangBi,
           const QString &JunJia,
           const QString &WeiBi,
           const QString &WeiCha,
           const QString &ChengJiaoBiShu,
           const QString &ChengJiaoFangXiang,
           const QString &ZongShiZhi,
           const QString &LiuTongShiZhi);
public:
    QString Head() const;
    QString XuHao() const;
    QString Obj() const;
    QString ZhongWenJianCheng() const;
    QString ZuiXinJia() const;
    QString ZhangDie() const;
    QString ZhangFu() const;
    QString ChengJiaoLiang() const;
    QString HuanShou() const;
    QString XianShou() const;

    QString ChengJiaoE() const;
    QString FenZhongZhangFu5() const;
    QString ZuoShou() const;
    QString KaiPanJia() const;
    QString ZuiGaoJia() const;
    QString ZuiDiJia() const;
    QString HangYe() const;
    QString ShiYingLv() const;
    QString ShiJingLv() const;
    QString ShiXiaoLv() const;

    QString WeiTuoMaiRuJia1() const;
    QString WeiTuoMaiChuJia1() const;
    QString NeiPan() const;
    QString WaiPan() const;
    QString ZhenFu() const;
    QString LiangBi() const;
    QString JunJia() const;
    QString WeiBi() const;
    QString WeiCha() const;
    QString ChengJiaoBiShu() const;

    QString ChengJiaoFangXiang() const;
    QString ZongShiZhi() const;
    QString LiuTongShiZhi() const;

    void SetData(QJsonValue &value);

public:

    QString m_Head;
    QString m_XuHao;
    QString m_Obj;
    QString m_ZhongWenJianCheng;
    QString m_ZuiXinJia;
    QString m_ZhangDie;
    QString m_ZhangFu;
    QString m_ChengJiaoLiang;
    QString m_HuanShou;
    QString m_XianShou;
    QString m_ChengJiaoE;
    QString m_FenZhongZhangFu5;
    QString m_ZuoShou;
    QString m_KaiPanJia;
    QString m_ZuiGaoJia;
    QString m_ZuiDiJia;
    QString m_HangYe;
    QString m_ShiYingLv;
    QString m_ShiJingLv;
    QString m_ShiXiaoLv;
    QString m_WeiTuoMaiRuJia1;
    QString m_WeiTuoMaiChuJia1;
    QString m_NeiPan;
    QString m_WaiPan;
    QString m_ZhenFu;
    QString m_LiangBi;
    QString m_JunJia;
    QString m_WeiBi;
    QString m_WeiCha;
    QString m_ChengJiaoBiShu;
    QString m_ChengJiaoFangXiang;
    QString m_ZongShiZhi;
    QString m_LiuTongShiZhi;

};

class QStockModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum QStockRoles {
        HeadRole = Qt::UserRole + 1,
        XuHaoRole,
        ObjRole,
        ZhongWenJianChengRole,
        ZuiXinJiaRole,//5
        ZhangDieRole,//6
        ZhangFuRole,
        ChengJiaoLiangRole,
        HuanShouRole,
        XianShouRole,
        ChengJiaoERole,
        FenZhongZhangFu5Role,
        ZuoShouRole,
        KaiPanJiaRole,
        ZuiGaoJiaRole,
        ZuiDiJiaRole,
        HangYeRole,
        ShiYingLvRole,
        ShiJingLvRole,
        ShiXiaoLvRole,
        WeiTuoMaiRuJia1Role,
        WeiTuoMaiChuJia1Role,
        NeiPanRole,
        WaiPanRole,
        ZhenFuRole,
        LiangBiRole,
        JunJiaRole,
        WeiBiRole,
        WeiChaRole,
        ChengJiaoBiShuRole,
        ChengJiaoFangXiangRole,
        ZongShiZhiRole,
        LiuTongShiZhiRole
    };

    QStockModel(QObject *parent = 0);

    void setQmlContext(QQmlContext *qmlContext);

    void addStock(const QStock &stock);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    Q_INVOKABLE void setExpandPosition(const int position);
    Q_INVOKABLE void updateData(const QString &data);
    Q_INVOKABLE void updateChildData(const int index,const QString &data);
    Q_INVOKABLE int deleteChildData(const int start);
    Q_INVOKABLE QVariant get(const int index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE void set(const int index, const QVariant &data,int role = Qt::DisplayRole);

    void printList();

protected:
    QHash<int, QByteArray> roleNames() const;
private:
    QList<QStock> m_stocks;
    QList<QStock> ::iterator m_iterStart;
    QList<QStock> ::iterator m_iterEnd;
    QList<QStock> ::iterator m_start;
    QList<QStock> ::iterator m_end;

    QMap<QString,int> m_stockIndexMap;

    int m_blockStockCount;
    int m_expandStockPos;
    int m_childStockStart;
    int m_childStockCount;

    bool m_isUpdatechildStock;

    QMutex m_mutex;
    QQmlContext *m_qmlContext;
};

#endif //TABLEMODEL_H


