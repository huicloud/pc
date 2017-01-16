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

#include "treemodel.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QDebug>
#include <QTime>


Stock::Stock(){

}

Stock::Stock(const QString &Head,
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
               const QString &LiuTongShiZhi)
    : m_Head(Head),
      m_XuHao(XuHao),
      m_Obj(Obj),
      m_ZhongWenJianCheng(ZhongWenJianCheng),
      m_ZuiXinJia(ZuiXinJia),
      m_ZhangDie(ZhangDie),
      m_ZhangFu(ZhangFu),
      m_ChengJiaoLiang(ChengJiaoLiang),
      m_HuanShou(HuanShou),
      m_XianShou(XianShou),
      m_ChengJiaoE(ChengJiaoE),
      m_FenZhongZhangFu5(FenZhongZhangFu5),
      m_ZuoShou(ZuoShou),
      m_KaiPanJia(KaiPanJia),
      m_ZuiGaoJia(ZuiGaoJia),
      m_ZuiDiJia(ZuiDiJia),
      m_HangYe(HangYe),
      m_ShiYingLv(ShiYingLv),
      m_ShiJingLv(ShiJingLv),
      m_ShiXiaoLv(ShiXiaoLv),
      m_WeiTuoMaiRuJia1(WeiTuoMaiRuJia1),
      m_WeiTuoMaiChuJia1(WeiTuoMaiChuJia1),
      m_NeiPan(NeiPan),
      m_WaiPan(WaiPan),
      m_ZhenFu(ZhenFu),
      m_LiangBi(LiangBi),
      m_JunJia(LiangBi),
      m_WeiBi(WeiBi),
      m_WeiCha(WeiCha),
      m_ChengJiaoBiShu(ChengJiaoBiShu),
      m_ChengJiaoFangXiang(ChengJiaoFangXiang),
      m_ZongShiZhi(ZongShiZhi),
      m_LiuTongShiZhi(LiuTongShiZhi)
{
}

QString Stock::Head() const
{
    return m_Head;
}
QString Stock::XuHao() const
{
    return m_XuHao;
}
QString Stock::Obj() const
{
    return m_Obj;
}
QString Stock::ZhongWenJianCheng() const
{
    return m_ZhongWenJianCheng;
}
QString Stock::ZuiXinJia() const
{
    return m_ZuiXinJia;
}
QString Stock::ZhangDie() const
{
    return m_ZhangDie;
}
QString Stock::ZhangFu() const
{
    return m_ZhangFu;
}
QString Stock::ChengJiaoLiang() const
{
    return m_ChengJiaoLiang;
}
QString Stock::HuanShou() const
{
    return m_HuanShou;
}
QString Stock::XianShou() const
{
    return m_XianShou;
}
QString Stock::ChengJiaoE() const
{
    return m_ChengJiaoE;
}
QString Stock::FenZhongZhangFu5() const
{
    return m_FenZhongZhangFu5;
}
QString Stock::ZuoShou() const
{
    return m_ZuoShou;
}
QString Stock::KaiPanJia() const
{
    return m_KaiPanJia;
}
QString Stock::ZuiGaoJia() const
{
    return m_ZuiGaoJia;
}
QString Stock::ZuiDiJia() const
{
    return m_ZuiDiJia;
}
QString Stock::HangYe() const
{
    return m_HangYe;
}
QString Stock::ShiYingLv() const
{
    return m_ShiYingLv;
}
QString Stock::ShiJingLv() const
{
    return m_ShiJingLv;
}
QString Stock::ShiXiaoLv() const
{
    return m_ShiXiaoLv;
}
QString Stock::WeiTuoMaiRuJia1() const
{
    return m_WeiTuoMaiRuJia1;
}
QString Stock::WeiTuoMaiChuJia1() const
{
    return m_WeiTuoMaiChuJia1;
}
QString Stock::NeiPan() const
{
    return m_NeiPan;
}
QString Stock::WaiPan() const
{
    return m_WaiPan;
}
QString Stock::ZhenFu() const
{
    return m_ZhenFu;
}
QString Stock::LiangBi() const
{
    return m_LiangBi;
}
QString Stock::JunJia() const
{
    return m_JunJia;
}
QString Stock::WeiBi() const
{
    return m_WeiBi;
}
QString Stock::WeiCha() const
{
    return m_WeiCha;
}
QString Stock::ChengJiaoBiShu() const
{
    return m_ChengJiaoBiShu;
}
QString Stock::ChengJiaoFangXiang() const
{
    return m_ChengJiaoFangXiang;
}
QString Stock::ZongShiZhi() const
{
    return m_ZongShiZhi;
}
QString Stock::LiuTongShiZhi() const
{
    return m_LiuTongShiZhi;
}

Stock::Stock(const QJsonValue &value,int isStkDyna){
    m_jsonValue = value;
    QJsonObject item = m_jsonValue.toObject();
    m_Obj = item["Obj"].toString();
}

