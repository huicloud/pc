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

#ifndef TREEMODEL_H
#define TREEMODEL_H
#include <QAbstractListModel>
#include <QStringList>
#include <QMap>
#include <QMutex>
#include <iterator>
#include <QQmlContext>
#include <QQmlParserStatus>
#include <QJsonObject>

class TreeNode;
typedef TreeNode* TreeNodePtr;

class Stock
{
public:
    Stock();
    Stock(const QJsonValue &item,int isStkDyna = 0);
    Stock(const QString &Head,
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


    QJsonValue GetJsonValue(int number,int isChild,int isExpandParent);
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
    QString m_ShangZhangJiaShu;
    QString m_XiaDieJiaShu;
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

    QJsonValue m_jsonValue;
};


class TreeNode
{
public:
    enum StockRoles {
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

    explicit TreeNode();
    TreeNodePtr parent();
    void setParent(const TreeNodePtr p);  //设置父节点，根节点的父节点为NULL
    void appendNode(TreeNodePtr node);
    void removeNode(int row);
    QVariant data(int role = Qt::DisplayRole) const;
    void setStock(Stock &stock);
    //void setData(int role,QVariant value);
    QList<TreeNodePtr> childs;   //用于保存子节点指针，把childs放到public不好，仅仅是为了方便，不要学。

    TreeNodePtr mParent=NULL;   //父节点
    Stock mRecord; //一个节点可以保存一行数据，哈希表的key是整型，用于保存role，QVariant保存数据
    int mIsUpdate;//节点数据是否更新
    QMap<QString,int> m_stockIndexMap;
};

//class SqlMenuEntry : public QAbstractItemModel,public QQmlParserStatus
class SqlMenuEntry : public QAbstractItemModel
{
    Q_OBJECT
public:

    enum StockRoles {
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



    explicit SqlMenuEntry(QObject *parent=0);
    //~SqlMenuEntry();

    int rowCount(const QModelIndex &parent=QModelIndex()) const;
    int columnCount(const QModelIndex &parent=QModelIndex()) const;
    QModelIndex index(int row, int column=0, const QModelIndex &parent=QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role=Qt::DisplayRole) const;
    QModelIndex parent(const QModelIndex &child) const;
    QHash<int,QByteArray>roleNames() const;


    void addEntryNode(TreeNodePtr node,TreeNodePtr parent=0); //用于向树添加节点

    Q_INVOKABLE void updateData(const int isSortFlag,const QString &data);

    Q_INVOKABLE void updateChildData(const int isSortFlag,const int index,const QString &data);

    Q_INVOKABLE QVariant get(const int parent,const int index, int role = Qt::DisplayRole) const;
    //Q_INVOKABLE void set(const int index, const QVariant &data,int role = Qt::DisplayRole);

    Q_INVOKABLE int getRowDataUpdateFlag(const int parent,const int child)const;
    Q_INVOKABLE QVariant getRowData(const int parent,const int child) const;

    Q_INVOKABLE QVariant getShowRowData(const int start,const int count,const int parent) const;

    Q_INVOKABLE int getParentChildsCount(const int parent) const;

    Q_INVOKABLE int getExpandPosition(const QVariant obj);
    Q_INVOKABLE int getExpandPositionChildCount(const QVariant obj);


signals:

    void updateBlockDataSignal();
    void updateBlockChildDataSignal(const QVariant updateParentObj);

public slots:
    void updateBlockDataSlots(const int isSortFlag,const QString &data);
    void updateBlockChildDataSlots(const int isSortFlag,const int index,const QString &data);


private:

    //QList<QHash<int,QVariant>> mRecords; //QList不能保存树状数据，干掉
    QList<TreeNodePtr> mRootEntrys;      //用于保存根节点

    QMap<QString,int> m_stockIndexMap;

    int m_blockStockCount;
    int m_expandStockPos;
    int m_childStockStart;
    int m_childStockCount;

    QJsonValue m_headValue;
};

#endif //TREEMODEL_H


