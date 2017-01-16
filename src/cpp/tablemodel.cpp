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

#include "tablemodel.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QDebug>
#include <QTime>

QStock::QStock(){

}

QStock::QStock(const QString &Head,
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

QString QStock::Head() const
{
    return m_Head;
}
QString QStock::XuHao() const
{
    return m_XuHao;
}
QString QStock::Obj() const
{
    return m_Obj;
}
QString QStock::ZhongWenJianCheng() const
{
    return m_ZhongWenJianCheng;
}
QString QStock::ZuiXinJia() const
{
    return m_ZuiXinJia;
}
QString QStock::ZhangDie() const
{
    return m_ZhangDie;
}
QString QStock::ZhangFu() const
{
    return m_ZhangFu;
}
QString QStock::ChengJiaoLiang() const
{
    return m_ChengJiaoLiang;
}
QString QStock::HuanShou() const
{
    return m_HuanShou;
}
QString QStock::XianShou() const
{
    return m_XianShou;
}
QString QStock::ChengJiaoE() const
{
    return m_ChengJiaoE;
}
QString QStock::FenZhongZhangFu5() const
{
    return m_FenZhongZhangFu5;
}
QString QStock::ZuoShou() const
{
    return m_ZuoShou;
}
QString QStock::KaiPanJia() const
{
    return m_KaiPanJia;
}
QString QStock::ZuiGaoJia() const
{
    return m_ZuiGaoJia;
}
QString QStock::ZuiDiJia() const
{
    return m_ZuiDiJia;
}
QString QStock::HangYe() const
{
    return m_HangYe;
}
QString QStock::ShiYingLv() const
{
    return m_ShiYingLv;
}
QString QStock::ShiJingLv() const
{
    return m_ShiJingLv;
}
QString QStock::ShiXiaoLv() const
{
    return m_ShiXiaoLv;
}
QString QStock::WeiTuoMaiRuJia1() const
{
    return m_WeiTuoMaiRuJia1;
}
QString QStock::WeiTuoMaiChuJia1() const
{
    return m_WeiTuoMaiChuJia1;
}
QString QStock::NeiPan() const
{
    return m_NeiPan;
}
QString QStock::WaiPan() const
{
    return m_WaiPan;
}
QString QStock::ZhenFu() const
{
    return m_ZhenFu;
}
QString QStock::LiangBi() const
{
    return m_LiangBi;
}
QString QStock::JunJia() const
{
    return m_JunJia;
}
QString QStock::WeiBi() const
{
    return m_WeiBi;
}
QString QStock::WeiCha() const
{
    return m_WeiCha;
}
QString QStock::ChengJiaoBiShu() const
{
    return m_ChengJiaoBiShu;
}
QString QStock::ChengJiaoFangXiang() const
{
    return m_ChengJiaoFangXiang;
}
QString QStock::ZongShiZhi() const
{
    return m_ZongShiZhi;
}
QString QStock::LiuTongShiZhi() const
{
    return m_LiuTongShiZhi;
}

QStock::QStock(const QJsonObject &item){


//    item.ChengJiaoLiang = item.ChengJiaoLiang / 100;
//    item.XianShou = item.XianShou / 100;
//    item.XuHao = index +  1;
//    item.ZuiXinJia = item.ZuiXinJia.toFixed(2);
//    item.ZhangDie = item.ZhangDie.toFixed(2);

    m_XuHao = item["XuHao"].toString();
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
    m_JunJia.setNum(item["LiangBi"].toDouble(),'f',2);
    m_WeiBi.setNum(item["WeiBi"].toDouble(),'f',2);
    m_WeiCha.setNum(item["WeiCha"].toDouble(),'f',2);
    m_ChengJiaoBiShu.setNum(item["ChengJiaoBiShu"].toDouble(),'f',0);
    m_ChengJiaoFangXiang.setNum(item["ChengJiaoFangXiang"].toDouble(),'f',2);
    m_ZongShiZhi.setNum(item["ZongShiZhi"].toDouble(),'f',2);
    m_LiuTongShiZhi.setNum(item["LiuTongShiZhi"].toDouble(),'f',2);

    //qDebug()<<"SetData:"<<m_Obj <<" " << m_ZhongWenJianCheng ;
}


QStockModel::QStockModel(QObject *parent)
    : QAbstractListModel(parent),m_expandStockPos(-1),m_childStockCount(0),m_isUpdatechildStock(false)
{
}

void QStockModel::setQmlContext(QQmlContext *qmlContext){
    m_qmlContext = qmlContext;
}

void QStockModel::addStock(const QStock &stock)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_stocks << stock;
    endInsertRows();
}

int QStockModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return m_stocks.count();
}