QJsonValue Stock::GetJsonValue(int number,int isChild,int isExpandParent){
//QTime time;
//QDateTime dt;
//time.start();
//qDebug()<<"Stock " << time.elapsed() <<" ms" << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
//    item.ChengJiaoLiang = item.ChengJiaoLiang / 100;
//    item.XianShou = item.XianShou / 100;
//    item.XuHao = index +  1;
//    item.ZuiXinJia = item.ZuiXinJia.toFixed(2);
//    item.ZhangDie = item.ZhangDie.toFixed(2);
    //m_jsonValue = value;
    QJsonObject item = m_jsonValue.toObject();
    QJsonObject formatData;

//    if(isStkDyna == 0){
//        m_Obj = item["Obj"].toString();
//        m_ZhongWenJianCheng = item["ZhongWenJianCheng"].toString();
//        m_ZuiXinJia.setNum(item["ZhangFu"].toDouble(),'f',2);

//        formatData["Obj"] = m_Obj;
//        formatData["ZhongWenJianCheng"] = m_ZhongWenJianCheng;
//        formatData["ZhangFu"] = m_ZhangFu;

//        QJsonValue newValue(formatData);

//        m_jsonValue = newValue;
//        return;
//    }

    //m_XuHao = item["XuHao"].toString();
    m_Obj = item["Obj"].toString();
    m_ZhongWenJianCheng = item["ZhongWenJianCheng"].toString();
    m_ZuiXinJia.setNum(item["ZuiXinJia"].toDouble(),'f',2);
    m_ZhangDie.setNum(item["ZhangDie"].toDouble(),'f',2);
    m_ZhangFu.setNum(item["ZhangFu"].toDouble(),'f',2);
    m_ChengJiaoLiang.setNum(item["ChengJiaoLiang"].toDouble(),'f',0);
    m_HuanShou.setNum(item["HuanShou"].toDouble(),'f',2);
    m_XianShou.setNum(item["XianShou"].toDouble(),'f',0);
    m_ChengJiaoE.setNum(item["ChengJiaoE"].toDouble(),'f',0);
    m_FenZhongZhangFu5.setNum(item["FenZhongZhangFu5"].toDouble(),'f',2);
    m_ZuoShou.setNum(item["ZuoShou"].toDouble(),'f',0);
    m_KaiPanJia.setNum(item["KaiPanJia"].toDouble(),'f',2);
    m_ZuiGaoJia.setNum(item["ZuiGaoJia"].toDouble(),'f',2);
    m_ZuiDiJia.setNum(item["ZuiDiJia"].toDouble(),'f',2);
    m_HangYe = item["HangYe"].toString();
    m_ShiYingLv.setNum(item["ShiYingLv"].toDouble(),'f',2);
    m_ShiJingLv.setNum(item["ShiJingLv"].toDouble(),'f',2);
    m_ShiXiaoLv.setNum(item["ShiXiaoLv"].toDouble(),'f',2);
    m_WeiTuoMaiRuJia1.setNum(item["WeiTuoMaiRuJia1"].toDouble(),'f',2);
    m_WeiTuoMaiChuJia1.setNum(item["WeiTuoMaiChuJia1"].toDouble(),'f',2);
    m_NeiPan.setNum(item["NeiPan"].toDouble(),'f',0);
    m_WaiPan.setNum(item["WaiPan"].toDouble(),'f',0);
    m_ZhenFu.setNum(item["ZhenFu"].toDouble(),'f',2);
    m_LiangBi.setNum(item["LiangBi"].toDouble(),'f',2);
    m_JunJia.setNum(item["JunJia"].toDouble(),'f',2);
    m_WeiBi.setNum(item["WeiBi"].toDouble(),'f',2);
    m_WeiCha.setNum(item["WeiCha"].toDouble(),'f',2);
    m_ChengJiaoBiShu.setNum(item["ChengJiaoBiShu"].toDouble(),'f',0);
    m_ChengJiaoFangXiang.setNum(item["ChengJiaoFangXiang"].toDouble(),'f',2);
    m_ZongShiZhi.setNum(item["ZongShiZhi"].toDouble(),'f',2);
    m_LiuTongShiZhi.setNum(item["LiuTongShiZhi"].toDouble(),'f',2);

    //qDebug()<<"Stock " << time.elapsed() <<" ms" << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    //    item.ChengJiaoLiang = item.ChengJiaoLiang / 100;
    //构建格式化的json数据
    if(isChild){
        formatData["Head"] = "  ";
        formatData["Color"] = 1;
    }else{
        if(isExpandParent){
            formatData["Head"] = "-";
        }else{
            formatData["Head"] = "+";
        }
        formatData["Color"] = 0;
    }

    formatData["XuHao"] = number;
    formatData["Obj"] = m_Obj;
    formatData["ZhongWenJianCheng"] = m_ZhongWenJianCheng;
    formatData["ZuiXinJia"] = m_ZuiXinJia;
    formatData["ZhangDie"] = m_ZhangDie;
    formatData["ZhangFu"] = m_ZhangFu;
    formatData["ChengJiaoLiang"] = m_ChengJiaoLiang;
    formatData["HuanShou"] = m_HuanShou;
    formatData["XianShou"] = m_XianShou;
    formatData["ChengJiaoE"] = m_ChengJiaoE;
    formatData["FenZhongZhangFu5"] = m_FenZhongZhangFu5;
    formatData["ZuoShou"] = m_ZuoShou;
    formatData["KaiPanJia"] = m_KaiPanJia;
    formatData["ZuiGaoJia"] = m_ZuiGaoJia;
    formatData["ZuiDiJia"] = m_ZuiDiJia;
    formatData["HangYe"] = m_HangYe;
    formatData["ShiYingLv"] = m_ShiYingLv;
    formatData["ShiJingLv"] = m_ShiJingLv;
    formatData["ShiXiaoLv"] = m_ShiXiaoLv;
    formatData["WeiTuoMaiRuJia1"] = m_WeiTuoMaiRuJia1;
    formatData["WeiTuoMaiChuJia1"] = m_WeiTuoMaiChuJia1;
    formatData["NeiPan"] = m_NeiPan;
    formatData["WaiPan"] =m_WaiPan;
    formatData["ZhenFu"] = m_ZhenFu;
    formatData["LiangBi"] = m_LiangBi;
    formatData["JunJia"] = m_JunJia;
    formatData["WeiBi"] = m_WeiBi;
    formatData["WeiCha"] = m_WeiCha;
    formatData["ChengJiaoBiShu"] = m_ChengJiaoBiShu;
    formatData["ChengJiaoFangXiang"] = m_ChengJiaoFangXiang;
    formatData["ZongShiZhi"] = m_ZongShiZhi;
    formatData["LiuTongShiZhi"] = m_LiuTongShiZhi;

    QJsonValue newValue(formatData);

    //qDebug()<<"GetJsonData:"<< ":"<<m_Obj <<":"<<m_ZhongWenJianCheng<<":"<<m_ZuiXinJia<<":"<<m_ZhangFu;


    return newValue;

    //qDebug()<<"Stock " << time.elapsed() <<" ms" << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");

    //qDebug()<<"GetJsonData:"<<m_Obj <<" " << m_ZhongWenJianCheng ;
}



