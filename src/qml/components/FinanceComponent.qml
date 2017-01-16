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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import "../core"
import "../core/data"
import "../controls"
import "../util"
import "../js/DateUtil.js" as DateUtil

/**
 * 短线精灵数据组件
 *
 */
ContextComponent {
    id: root
    width: 350
    height: 300

    property var context: ApplicationContext
    property var theme: ThemeManager.currentTheme
    property var stock: StockUtil.stock.createObject(root)
    // 默认type=-1时不显示，type=1显示股票, type=0显示指数板块, 其它显示基金
    property int type: stock.type
    //页面当前股票代码
    property string obj:''
    property string fieldParamGuPiao: "BaoGaoQi,ZongGuBen,WuXianShouGuHeJi,MeiGuShouYi,MeiGuJingZiChan,JingZiChanShouYiLv,MeiGuJingYingXianJin,MeiGuGongJiJin,MeiGuWeiFenPei,GuDongQuanYiBi,JingLiRunTongBi,ZhuYingShouRuTongBi,XiaoShouMaoLiLv,TiaoZhengMeiGuJingZi,ZongZiChan,LiuDongZiChan,GuDingZiChan,WuXingZiChan,LiuDongFuZhai,ChangQiFuZhai,ZongFuZhai,GuDongQuanYi,ZiBenGongJiJin,JingYingXianJinLiuLiang,TouZiXianJinLiuLiang,ChouZiXianJinLiuLiang,XianJinZengJiaE,ZhuYingShouRu,ZhuYingLiRun,YingYeLiRun,TouZiShouYi,YingYeWaiShouZhi,LiRunZongE,JingLiRun,WeiFenPeiLiRun,ShangShiRiQi,LiuTongAGu,LiuTongBGu,JingWaiShangShiGu,QiTaLiuTongGu,XianShouGuHeJi,GuoJiaChiGu,GuoYouFaRenGu,JingNeiFaRenGu,JingNeiZiRanRenGu,QiTaFaQiRenGu,MuJiFaRenGu,JingWaiFaRenGu,JingWaiZiRanRenGu,YouXianGuHuoQiTa"
    property string fieldParamJiJin: "JJBaoGaoQi,JJJiaoYiNeiMa,JJJiJinDaiMa,JJBaoGaoLeiBie,JJQiMoZiChanJingZhi,JJQiMoFenEJingZhi,JJGuPiaoShiZhi,JJGuPiaoBiLi,JJZhaiQuanShiZhi,JJZhaiQuanBiLi,JJZongZiChan,JJZongFuZhai,JJWeiFenPeiLiRun,JJTouZiShouYi,JJShouRuZongJi,JJFeiYongZongJi,JJShangShiRiQi,JJLiRunZongE,JJJingLiRun,JJJingLiRunTongBi,JJQiChuZongFenE,JJChaiFenZengJiaFenE,JJQiMoZongFenE"
    property string fieldParam:stock.type > 1 ? fieldParamJiJin:fieldParamGuPiao

    property color digitColor: theme.financeDigitColor
    property color textColor: theme.financeTextColor
    property color rowSelectedColor: theme.financeRowSelectedColor
    property color nullColor: theme.financeTextColor

    property var colorList: [digitColor,textColor];//数字颜色,文本颜色

    property var dataModelGuPiao: {
        "BaoGaoQi":{index:0,colortype:0,title:"报告期:"},
        "ZongGuBen":{index:1,colortype:0,title:"总股本(万股):"},
        "WuXianShouGuHeJi":{index:2,colortype:0,title:"流通股本(万股):"},
        "MeiGuShouYi":{index:3,colortype:0,title:"每股收益(元):"},
        "MeiGuJingZiChan":{index:4,colortype:0,title:"每股净资产(元):"},
        "JingZiChanShouYiLv":{index:5,colortype:0,title:"净资产收益率(%):"},
        "MeiGuJingYingXianJin":{index:6,colortype:0,title:"每股经营现金流(元):"},
        "MeiGuGongJiJin":{index:7,colortype:0,title:"每股公积金(元):"},
        "MeiGuWeiFenPei":{index:8,colortype:0,title:"每股未分配利润(元):"},
        "GuDongQuanYiBi":{index:9,colortype:0,title:"股东权益比(%):"},
        "JingLiRunTongBi":{index:10,colortype:0,title:"净利润同比(%):"},
        "ZhuYingShouRuTongBi":{index:11,colortype:0,title:"主营收入同比(%):"},
        "XiaoShouMaoLiLv":{index:12,colortype:0,title:"销售毛利率(%):"},
        "TiaoZhengMeiGuJingZi":{index:13,colortype:0,title:"调整每股净资(元):"},
        "ZongZiChan":{index:14,colortype:0,title:"总资产(万元):"},
        "LiuDongZiChan":{index:15,colortype:0,title:"流通资产(元):"},
        "GuDingZiChan":{index:16,colortype:0,title:"固定资产(元):"},
        "WuXingZiChan":{index:17,colortype:0,title:"无形资产(万元):"},
        "LiuDongFuZhai":{index:18,colortype:0,title:"流动负债(万元):"},
        "ChangQiFuZhai":{index:19,colortype:0,title:"长期负债(万元):"},
        "ZongFuZhai":{index:20,colortype:0,title:"总负债(万元):"},
        "GuDongQuanYi":{index:21,colortype:0,title:"股东权益(万元):"},
        "ZiBenGongJiJin":{index:22,colortype:0,title:"资本公积金(万元):"},
        "JingYingXianJinLiuLiang":{index:23,colortype:0,title:"经营现金流(万元):"},
        "TouZiXianJinLiuLiang":{index:24,colortype:0,title:"投资现金流(万元):"},
        "ChouZiXianJinLiuLiang":{index:25,colortype:0,title:"筹资现金流(万元):"},
        "XianJinZengJiaE":{index:26,colortype:0,title:"现金增加额(万元):"},
        "ZhuYingShouRu":{index:27,colortype:0,title:"主营收入(万元):"},
        "ZhuYingLiRun":{index:28,colortype:0,title:"主营利润(万元):"},
        "YingYeLiRun":{index:29,colortype:0,title:"营业利润(万元):"},
        "TouZiShouYi":{index:30,colortype:0,title:"投资收益(万元):"},
        "YingYeWaiShouZhi":{index:31,colortype:0,title:"营业外收支(万元):"},
        "LiRunZongE":{index:32,colortype:0,title:"利润总额(万元):"},
        "JingLiRun":{index:33,colortype:0,title:"净利润(万元):"},
        "WeiFenPeiLiRun":{index:34,colortype:0,title:"未分配利润(万元):"},
        "ShangShiRiQi":{index:35,colortype:0,title:"上市日期:"},
        "ZongGuBen2":{index:36,colortype:0,title:"总股本(万股):"},
        "LiuTongAGu":{index:37,colortype:0,title:"流通A股(万股):"},
        "LiuTongBGu":{index:38,colortype:0,title:"流通B股(万股):"},
        "JingWaiShangShiGu":{index:39,colortype:0,title:"境外上市股(万股):"},
        "QiTaLiuTongGu":{index:40,colortype:0,title:"其他流通股(万股):"},
        "XianShouGuHeJi":{index:41,colortype:0,title:"限售股本合计(万股):"},
        "GuoJiaChiGu":{index:42,colortype:0,title:"国家持股(万股):"},
        "GuoYouFaRenGu":{index:43,colortype:0,title:"国有法人股(万股):"},
        "JingNeiFaRenGu":{index:44,colortype:0,title:"境内法人股(万股):"},
        "JingNeiZiRanRenGu":{index:45,colortype:0,title:"境内自然人股(万股):"},
        "QiTaFaQiRenGu":{index:46,colortype:0,title:"其他发起人股(万股):"},
        "MuJiFaRenGu":{index:47,colortype:0,title:"募集法人股(万股):"},
        "JingWaiFaRenGu":{index:48,colortype:0,title:"境外法人股(万股):"},
        "JingWaiZiRanRenGu":{index:49,colortype:0,title:"境外自然人(万股):"},
        "YouXianGuHuoQiTa":{index:50,colortype:0,title:"优先股或其他(万股):"}
    }
    property var dataModelJiJin: {
        "JJBaoGaoQi":{index:0,colortype:0,title:"报告期:",divisor:1},
        "JJQiMoZiChanJingZhi":{index:1,colortype:0,title:"期末资产净值(亿元):",divisor:10000},
        "JJQiMoFenEJingZhi":{index:2,colortype:0,title:"期末份额净值(元):",divisor:1},
        "JJGuPiaoShiZhi":{index:3,colortype:0,title:"股票市值(亿元):",divisor:10000},
        "JJGuPiaoBiLi":{index:4,colortype:0,title:"股票比例(%):",divisor:1},
        "JJZhaiQuanShiZhi":{index:5,colortype:0,title:"债券市值(亿元):",divisor:10000},
        "JJZhaiQuanBiLi":{index:6,colortype:0,title:"债券比例(%):",divisor:1},
        "JJZongZiChan":{index:7,colortype:0,title:"总资产(亿元):",divisor:10000},
        "JJZongFuZhai":{index:8,colortype:0,title:"总负债(亿元):",divisor:10000},
        "JJWeiFenPeiLiRun":{index:9,colortype:0,title:"未分配利润(亿元):",divisor:10000},
        "JJTouZiShouYi":{index:10,colortype:0,title:"投资收益(亿元):",divisor:10000},
        "JJShouRuZongJi":{index:11,colortype:0,title:"收入总计(亿元):",divisor:10000},
        "JJFeiYongZongJi":{index:12,colortype:0,title:"费用总计(亿元):",divisor:10000},
        "JJShangShiRiQi":{index:13,colortype:0,title:"上市日期:",divisor:1},
        "JJLiRunZongE":{index:14,colortype:0,title:"利润总额(亿元):",divisor:10000},
        "JJJingLiRun":{index:15,colortype:0,title:"净利润(亿元):",divisor:10000},
        "JJJingLiRunTongBi":{index:16,colortype:0,title:"净利润同比(%):",divisor:1},
        "JJQiChuZongFenE":{index:17,colortype:0,title:"期初总份额(万份):",divisor:1},
        "JJChaiFenZengJiaFenE":{index:18,colortype:0,title:"拆分增加份额(万份):",divisor:1},
        "JJQiMoZongFenE":{index:19,colortype:0,title:"期末总份额(万份):",divisor:1}
    }
    property var dataModel:stock.type > 1 ? dataModelJiJin:dataModelGuPiao

    //弹出窗口数据列表
    property var showData: []
    property var allData: []
    property int rowCount: Object.getOwnPropertyNames(dataModel).length

    // 请求财务数据
    property DataProvider requestDataProvider: DataProvider {
        parent: root
        serviceUrl: '/stkdata'
        params: ({
            obj:obj,
            field:fieldParam
        })

        onSuccess: {
            var colorType = 0;
            var countList = 0;
            var precision = 2;//小数精度
            var objType = stock.type;//类型
            if(objType > 1){
                precision = 4;
            }

            for (var prop in data[0]) {
                var value = data[0][prop];
                colorType = 0;
                if(typeof(value) == 'string'){
                    //值为字符串
                    colorType = 1;
                    if(value === null){
                        value = "--";
                    }
                }else{
                    if(value === null){
                        value = "--";
                        colorType = 1;
                    }
                }

                if(dataModel[prop]){
                    var dataNew = {};
                    dataNew.title = dataModel[prop].title;
                    dataNew.type = colorType
                    if(colorType === 0){
                        if(objType > 1){
                            //基金需要除因子
                            value = value/dataModel[prop].divisor;
                        }
                        dataNew.value = value.toFixed(precision);
                    }else{
                        if(prop === "BaoGaoQi" || prop === "JJBaoGaoQi"){
                            var month = parseInt(value.substr(4,2));
                            var sufficStr;
                            if(month < 4){
                                sufficStr = "一季报";
                            } else if(month < 7){
                                sufficStr = "二季报";
                            } else if(month < 10){
                                sufficStr = "三季报";
                            } else {
                                sufficStr = "四季报";
                            }

                            dataNew.value = value.substr(0,8) + sufficStr;
                        } else if(prop === "JJShangShiRiQi"){
                            dataNew.value = value.substr(0,8);
                        } else{
                            dataNew.value = value;
                        }
                    }

                    dataNew.color = colorList[colorType];
                    if(prop === "ZongGuBen"){
                        allData[dataModel["ZongGuBen2"].index] = dataNew;
                    }
                    allData[dataModel[prop].index] = dataNew;
                }
            }

            if(allData.length > 5){
                showData = allData.slice(showStartIndex,showStartIndex+showCount);
            }
        }
    }

    property int rowFontSize: 14
    property int rowFontWeight: theme.tickLabelFontWeight
    property string rowFontFamily: theme.tickLabelFontFamily
    property int volumePreferredWidth: theme.tickVolumePreferredWidth

    //行边距信息
    property int rowLeftMargin: 8
    property int rowRightMargin: theme.scrollbarSize
    property int rowTopMargin: 0
    property int rowBottomMargin: 0
    property int rowHeight: 20

    property int showCount: Math.floor(root.height / rowHeight);
    property int showStartIndex: Math.max(0, Math.ceil(flicker.visibleArea.yPosition * allData.length))

    //当前选中的行
    property string selected:''

    onObjChanged: {
        flicker.contentY = 0;
        allData = [];
        showData = [];
        requestDataProvider.query();
    }
    onShowCountChanged: {
        //更新showData
        if(allData.length > 5){
            showData = allData.slice(showStartIndex,showStartIndex+showCount);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: theme.backgroundColor
        clip: true

        Flickable {
            id: flicker
            anchors.fill: parent

            // 计算总数据高度
            contentHeight: rowHeight * rowCount
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            maximumFlickVelocity: 1000

            onContentYChanged: {
                if(allData.length > 0){
                    showData = allData.slice(showStartIndex,showStartIndex+showCount);
                }
            }
        }
        ColumnLayout {
            id: layout
            anchors.fill: flicker
            anchors.rightMargin: scrollbar.visible ? 8 : 0
            anchors.leftMargin: 0
            spacing: 0
            clip: true
            Repeater {
                model:showCount

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: scrollbar.visible ? true : false
                    Layout.preferredHeight: scrollbar.visible ? -1 : rowHeight
                    color: selected === showData[index].title ? '#ecf2ff' : 'transparent'
                    RowLayout {
                        spacing: 0
                        anchors.fill: parent
                        anchors.leftMargin: rowLeftMargin
                        anchors.rightMargin: rowRightMargin
                        anchors.topMargin: rowTopMargin
                        anchors.bottomMargin: rowBottomMargin
                        Text {
                            horizontalAlignment: Qt.AlignLeft
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //Layout.preferredWidth: 60
                            color: textColor
                            font.pixelSize: rowFontSize
                            font.weight: rowFontWeight
                            font.family: rowFontFamily
                            text: index < showData.length ? showData[index].title : ""
                        }

                        Text {
                            horizontalAlignment: Qt.AlignRight
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //Layout.preferredWidth: 60
                            color: showData[index].color
                            font.pixelSize: rowFontSize
                            font.weight: rowFontWeight
                            font.family: rowFontFamily
                            text:index < showData.length ? showData[index].value : ""
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            selected = showData[index].title;
                        }
                        onEntered: {
                             root.focus = true;
                        }
                        onExited: {
                            root.focus = false;
                        }
                    }
                }
            }

            // 用于填充剩余高度
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: scrollbar.visible ? false : true
                Layout.preferredHeight: 0
                height: 0
            }
        }
        VScrollBar {
            id: scrollbar
            flicker: flicker
        }
    }
}