QVariant QStockModel::data(const QModelIndex & index, int role) const {

    if (index.row() < 0 || index.row() >= m_stocks.count())
        return QVariant();

    const QStock &stock = m_stocks[index.row()];
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


QVariant QStockModel::get(const int index, int role) const{

    QVariant ret;
    if (index < 0 || index >= m_stocks.count())
        return ret;


    const QStock &stock = m_stocks[index];
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

    //qDebug()<<"Get:"<<ret;
    return ret;
}

void QStockModel::set(const int index,const QVariant &data, int role) {
    m_mutex.lock();

    if (index < 0 || index >= m_stocks.count())
        return;


    QStock &stock = m_stocks[index];

    if (role == HeadRole)
        stock.m_Head = data.toString();
    emit dataChanged(createIndex(index,0),createIndex(index,33));

    m_mutex.unlock();
    return;
}


QHash<int, QByteArray> QStockModel::roleNames() const {
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

//更新板块数据
void QStockModel::updateData(const QString &data){
    m_mutex.lock();

    int listCount  = m_stocks.size();
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

            //qDebug()<<"QStockModel::updateData array:"<<dataCout;

            if(listCount == 0){
                //第一次增加
                beginInsertRows(QModelIndex(), 0, dataCout-1);
                m_blockStockCount = dataCout;
                for(int i = 0; i < dataCout; i++){
                    QStock stock(array[i].toObject());
                    stock.m_Head = "+";
                    stock.m_XuHao.setNum(i+1);
                    //qDebug()<<"Data:"<<i<<" obj"<<stock.Obj();
                    m_stocks.append(stock);
                    m_stockIndexMap[stock.Obj()] = i;
                }

                endInsertRows();



                emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
            } else if(dataCout > 1){

                //有展开数据时不更新排序
                if(m_expandStockPos == -1){

                    for(int i = 0; i < dataCout; i++){
                        QStock stock(array[i].toObject());
                        //修改索引
                        m_stockIndexMap[stock.Obj()] = i;
                    }
                    //emit dataChanged(createIndex(0,0),createIndex(dataCout,33));
                }

            } else {
                //更新

                int offset = 0;
                int index = 0;
                if(m_expandStockPos > -1){
                    //有展开的数据
                    offset = m_childStockCount;
                }

                for(int i = 0; i < dataCout; i++){
                    QStock stock(array[i].toObject());
                    int pos = m_stockIndexMap[stock.Obj()];

                    if(pos > m_expandStockPos){
                        pos += offset;
                    }

                    //qDebug()<<"updateData obj:" << stock.Obj() << "index:"<<pos <<" expand:"<<m_expandStockPos<<" Size:"<<m_stocks.size() ;

                    //qDebug()<<"updateData new obj:" << stock.Obj() << " old:"<<m_stocks[pos].Obj();

//                    if(stock.Obj().compare(m_stocks[pos].Obj()) != 0){
//                        qDebug()<<"updateData continue new obj:" << stock.Obj() << " old:"<<m_stocks[pos].Obj();

//                        continue;
//                    }
                    stock.m_Head = m_stocks[pos].Head();
                    stock.m_XuHao = m_stocks[pos].XuHao();
                    m_stocks.replace(pos,stock);

                    emit dataChanged(createIndex(pos,0),createIndex(pos,33));
                }
            }
       } else if(parse_doucment.isObject()){
            QStock stock(parse_doucment.object());
            int pos = m_stockIndexMap[stock.Obj()];
            if(stock.Obj().compare(m_stocks[pos].Obj()) != 0){
                qDebug()<<"updateData continue new obj:" << stock.Obj() << " old:"<<m_stocks[pos].Obj();

            }
            stock.m_Head = m_stocks[pos].Head();
            stock.m_XuHao = m_stocks[pos].XuHao();
            m_stocks.replace(pos,stock);
            emit dataChanged(createIndex(pos,0),createIndex(pos,33));
        } else {
            qDebug()<<"updateData err" ;
        }
    }

    m_mutex.unlock();
}

void QStockModel::printList(){
    int count = m_stocks.size();
    for(int i=0;i< count ;i++){

        qDebug()<<"List:"<<i << " " << m_stocks[i].Obj();
    }
}