//////////////////////////////////
TreeNode::TreeNode()
{
}
TreeNodePtr TreeNode::parent()
{
    return mParent;
}

void TreeNode::setParent(TreeNodePtr p)
{
    this->mParent = p;
}

void TreeNode::appendNode(TreeNodePtr node)
{
    childs.append(node);
}

void TreeNode::removeNode(int row)
{
    childs.removeAt(row);
}

void TreeNode::setStock(Stock &stock)
{
    mRecord = stock;
}

QVariant TreeNode::data(int role) const {


    const Stock &stock = mRecord;
    if (role == HeadRole)
        return stock.Head();
    else if (role == XuHaoRole)
        return stock.XuHao();
    else if (role == ObjRole)
        return stock.Obj();
    else if (role == ZhongWenJianChengRole)
        return stock.ZhongWenJianCheng();
    else if (role == ZuiXinJiaRole)
        return stock.ZuiXinJia();
    else if (role == ZhangDieRole)
        return stock.ZhangDie();
    else if (role == ZhangFuRole)
        return stock.ZhangFu();
    else if (role == ChengJiaoLiangRole)
        return stock.ChengJiaoLiang();
    else if (role == HuanShouRole)
        return stock.HuanShou();
    else if (role == XianShouRole)
        return stock.XianShou();
    else if (role == ChengJiaoERole)
        return stock.ChengJiaoE();
    else if (role == FenZhongZhangFu5Role)
        return stock.FenZhongZhangFu5();
    else if (role == ZuoShouRole)
        return stock.ZuoShou();
    else if (role == KaiPanJiaRole)
        return stock.KaiPanJia();
    else if (role == ZuiGaoJiaRole)
        return stock.ZuiGaoJia();
    else if (role == ZuiDiJiaRole)
        return stock.ZuiDiJia();
    else if (role == HangYeRole)
        return stock.HangYe();
    else if (role == ShiYingLvRole)
        return stock.ShiYingLv();
    else if (role == ShiJingLvRole)
        return stock.ShiJingLv();
    else if (role == ShiXiaoLvRole)
        return stock.ShiXiaoLv();
    else if (role == WeiTuoMaiRuJia1Role)
        return stock.WeiTuoMaiRuJia1();
    else if (role == WeiTuoMaiChuJia1Role)
        return stock.WeiTuoMaiChuJia1();
    else if (role == NeiPanRole)
        return stock.NeiPan();
    else if (role == WaiPanRole)
        return stock.WaiPan();
    else if (role == ZhenFuRole)
        return stock.ZhenFu();
    else if (role == LiangBiRole)
        return stock.LiangBi();
    else if (role == JunJiaRole)
        return stock.JunJia();
    else if (role == WeiBiRole)
        return stock.WeiBi();
    else if (role == WeiChaRole)
        return stock.WeiCha();
    else if (role == ChengJiaoBiShuRole)
        return stock.ChengJiaoBiShu();
    else if (role == ChengJiaoFangXiangRole)
        return stock.ChengJiaoFangXiang();
    else if (role == ZongShiZhiRole)
        return stock.ZongShiZhi();
    else if (role == LiuTongShiZhiRole)
        return stock.LiuTongShiZhi();


    return QVariant();
}


SqlMenuEntry::SqlMenuEntry(QObject *parent):QAbstractItemModel(parent),m_expandStockPos(-1){

}


int SqlMenuEntry::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid()) //parent不为空，则要获取的行数是某个节点的子节点行数
    {
        TreeNodePtr parentNode = (TreeNodePtr)parent.internalPointer(); //节点信息在index时被保存在QModelIndex的internalPointer中
        return parentNode->childs.size();
    }
    return mRootEntrys.size();  //否则返回的是根节点行数

}

int SqlMenuEntry::columnCount(const QModelIndex &parent) const{
//    if(parent.isValid()) //parent不为空，则要获取的行数是某个节点的子节点行数
//    {
//        TreeNodePtr parentNode = (TreeNodePtr)parent.internalPointer(); //节点信息在index时被保存在QModelIndex的internalPointer中
//        return parentNode->childs.size();
//    }
//    return mRootEntrys.size();  //否则返回的是根节点行数
    return 33;
}

QModelIndex SqlMenuEntry::index(int row, int column, const QModelIndex &parent) const
{
    if(!parent.isValid())  //parent为空，返回的是根节点的modelIndex，返回的同时，把节点数据指针(TreeNodePtr)保存在QModelIndex的internalPointer中，以便在其它函数中获取节点数据
    {
        if((row >= 0) && (row < mRootEntrys.size()))
        {
            return createIndex(row,column,mRootEntrys.at(row));
        }
    }else{
        TreeNodePtr parentNode = (TreeNodePtr)parent.internalPointer(); //返回子节点的modelIndex
        return createIndex(row,column,parentNode->childs[row]);
    }
    return QModelIndex();
}
QModelIndex SqlMenuEntry::parent(const QModelIndex &child) const
{
    TreeNodePtr node = (TreeNodePtr)child.internalPointer();
    if(node->parent() == NULL)
    {
        return QModelIndex(); //根节点没有parent
    }else{
        return createIndex(0,1,node->parent());
    }
}

