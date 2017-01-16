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

pragma Singleton
import QtQuick 2.0
import QtWebEngine 1.2
import Dzh.DZHWebEngineProfile 1.0

/*程序的相关配置*/
QtObject {
    id: applicationConfigure

    property DZHWebEngineProfile webProfile: DZHWebEngineProfile {
        id: profiles
        storageName: "QDZH"
        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        httpUserAgent: "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36"
    }

    readonly property string routePathSelfStock: '/zixuanguliebiao'
    readonly property string routePathMarketList: '/hushenliebiao'
    readonly property string routePathStockDetail: '/liebiao/xiangxi'
    readonly property string routePathSelectStock: '/xuangu'
    readonly property string routePathTrade: '/jiaoyi'
    readonly property string routePathNews: '/zixun'
    readonly property string routePathMessage: '/xiaoxi'
    readonly property string routePathProfile: '/wode'
    readonly property string routePathFeedback: '/fankui'

    //路由表，应用启动后从配置中加载，包含路径对应的qml文件，路径有功能层次结构
    property var routeMap: ({
                                '/zixuanguliebiao': '/dzh/pages/stockList/ZiXuan.qml',
                                '/hushenliebiao' : '/dzh/pages/stockList/StockTable_Main.qml',
                                '/liebiao/xiangxi' : '/dzh/pages/Detail.qml',
                                '/xuangu' : '/dzh/pages/PickStock.qml',
                                '/jiaoyi' : '/dzh/pages/Trade.qml',
                                '/zixun' : '/dzh/pages/News.qml',
                                '/wode' : '/dzh/pages/Profile.qml',
                                '/xiaoxi' : '/dzh/pages/Messages.qml',
                                '/fankui' : '/dzh/pages/Feedback.qml'
                            });

    //快捷键名称对应
    property var keysMap:({
                              '06': '自选股',
                              '060': '自选股',
                              '03': '上证指数',
                              '04': '深证成指',
                              '05': '创业板指',
                              '31': '热点板块涨幅排名',
                              '60': '全部A股涨幅排名',
                              '61': '上A涨幅排名',
                              '63': '深A涨幅排名',
                              '67': '创业板涨幅排名',
                              '69':'中小企业涨幅排名'
                          })

    //本地键盘宝缓存  type = 0 股票; type = 1 行情列表;  type = 2 走势图; type = 3 常用指数 type = 99 分割线
    property QtObject localKBSprite: QtObject {
        property int type: 6
        property int queryCount: 50
        property string markert: 'SH,SZ,B$'
        property var keys: [{
                DaiMa: '1',
                MingCheng: '1分钟K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'1min'}
            }, {
                DaiMa: '2',
                MingCheng: '5分钟K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'5min'}
            }, {
                DaiMa: '3',
                MingCheng: '15分钟K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'15min'}
            }, {
                DaiMa: '4',
                MingCheng: '30分钟K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'30min'}
            }, {
                DaiMa: '5',
                MingCheng: '60分钟K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'60min'}
            }, {
                DaiMa: '6',
                MingCheng: '日K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'1day'}
            }, {
                DaiMa: '7',
                MingCheng: '周K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'week'}
            }, {
                DaiMa: '8',
                MingCheng: '月K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'month'}
            },{
                DaiMa: '10',
                MingCheng: '个股资料',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'f10'}
            }
            , {
                DaiMa: '11',
                MingCheng: '季度K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'season'}
            }, {
                DaiMa: '12',
                MingCheng: '半年K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'halfyear'}
            }, {
                DaiMa: '13',
                MingCheng: '年K线图',
                ShuXing: '快捷键',
                Type: 2,
                Params: {'chart':'kline', 'period':'year'}
            },{
                DaiMa: '03',
                MingCheng: keysMap['03'],
                ShuXing: '快捷键',
                Type: 3,
                Params: {'obj':'SH000001', 'chart':'min', 'type':3}
            },{
                DaiMa: '04',
                MingCheng: keysMap['04'],
                ShuXing: '快捷键',
                Type: 3,
                Params: {'obj':'SZ399001', 'chart':'min', 'type':3}
            },{
                DaiMa: '05',
                MingCheng: keysMap['05'],
                ShuXing: '快捷键',
                Type: 3,
                Params: {'obj':'SZ399006', 'chart':'min', 'type':3}
            },{
                DaiMa: '06',
                MingCheng: keysMap['06'],
                ShuXing: '快捷键',
                Params: {'type':1},
                Type: 1
            }, {
                DaiMa: '060',
                MingCheng: keysMap['060'],
                ShuXing: '快捷键',
                Params: {'type':1},
                Type: 1
            }, {
                DaiMa: '31',
                MingCheng: keysMap['31'],
                ShuXing: '快捷键',
                Params: {'market':31, 'tableHeaderType':1, 'isSprite':'true'},
                Type: 1
            }, {
                DaiMa: '60',
                MingCheng: keysMap['60'],
                ShuXing: '快捷键',
                Params: {'market':60, 'isSprite':'true'},
                Type: 1
            }, {
                DaiMa: '61',
                MingCheng: keysMap['61'],
                ShuXing: '快捷键',
                Params: {'market':61, 'isSprite':'true'},
                Type: 1
            }, {
                DaiMa: '63',
                MingCheng: keysMap['63'],
                ShuXing: '快捷键',
                Params: {'market':63, 'isSprite':'true'},
                Type: 1
            }, {
                DaiMa: '67',
                MingCheng: keysMap['67'],
                ShuXing: '快捷键',
                Params: {'market':67, 'isSprite':'true'},
                Type: 1
            }, {
                DaiMa: '69',
                MingCheng: keysMap['69'],
                ShuXing: '快捷键',
                Params: {'market':69, 'isSprite':'true'},
                Type: 1
            }]
    }

    //市场集合分类
    property var marketListMap: ({
                             'hsStock': ['60', '61', '63', '67', '69', 'st'],
                             'fund': ['ETFFund', 'ClosedFund', 'LofFund', 'GradingFundA', 'GradingFundB', 'T0Fund']
                             })

    //市场对应的分类
    property var marketTypeMap: ({
                                 '60':1, '61':1, '63':1, '67':1, '69':1, 'st':1,
                                 '31':2, 'SHINX':3, 'SZINX':4, 'CYINX':6,
                                 'ETFFund':5, 'ClosedFund':5, 'LofFund':5, 'GradingFundA':5, 'GradingFundB':5, 'T0Fund':5
                                 })

    //对应市场的中文名称
    property var marketNameMap: ({
         "60": "沪深A股", "61": "上证A股", "63": "深圳A股", "67": "创业板", "69": "中小企业板", "st": "风险警示",
         "31": "热门板块", "SHINX": "上证指数", "SZINX": "深证指数","CYINX":"常用指数",
         "ETFFund": "ETF基金", "ClosedFund": "封闭基金", "LofFund": "LOF基金",
         "GradingFundA": "分级基金A", "GradingFundB": "分级基金B", "T0Fund": "T+0基金"
     })

    //WEB页面路径
    property var webUrlMap: ({
        "yitu": {"title": "一突选股", "url": "stzb/index.html?type=0", "helpUrl": "stzb/instruction/ytxg.html"},
        "ertu": {"title": "双突选股", "url": "stzb/index.html?type=1", "helpUrl": "stzb/instruction/stxg.html"},
        "hongjiu": {"title": "红九选股", "url": "stzb/index.html?type=2", "helpUrl": "stzb/instruction/hjxg.html"},
        "lvjiu": {"title": "绿九选股", "url": "stzb/index.html?type=3", "helpUrl": "stzb/instruction/ljxg.html"},
    })

    //常用指数请求obj
    property string requestObjsCyinx: "SH000001,SZ399001,SZ399005,SZ399006,SH000300,SZ399106,SH000016,SH000905,SZ399004,IXDJIA,IXNDX,IXSPX,HKHSI,IXN225"
}