void QStockModel::updateChildData(const int index,const QString &data){
    QDateTime dt;
    qDebug()<<"updateChildData before Size:"<<m_stocks.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");

    QTime time;
    time.start();

    m_mutex.lock();

    qDebug()<<"updateChildData lock after Size:"<<m_stocks.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");

    QJsonParseError json_error;
    QJsonDocument parse_doucment = QJsonDocument::fromJson(data.toUtf8(), &json_error);
    if(json_error.error != QJsonParseError::NoError)
    {
       qDebug()<<"appendChildData: err:"<<json_error.error ;
       return;
    }
    //当前列表股票个数
    int listCount = m_stocks.size();
    int dataCount = 0;


    if(json_error.error == QJsonParseError::NoError)
    {
        if(parse_doucment.isArray())
        {
            QJsonArray array = parse_doucment.array();
            dataCount = array.size();

            qDebug()<<"updateChildData dealarray listSize:"<< listCount<< " dataCount:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
            if(listCount == m_blockStockCount){
                //第一次展开板块列表，新增加
                m_isUpdatechildStock = true;

                m_childStockCount = dataCount;
                qDebug()<<"updateChildData beginInsertRows Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //beginInsertRows(QModelIndex(), index, index + dataCount-1);
                beginInsertRows(this->index(index-1), index, index + dataCount-1);
                qDebug()<<"updateChildData beginInsertRows after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //QList<QPersistentModelIndex> listChange;
                for(int i = 0; i < dataCount; i++){
                    QStock stock(array[i].toObject());
                    stock.m_XuHao.setNum(i+1);
                    m_stocks.insert(index+i,stock);

                    m_stockIndexMap[stock.Obj()] = index + i;

                    //listChange.append( QPersistentModelIndex(this->index(index+i)));
                }

                m_stocks[index - 1].m_Head = "-";
                qDebug()<<"updateChildData beginInsertRows to end Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                endInsertRows();
                qDebug()<<"updateChildData endInsertRows  after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                emit layoutChanged();
                //m_qmlContext->setContextProperty("blockModel", this);
                qDebug()<<"updateChildData layoutChanged after Size:"<<dataCount << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
                //emit dataChanged(createIndex(index - 1,0),createIndex(index - 1,33));
                //qDebug()<<"updateChildData: " << dataCount << "  emit "<< index <<", " << m_stocks.size();
                //emit dataChanged(createIndex(index,0),createIndex(index+ dataCount-1,33));
            } else if(dataCount > 1){


                if(m_isUpdatechildStock){
                    int oldIndex = 0;
                    for(int i = 0; i < dataCount; i++){
                        QStock stock(array[i].toObject());
                        //修改索引
                        oldIndex = m_stockIndexMap[stock.Obj()];
                        if(oldIndex == -1){
                            continue;
                        }
                        m_stockIndexMap[stock.Obj()] = i+index;
                    }
                }
            } else {
                //更新
                if(m_isUpdatechildStock){
                    for(int i = 0; i < dataCount; i++){
                        QStock stock(array[i].toObject());
                        int pos = m_stockIndexMap[stock.Obj()];

                        if(pos == -1){
                            continue;
                        }
                        stock.m_XuHao = m_stocks[pos].XuHao();
                        m_stocks.replace(pos,stock);

                        emit dataChanged(createIndex(pos,0),createIndex(pos,33));
                        //emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
                    }
                }
            }
       } else if(parse_doucment.isObject()){
            if(m_isUpdatechildStock){
                QStock stock(parse_doucment.object());
                int pos = m_stockIndexMap[stock.Obj()];
                if(pos > -1){
                    stock.m_XuHao = m_stocks[pos].XuHao();
                    m_stocks.replace(pos,stock);
                    //qDebug()<<"updateChildData: emit "<< pos <<", " << pos;
                    emit dataChanged(createIndex(pos,0),createIndex(pos,33));
                    //emit dataChanged(createIndex(0,0),createIndex(m_stocks.size(),33));
                }

            }
        } else {
            qDebug()<<"NoUpdate :" ;
        }
    }

    qDebug()<<"updateChildData " << time.elapsed() <<" ms" << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    m_mutex.unlock();
}

int QStockModel::deleteChildData(const int start){
    QTime time;
    time.start();
    m_mutex.lock();

    if(m_childStockCount == 0){
        m_mutex.unlock();
        return 0;
    }

    m_isUpdatechildStock = false;

    QDateTime dt;
    qDebug()<<"deleteChildData before Size:"<<m_stocks.size() << " "<<dt.currentDateTime().toString("yyyy:MM:dd hh:mm:ss:zzz");
    int count = m_childStockCount;
    int updateCount  = m_childStockCount;
    int sourceCount = m_stocks.length();
    //beginMoveRows(QModelIndex(), start, start+updateCount-1,QModelIndex(), 0);
    beginMoveRows(this->index(start-1), start, start+updateCount-1,QModelIndex(), 0);

//    QList<QStock> headList = m_stocks.mid(0,start);
//    QList<QStock> tailList = m_stocks.mid(start+updateCount,-1);
//    headList += tailList;
//    m_stocks = headList;

    for(int i=updateCount-1;i>-1 ;i--){
        //qDebug()<<"Delete:"<<start+i << " " << m_stocks[start+i].Obj();
        //在删除数据前修改索引
        m_stockIndexMap[m_stocks[start+i].Obj()] = -1;

        m_stocks.removeAt(start+i);
    }

//    //最慢
//    m_iterStart = m_stocks.begin();
//    m_iterEnd = m_stocks.begin();
//    m_iterStart += start;
//    m_iterEnd += start+m_childStockCount;
//    m_stocks.erase(m_iterStart,m_iterEnd);


    m_stocks[start - 1].m_Head = "+";

    endInsertRows();

    emit layoutChanged();

    qDebug()<<"deleteChildData after Size:"<<m_stocks.size()<< " "<<time.elapsed() <<" ms";

    m_expandStockPos = -1;
    m_childStockCount = 0;
    m_mutex.unlock();

    //emit dataChanged(createIndex(start - 1,0),createIndex(start - 1,33));
    //emit dataChanged(createIndex(start,0),createIndex(start+updateCount-1,33));
    //emit dataChanged(createIndex(start,0),createIndex(start+updateCount-1,33));




    return count;
}

void QStockModel::setExpandPosition(const int position){
    m_mutex.lock();
    m_expandStockPos = position;
    //qDebug()<<"setExpandPosition:"<<position;
    m_mutex.unlock();
}