QVariant SqlMenuEntry::data(const QModelIndex &index, int role) const
{
    TreeNodePtr node = (TreeNodePtr)index.internalPointer();
    return node->data(role);
}

QHash<int, QByteArray> SqlMenuEntry::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[HeadRole] = "Head";
    roles[XuHaoRole] = "XuHao";
    roles[ObjRole] = "Obj";
    roles[ZhongWenJianChengRole] = "ZhongWenJianCheng";
    roles[ZuiXinJiaRole] = "ZuiXinJia";
    roles[ZhangDieRole] = "ZhangDie";
    roles[ZhangFuRole] = "ZhangFu";
    roles[ChengJiaoLiangRole] = "ChengJiaoLiang";
    roles[HuanShouRole] = "HuanShou";
    roles[XianShouRole] = "XianShou";
    roles[ChengJiaoERole] = "ChengJiaoE";
    roles[FenZhongZhangFu5Role] = "FenZhongZhangFu5";
    roles[ZuoShouRole] = "ZuoShou";
    roles[KaiPanJiaRole] = "KaiPanJia";
    roles[ZuiGaoJiaRole] = "ZuiGaoJia";
    roles[ZuiDiJiaRole] = "ZuiDiJia";
    roles[HangYeRole] = "HangYe";
    roles[ShiYingLvRole] = "ShiYingLv";
    roles[ShiJingLvRole] = "ShiJingLv";
    roles[ShiXiaoLvRole] = "ShiXiaoLv";
    roles[WeiTuoMaiRuJia1Role] = "WeiTuoMaiRuJia1";
    roles[WeiTuoMaiChuJia1Role] = "WeiTuoMaiChuJia1";
    roles[NeiPanRole] = "NeiPan";
    roles[WaiPanRole] = "WaiPan";
    roles[ZhenFuRole] = "ZhenFu";
    roles[LiangBiRole] = "LiangBi";
    roles[JunJiaRole] = "JunJia";
    roles[WeiBiRole] = "WeiBi";
    roles[WeiChaRole] = "WeiCha";
    roles[ChengJiaoBiShuRole] = "ChengJiaoBiShu";
    roles[ChengJiaoFangXiangRole] = "ChengJiaoFangXiang";
    roles[ZongShiZhiRole] = "ZongShiZhi";
    roles[LiuTongShiZhiRole] = "LiuTongShiZhi";
    return roles;
}

void SqlMenuEntry::addEntryNode(TreeNodePtr node, TreeNodePtr parent)
{
    if(parent == NULL)
    {
        mRootEntrys.append(node);
    }else{
        node->setParent(parent);
        parent->appendNode(node);
    }
}


//更新板块数据
void SqlMenuEntry::updateData(const int isSortFlag,const QString &data){

    qDebug()<<"StockModel::updateData";
    int listCount  = mRootEntrys.size();
    int dataCout = 0;

    QJsonParseError json_error;
    QJsonDocument parse_doucment = QJsonDocument::fromJson(data.toUtf8(), &json_error);
    if(json_error.error != QJsonParseError::NoError)
    {
       qDebug()<<"updateData: err:"<<json_error.error <<" data:"<<data ;
       return;
    }

    if(json_error.error == QJsonParseError::NoError)
    {
        if(parse_doucment.isArray())
        {
            QJsonArray array = parse_doucment.array();
            dataCout = array.size();

            qDebug()<<"StockModel::updateData array:"<<dataCout<<" isSortFlag:"<<isSortFlag;
            if(listCount == 0){
                //第一次增加
                //beginInsertRows(QModelIndex(), 0, dataCout-1);
                m_blockStockCount = dataCout;
                for(int i = 0; i < dataCout; i++){
                    Stock stock(array.at(i));

                    stock.m_Head = "+";
                    stock.m_XuHao.setNum(i+1);
                    //qDebug()<<"Data:"<<i<<" obj"<<stock.Obj();
                    TreeNodePtr pNode = new TreeNode();
                    pNode->setStock(stock);
                    pNode->mIsUpdate = 1;
                    addEntryNode(pNode);

                    m_stockIndexMap[stock.Obj()] = i;

                }

                //endInsertRows();

                //updateChildData(0,data);
                //emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
            } else if(isSortFlag == 1){

                //有展开数据时不更新排序
                if(m_expandStockPos == -1){

                    for(int i = 0; i < dataCout; i++){
                        Stock stock(array.at(i));
                        //修改索引
                        m_stockIndexMap[stock.Obj()] = i;
                    }
                    //emit dataChanged(createIndex(0,0),createIndex(dataCout,33));
                }
            } else {
                //更新
                int offset = 0;
                int index = 0;

                for(int i = 0; i < dataCout; i++){
                    Stock stock(array.at(i));
                    int pos = m_stockIndexMap[stock.Obj()];

                    qDebug()<<"updateData obj:" << stock.Obj() << "index:"<<pos<<stock.ZhongWenJianCheng() ;
                    //qDebug()<<"updateData new obj:" << stock.Obj() << " old:"<<m_stocks[pos].Obj();

                    TreeNodePtr pNode = mRootEntrys[pos];

//                    if(stock.Obj().compare(pNode->mRecord.Obj()) != 0){
//                        qDebug()<<"updateData continue new obj:" << stock.Obj() << " old:"<<pNode->mRecord.Obj();

//                        continue;
//                    }
                    //stock.m_Head = pNode->mRecord.Head();
                    //stock.m_XuHao = pNode->mRecord.XuHao();

                    pNode->setStock(stock);
                    pNode->mIsUpdate = 1;

                    //存储的是指针无需replace
                    //mRootEntrys.replace(pos,stock);
                    //emit dataChanged(this->index(pos,0),this->index(pos,33));
                }
            }
       } else {
            qDebug()<<"updateData err" ;
       }
    }
    //qDebug()<<"updateData end" ;
    //return ret;
}

//更新板块成分股数据
void SqlMenuEntry::updateChildData(const int isSortFlag,const int index,const QString &data){
    QDateTime dt;
    qDebug()<<"updateChildData before Size:"<<mRootEntrys.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    int ret = -1;
    QTime time;
    time.start();
    //qDebug()<<"updateChildData lock after Size:"<<mRootEntrys.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");

    QJsonParseError json_error;
    QJsonDocument parse_doucment = QJsonDocument::fromJson(data.toUtf8(), &json_error);
    if(json_error.error != QJsonParseError::NoError)
    {
       qDebug()<<"appendChildData: err:"<<json_error.error ;
       return;
    }
    //当前列表股票个数
    TreeNodePtr pNodeParent = mRootEntrys[index];

    int listCount = pNodeParent->childs.size();
    int dataCount = 0;


    if(json_error.error == QJsonParseError::NoError)
    {
        if(parse_doucment.isArray())
        {
            QJsonArray array = parse_doucment.array();
            dataCount = array.size();

            //qDebug()<<"updateChildData dealarray Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
            if(listCount == 0){
                //第一次展开板块列表，新增加

                //qDebug()<<"updateChildData beginInsertRows Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //beginInsertRows(QModelIndex(), index, index + dataCount-1);
                //beginInsertRows(this->index(index), 0, dataCount-1);
                //qDebug()<<"updateChildData beginInsertRows after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //QList<QPersistentModelIndex> listChange;
                for(int i = 0; i < dataCount; i++){
                    Stock stock(array.at(i));
                    stock.m_XuHao.setNum(i+1);
                    stock.m_Head = "";
                    TreeNodePtr pNode = new TreeNode();
                    pNode->setStock(stock);
                    pNodeParent->m_stockIndexMap[stock.Obj()] = i;
                    addEntryNode(pNode,pNodeParent);
                    pNode->mIsUpdate = 1;
                }

                //m_stocks[index - 1].m_Head = "-";
                //qDebug()<<"updateChildData beginInsertRows to end Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //endInsertRows();
                //qDebug()<<"updateChildData endInsertRows  after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //emit layoutChanged();
                //m_qmlContext->setContextProperty("blockModel", this);
                //qDebug()<<"updateChildData layoutChanged after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //emit dataChanged(createIndex(index - 1,0),createIndex(index - 1,33));
                //qDebug()<<"updateChildData: " << dataCount << "  emit "<< index <<", " << m_stocks.size();
                //emit dataChanged(createIndex(index,0),createIndex(index+ dataCount-1,33));
            } else if(isSortFlag == 1){

                //qDebug()<<"updateChildData : " << dataCount;
                int oldIndex = 0;
                for(int i = 0; i < dataCount; i++){
                    Stock stock(array.at(i));
                    //修改索引

                    pNodeParent->m_stockIndexMap[stock.Obj()] = i;

                }
            } else {
                //更新
                for(int i = 0; i < dataCount; i++){
                    Stock stock(array.at(i));
                    int pos = pNodeParent->m_stockIndexMap[stock.Obj()];

                    if(pos == -1){
                        continue;
                    }

                    TreeNodePtr pNodeStock = pNodeParent->childs[pos];

//                    if(stock.Obj().compare(pNodeStock->mRecord.Obj()) != 0){
//                        qDebug()<<"updateData continue new obj:" << stock.Obj() << " old:"<<pNodeStock->mRecord.Obj();

//                        continue;
//                    }

                    stock.m_XuHao = pNodeStock->mRecord.XuHao();

                    pNodeStock->setStock(stock);
                    pNodeStock->mIsUpdate = 1;

                    //emit dataChanged(this->index(pos,0,this->index(index)),this->index(pos,33,this->index(index)));
                    //emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
                }
            }
       } else {
            qDebug()<<"NoUpdate :" ;
        }
    }

    //qDebug()<<"updateChildData:"<<index << " childsize:"<<mRootEntrys[index]->childs.size();

    //qDebug()<<"updateChildData " << time.elapsed() <<" ms" << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    return;
}


//更新板块数据
void SqlMenuEntry::updateBlockDataSlots(const int isSortFlag,const QString &data){

    //qDebug()<<"StockModel::updateData";
    int listCount  = mRootEntrys.size();
    int dataCout = 0;

    QJsonParseError json_error;
    QJsonDocument parse_doucment = QJsonDocument::fromJson(data.toUtf8(), &json_error);
    if(json_error.error != QJsonParseError::NoError)
    {
       qDebug()<<"updateData: err:"<<json_error.error <<" data:"<<data ;
       return;
    }

    if(json_error.error == QJsonParseError::NoError)
    {
        if(parse_doucment.isArray())
        {
            QJsonArray array = parse_doucment.array();
            dataCout = array.size();

            //qDebug()<<"updateBlockDataSlots:: array:"<<dataCout;
            if(listCount == 0){
                //第一次增加
                //beginInsertRows(QModelIndex(), 0, dataCout-1);
                m_blockStockCount = dataCout;
                for(int i = 0; i < dataCout; i++){
                    Stock stock(array.at(i));

                    stock.m_Head = "+";
                    stock.m_XuHao.setNum(i+1);
                    //qDebug()<<"Data:"<<i<<" obj"<<stock.Obj();
                    TreeNodePtr pNode = new TreeNode();
                    pNode->setStock(stock);
                    pNode->mIsUpdate = 1;
                    addEntryNode(pNode);

                    m_stockIndexMap[stock.Obj()] = i;

                }

                //endInsertRows();

                //updateChildData(0,data);
                //emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
            } else if(isSortFlag == 1){

                //qDebug()<<"StockModel::updateData isSortFlag:"<<dataCout;
                //有展开数据时不更新排序
                //if(m_expandStockPos == -1){
                    int oldIndex = 0;
                    QList<TreeNodePtr> rootEntrys;
                    for(int i = 0; i < dataCout; i++){
                        Stock stock(array.at(i));

                        oldIndex = m_stockIndexMap[stock.Obj()];

                        //通过两次更新数据方式，此处不能覆盖旧数据
                        //mRootEntrys[oldIndex]->setStock(stock);
                        rootEntrys.append(mRootEntrys[oldIndex]);
                        //修改索引
                        m_stockIndexMap[stock.Obj()] = i;
                    }
                    mRootEntrys = rootEntrys;

                    //emit dataChanged(createIndex(0,0),createIndex(dataCout,33));
                //}
            } else {
                //更新
                int offset = 0;
                int index = 0;

                for(int i = 0; i < dataCout; i++){
                    Stock stock(array.at(i),1);
                    int pos = m_stockIndexMap[stock.Obj()];

                    //qDebug()<<"updateData update obj:" << stock.Obj() << "index:"<<pos <<" :"<<stock.ZhongWenJianCheng();
                    //qDebug()<<"updateData new obj:" << stock.Obj() << " old:"<<m_stocks[pos].Obj();

                    TreeNodePtr pNode = mRootEntrys[pos];

//                    if(stock.Obj().compare(pNode->mRecord.Obj()) != 0){
//                        qDebug()<<"updateData continue new obj:" << stock.Obj() << " old:"<<pNode->mRecord.Obj();

//                        continue;
//                    }
                    stock.m_Head = pNode->mRecord.Head();
                    stock.m_XuHao = pNode->mRecord.XuHao();

                    pNode->setStock(stock);
                    pNode->mIsUpdate = 1;

                    //存储的是指针无需replace
                    //mRootEntrys.replace(pos,stock);
                    //emit dataChanged(this->index(pos,0),this->index(pos,33));
                }
            }
       } else {
            qDebug()<<"updateData err" ;
       }
    }

    emit updateBlockDataSignal();
    //qDebug()<<"updateData end" ;
    //return ret;
}

//更新板块成分股数据
void SqlMenuEntry::updateBlockChildDataSlots(const int isSortFlag,const int index,const QString &data){
    QDateTime dt;
    //qDebug()<<"updateChildData before Size:"<<mRootEntrys.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    int ret = -1;
    QTime time;
    time.start();
    //qDebug()<<"updateChildData lock after Size:"<<mRootEntrys.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");

    QJsonParseError json_error;
    QJsonDocument parse_doucment = QJsonDocument::fromJson(data.toUtf8(), &json_error);
    if(json_error.error != QJsonParseError::NoError)
    {
       qDebug()<<"appendChildData: err:"<<json_error.error ;
       return;
    }
    //当前列表股票个数
    TreeNodePtr pNodeParent = mRootEntrys[index];

    int listCount = pNodeParent->childs.size();
    int dataCount = 0;

    //qDebug()<<"updateChildData parent:"<<pNodeParent->mRecord.ZhongWenJianCheng();

    if(json_error.error == QJsonParseError::NoError)
    {
        if(parse_doucment.isArray())
        {
            QJsonArray array = parse_doucment.array();
            dataCount = array.size();

            //qDebug()<<"updateChildData dealarray Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
            if(listCount == 0 && isSortFlag == 1){
                //第一次展开板块列表，新增加
                m_expandStockPos = index;

                //qDebug()<<"updateChildData first  Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //beginInsertRows(QModelIndex(), index, index + dataCount-1);
                //beginInsertRows(this->index(index), 0, dataCount-1);
                //qDebug()<<"updateChildData beginInsertRows after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //QList<QPersistentModelIndex> listChange;
                for(int i = 0; i < dataCount; i++){
                    Stock stock(array.at(i));
                    stock.m_XuHao.setNum(i+1);
                    stock.m_Head = "";
                    TreeNodePtr pNode = new TreeNode();
                    pNode->setStock(stock);

                    //qDebug()<<"updateChildData first: "<<i<<" obj:"<<stock.Obj()<<" "<<stock.ZhongWenJianCheng();
                    pNodeParent->m_stockIndexMap[stock.Obj()] = i;
                    addEntryNode(pNode,pNodeParent);
                    pNode->mIsUpdate = 1;
                }

                //m_stocks[index - 1].m_Head = "-";
                //qDebug()<<"updateChildData beginInsertRows to end Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //endInsertRows();
                //qDebug()<<"updateChildData endInsertRows  after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //emit layoutChanged();
                //m_qmlContext->setContextProperty("blockModel", this);
                //qDebug()<<"updateChildData layoutChanged after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //emit dataChanged(createIndex(index - 1,0),createIndex(index - 1,33));
                //qDebug()<<"updateChildData: " << dataCount << "  emit "<< index <<", " << m_stocks.size();
                //emit dataChanged(createIndex(index,0),createIndex(index+ dataCount-1,33));
            } else if(isSortFlag == 1){

                //qDebug()<<"updateChildData updatesort isSortFlag: " << dataCount;

                int oldIndex = 0;
                QList<TreeNodePtr> childEntrys;
                for(int i = 0; i < dataCount; i++){
                    Stock stock(array.at(i));

                    //修改索引
                    oldIndex = pNodeParent->m_stockIndexMap[stock.Obj()];
                    //childEntrys.append(pNodeParent->childs[oldIndex]);
                    if(oldIndex < pNodeParent->childs.size()){
                        //通过两次更新数据方式，此处不能覆盖旧数据
                        //pNodeParent->childs[oldIndex]->setStock(stock);

                        childEntrys.append( pNodeParent->childs[oldIndex]);
                        pNodeParent->m_stockIndexMap[stock.Obj()] = i;
                    }


                    //qDebug()<<"updateChildData isSortFlag stock: " << stock.Obj()<<stock.ZhongWenJianCheng()<<stock.ZhangFu();
                    //qDebug()<<"updateChildData isSortFlag: " << pNodeParent->childs[oldIndex]->mRecord.Obj()<<pNodeParent->childs[oldIndex]->mRecord.ZhongWenJianCheng()<<pNodeParent->childs[oldIndex]->mRecord.ZhangFu();
                }
                pNodeParent->childs = childEntrys;
            } else {
                //更新
                if(m_expandStockPos != index || listCount == 0){
                    return;
                }
                for(int i = 0; i < dataCount; i++){
                    Stock stock(array.at(i),1);
                    int pos = pNodeParent->m_stockIndexMap[stock.Obj()];

                    if(pos == -1){
                        continue;
                    }
                    //qDebug()<<"updateChildData update obj:"<< stock.Obj()<<" pos:"<<pos;
                    if(pos > listCount){
                        qDebug()<<"updateChildData "<< pNodeParent->mRecord.ZhongWenJianCheng() << " parent:"<<index<<" listSize:"<< listCount <<" obj:"<< stock.Obj()<<" pos:"<<pos << " out of range";
                        continue;
                    }

                    TreeNodePtr pNodeStock = pNodeParent->childs[pos];

//                    if(stock.Obj().compare(pNodeStock->mRecord.Obj()) != 0){
//                        qDebug()<<"updateData continue new obj:" << stock.Obj() << " old:"<<pNodeStock->mRecord.Obj();

//                        continue;
//                    }

                    stock.m_XuHao = pNodeStock->mRecord.XuHao();

                    pNodeStock->setStock(stock);
                    pNodeStock->mIsUpdate = 1;

                    //emit dataChanged(this->index(pos,0,this->index(index)),this->index(pos,33,this->index(index)));
                    //emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
                }
            }
       } else {
            qDebug()<<"NoUpdate :" ;
        }
    }

    //qDebug()<<"updateChildData:"<<index << " childsize:"<<mRootEntrys[index]->childs.size();

    //qDebug()<<"updateChildData " << time.elapsed() <<" ms" << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    emit updateBlockChildDataSignal(pNodeParent->mRecord.Obj());
    return;
}




QVariant SqlMenuEntry::get(const int parent,const int index, int role) const{
    QVariant ret;

    if(mRootEntrys.size()==0){
        qDebug()<<"Get:"<<mRootEntrys.size();
        return ret;
    }
    qDebug()<<"Get:"<<parent <<","<<index;

    TreeNodePtr p;
    if(parent > -1){
        //取父节点
        p = mRootEntrys[parent];
    } else{
        p = mRootEntrys[parent]->childs[index];
    }
    const Stock &stock = p->mRecord;
    if (role == HeadRole)
        ret = stock.Head();
    else if (role == XuHaoRole)
        ret = stock.XuHao();
    else if (role == ObjRole)
        ret = stock.Obj();
    else if (role == ZhongWenJianChengRole)
        ret = stock.ZhongWenJianCheng();
    else if (role == ZuiXinJiaRole)
        ret = stock.ZuiXinJia();
    else if (role == ZhangDieRole)
        ret = stock.ZhangDie();
    else if (role == ZhangFuRole)
        ret = stock.ZhangFu();
    else if (role == ChengJiaoLiangRole)
        ret = stock.ChengJiaoLiang();
    else if (role == HuanShouRole)
        ret = stock.HuanShou();
    else if (role == XianShouRole)
        ret = stock.XianShou();
    else if (role == ChengJiaoERole)
        ret = stock.ChengJiaoE();
    else if (role == FenZhongZhangFu5Role)
        ret = stock.FenZhongZhangFu5();
    else if (role == ZuoShouRole)
        ret = stock.ZuoShou();
    else if (role == KaiPanJiaRole)
        ret = stock.KaiPanJia();
    else if (role == ZuiGaoJiaRole)
        ret = stock.ZuiGaoJia();
    else if (role == ZuiDiJiaRole)
        ret = stock.ZuiDiJia();
    else if (role == HangYeRole)
        ret = stock.HangYe();
    else if (role == ShiYingLvRole)
        ret = stock.ShiYingLv();
    else if (role == ShiJingLvRole)
        ret = stock.ShiJingLv();
    else if (role == ShiXiaoLvRole)
        ret = stock.ShiXiaoLv();
    else if (role == WeiTuoMaiRuJia1Role)
        ret = stock.WeiTuoMaiRuJia1();
    else if (role == WeiTuoMaiChuJia1Role)
        ret = stock.WeiTuoMaiChuJia1();
    else if (role == NeiPanRole)
        ret = stock.NeiPan();
    else if (role == WaiPanRole)
        ret = stock.WaiPan();
    else if (role == ZhenFuRole)
        ret = stock.ZhenFu();
    else if (role == LiangBiRole)
        ret = stock.LiangBi();
    else if (role == JunJiaRole)
        ret = stock.JunJia();
    else if (role == WeiBiRole)
        ret = stock.WeiBi();
    else if (role == WeiChaRole)
        ret = stock.WeiCha();
    else if (role == ChengJiaoBiShuRole)
        ret = stock.ChengJiaoBiShu();
    else if (role == ChengJiaoFangXiangRole)
        ret = stock.ChengJiaoFangXiang();
    else if (role == ZongShiZhiRole)
        ret = stock.ZongShiZhi();
    else if (role == LiuTongShiZhiRole)
        ret = stock.LiuTongShiZhi();

    qDebug()<<"Get:"<<ret;
    return ret;
}


//get jsonobject
int SqlMenuEntry::getParentChildsCount(const int parent) const{
    int ret = 0;

    ret = mRootEntrys[parent]->childs.size();
    qDebug()<<"Get:"<<parent << " childsize:"<<ret;

    return ret;
}

//get jsonobject
QVariant SqlMenuEntry::getRowData(const int parent,const int child) const{
    QJsonObject ret;
    if(mRootEntrys.size()==0){
        qDebug()<<"Get mRootEntrys.size():"<<mRootEntrys.size();
        return ret;
    }
    //qDebug()<<"Get:"<<parent <<","<<child << " childsize:"<<mRootEntrys[parent]->childs.size();

    TreeNodePtr p;
    if(child == -1){
        //取父节点
        p = mRootEntrys[parent];
    } else{
        p = mRootEntrys[parent]->childs[child];
    }

    //qDebug()<<"getRowData:"<<parent <<","<<child << p->mRecord.Obj() << p->mRecord.ZhongWenJianCheng();

    return p->mRecord.m_jsonValue.toObject();
}

//get jsonobject

//返回数据不包含end位置数据
QVariant SqlMenuEntry::getShowRowData(const int start,const int end,const int parent) const{
    QJsonArray ret;
    int parentCount = mRootEntrys.size();
    if(parentCount == 0){
        //qDebug() << "Get getShowRowData size:" << parentCount;
        return ret;
    }

    //qDebug() << "Get getShowRowData size:" << parentCount;
    //qDebug()<<"Get:"<<start <<","<<end <<" parent:"<<parent;

    int childCout = 0;
    int childIndex = 0;

    int parentIndex = start;

    if(parent > -1){
        childCout = mRootEntrys[parent]->childs.size();
        //qDebug()<<"Get: childcount:"<<childCout;
    }
    if(start > parent){
        //要显示的元素从成分股开始
        childIndex = start - parent - 1;
    }
    if(start >= (parent+childCout))
    {
        //要显示的元素从板块指数开始
        parentIndex = start - childCout;
    }

    TreeNodePtr p;
    int number = 0;
    int isChild = 0;
    int isExpandParent = 0;//是否是展开的父节点
    for(int i=start;i<end;i++){
        //qDebug()<<"getRowData :"<<i << " childcount:"<<childCout <<" "<<parent<<":"<<childCout << " childIndex:"<<childIndex;
        isChild = 0;
        isExpandParent = 0;
        if(parent > -1 && i > parent && childIndex < childCout){
            if(i == start){
                //第一个元素是子节点元素
                parentIndex = parent + 1;
            }
            //取子节点数据
            if(childIndex>childCout){
                continue;
            }

            p = mRootEntrys[parent]->childs[childIndex++];
            number = childIndex;
            isChild = 1;
        } else {
            //取父节点
            if(parentIndex >= parentCount){
                break;
            }
            if(parentIndex == parent){
                isExpandParent = 1;
            }
            p = mRootEntrys[parentIndex++];
            number = parentIndex;
        }

        //QJsonObject &item = p->mRecord.m_jsonValue.toObject();

        //qDebug()<<"getRowData:"<<i << ":"<<p->mRecord.Obj() <<":"<<p->mRecord.ZhongWenJianCheng()<<":"<<p->mRecord.ZhangFu()<<":"<<p->mRecord.ZuiXinJia();

        //ret.append(p->mRecord.m_jsonValue);
        ret.append(p->mRecord.GetJsonValue(number,isChild,isExpandParent));
    }

    //qDebug()<<"getRowData:"<<parent  << p->mRecord.Obj() << p->mRecord.ZhongWenJianCheng();
    //qDebug()<<"getRowData end";
    return ret;
}

//get jsonobject
int SqlMenuEntry::getRowDataUpdateFlag(const int parent,const int child) const{
    int ret = 0;
    if(mRootEntrys.size()==0){

        return ret;
    }
    //qDebug()<<"Get:"<<parent <<","<<child << " childsize:"<<mRootEntrys[parent]->childs.size();

    TreeNodePtr p;
    if(child == -1){
        //取父节点
        p = mRootEntrys[parent];
    } else{
        p = mRootEntrys[parent]->childs[child];
    }

    //qDebug()<<"getRowData:"<<parent <<","<<child << p->mRecord.Obj() << p->mRecord.ZhongWenJianCheng();
    ret = p->mIsUpdate;
    p->mIsUpdate = 0;
    return ret;
}

int SqlMenuEntry::getExpandPosition(const QVariant obj){


    int expand = m_stockIndexMap[obj.toString()];
    //qDebug()<<"getExpandPosition:"<< expand;
    return expand;
}
int SqlMenuEntry::getExpandPositionChildCount(const QVariant obj){


    int expand = m_stockIndexMap[obj.toString()];
    //qDebug()<<"getExpandPosition:"<< expand;
    return mRootEntrys[expand]->childs.size();
}
