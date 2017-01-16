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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2

import "../core/common"

QtObject {
    id: light
    objectName: "lightTheme"

    readonly property string fontFamily: Qt.platform.os === 'osx' ? 'Hiragino Sans GB' : 'Microsoft YaHei'
    readonly property real fontSize: 14
    readonly property int fontWeight: Font.Normal

    /*
        颜色相关
    */
    readonly property color backgroundColor: 'white'   //背景色
    readonly property color textColor: '#222222'       //默认文本颜色
    readonly property color toolbarColor: '#294683'    //标题栏颜色
    readonly property color borderColor: '#aec1da'     //内部边框颜色

    readonly property color redColor: '#ee2c2c'         //涨 红色
    readonly property color greenColor: '#1ca049'       //跌 绿色
    readonly property color normalColor: '#9aa4ad'      //平 灰色
    readonly property color volColor: '#3e6ac5'         //量价 颜色

    readonly property color blueColor: '#3e6ac5'        //蓝色
    readonly property color orangeColor: '#ff8800'      //橙色

    readonly property color hintTextColor: "#999999"    //提示性文字颜色

    readonly property color toolbarButtonTextColor: backgroundColor //菜单栏按钮文字颜色
    readonly property color toolbarButtonHoverColor: "#4A6FBE"  //菜单栏按钮鼠标移上去的效果
    readonly property color toolbarButtonCheckedColor: backgroundColor //菜单栏按钮选中的颜色
    readonly property color toolbarButtonCheckedTextColor: toolbarColor //菜单栏按钮选中的文字颜色


    readonly property color scrollbarSliderColor: "#aec1da"       //滚动条滑块颜色
    readonly property color scrollbarSliderBorderColor: "#aec1da" //滚动条滑块边框颜色
    readonly property color scrollbarBackgroundColor: "#e7e7ec"   //滚动条背景颜色

    readonly property color keyboardSpriteBoderColor: "#9fbde4"     //键盘宝边框颜色
    readonly property color keyboardSpriteInputBackgroundColor: "#f6f6f6" //键盘宝输入框背景色
    readonly property color keyboardSpriteCodeColor: "#1677d3"      //键盘宝代码颜色
    readonly property color keyboardSpriteHighlightColor: "#dde9f8" //键盘宝选中颜色
    readonly property color keyboardSpriteSeparatorLineColor: "#c7c7cb" //键盘宝分割线颜色

    readonly property color redDotColor: "red"        //红点颜色

    readonly property color popMenuBorderColor: "#6693cd"           //弹出菜单边框颜色
    readonly property color popMenuSeparatorColor:  "#dde9f8"       //弹出菜单分割线颜色
    readonly property color popMenuScollIndicatorColor: "#dde9f8"   //弹出菜单三角型颜色
    readonly property color popMenuItemSelectedColor: "#ecf2ff"     //弹出菜单项选中颜色
    readonly property color popMenuCheckableStyleColor: "#dde9f8"   //弹出菜单可选区域颜色

    readonly property color tradeButtonBorderColor: "#d3d9e6"       //交易设置界面按钮边框颜色
    readonly property color tradeButtonColor: "#e7eefc"             //交易设置界面按钮颜色
    readonly property color tradeButtonTextColor: "black"           //交易设置界面按钮文字颜色
    readonly property color tradeButtonCheckedColor: "#e9e9e9"      //交易设置界面选中颜色
    readonly property color tradeButtonCheckedBorderColor: "#d8d8d8"  //交易设置界面选中边框颜色
    readonly property color tradeButtonHoverColor: "#f6e9c9"          //交易设置界面移上去的颜色
    readonly property color tradeButtonHoverBorderColor: "#e1d3b4"    //交易设置界面移上去的边框颜色
    readonly property color tradeItemColor: "#dde9f8"               //交易设置界面菜单项的颜色
    readonly property color tradeItemHoverColor: "#ecf4ff"          //交易设置界面菜单项移上去颜色

    readonly property color selfStockDragLineColor: "#90a0f2"        //自选股拖拽高亮线条
    readonly property color selfStockDragItemColor: "#e0eafe"        //自选股拖拽背景


    property color dxspiritButtonBarBackgroundColor:"#f0f0f5"       //短线精灵二级菜单背景颜色
    property color dxspiritButtonBarBorderColor:"#aec1da"           //短线精灵二级菜单边框颜色
    property color dxspiritButtonBarTextColor:"#7f8c98"             //短线精灵二级菜单按钮背景颜色
    property color dxspiritButtonBarCheckedTextColor:"#222222"      //短线精灵二级菜单按钮文本颜色
    property color dxspiritDialogListBackgroundColor:"#f3f3f3"      //短线精灵设置对话框列表背景颜色
    property color dxspiritDialogListCheckBoxCheckedColor:"#294683" //短线精灵设置对话框列表勾选框选中颜色
    property color dxspiritDialogListScrollBarColor:"#e5e5e5"       //短线精灵设置对话框列表滚动条背景颜色
    property color dxspiritDialogListSliderColor:"#e6e6e6"          //短线精灵设置对话框列表滚动条滑块颜色
    property color dxspiritDialogButtonColor:"#294683"              //短线精灵设置对话框按钮背景颜色
    property color dxspiritDialogButtonTextColor:"#ffffff"          //短线精灵设置对话框按钮文本颜色
    property color dxspiritUpColor: "#d90b15"                       //短线精灵列表通知上涨颜色
    property color dxspiritDownColor: "#1ca049"                     //短线精灵列表通知下跌颜色
    property color dxspiritDdColor: "#ffa302"                       //短线精灵列表通知大单颜色
    property color dxspiritJgUpColor: "#dc5fdc"                     //短线精灵列表通知机构上涨颜色
    property color dxspiritJgDownColor: "#857400"                   //短线精灵列表通知机构下跌颜色

    property color financeDigitColor: "#1677d3"                     //财务数据数字颜色
    property color financeTextColor: "#666666"                      //财务数据文本颜色
    property color financeRowSelectedColor: "#ecf2ff"               //财务数据行选中颜色


    /*
        布局相关
    */
    readonly property int toolbarHeight: 34               //菜单栏高度
    readonly property int toolbarMiniHeight: 20           //小菜单栏高度
    readonly property int toolbarBackItemRectWidth: 70    //菜单栏返回按钮布局宽度
    readonly property int toolbarBackItemButtonWidth: 50  //菜单栏返回按钮宽度
    readonly property int toolbarBackItemButtonHeight: 22 //菜单栏返回按钮高度

    readonly property int toolbarMenuButtonWidth: 56      //菜单栏菜单按钮宽度
    readonly property int toolbarMenuButtonHeight: 22     //菜单栏菜单按钮高度
    readonly property int toolbarControlButtonHeight: toolbarHeight //菜单栏控制按钮高度
    readonly property int toolbarControlButtonWidth: toolbarHeight  //菜单栏控制按钮宽度
    readonly property int toolbarLogoWidth: 70;        //菜单栏logo高度
    readonly property int toolbarLogoHeight: 22;       //菜单栏logo高度

    readonly property int stockTableNavigationButtonWidth:186 //二级菜单按钮宽度，沪深，自选按钮等宽度
    readonly property color stockTableNavigationButtonTextColor:"#294683" //二级菜单按钮字体颜色

    readonly property int statusbarHeight: 30          //底部状态栏高度
    readonly property int statusbarIndexNameWidth: 65 //底部状态栏指数名称宽度
    readonly property int statusbarIndexValueWidth: Qt.platform.os === 'osx' ? 85 : 70 //底部状态栏指数值宽度
    readonly property int statusbarIndexDiffWidth: Qt.platform.os === 'osx' ? 65 : 60  //底部状态栏指数涨跌宽度
    readonly property int statusbarIndexPersentWidth: Qt.platform.os === 'osx' ? 65 : 60 //底部状态栏指数百分比宽度
    readonly property int statusbarIndexAmountWidth: Qt.platform.os === 'osx' ? 80 : 75  //底部状态栏指数成交额宽度
    readonly property int statusbarButtonWidth: 30       //底部状态栏按钮宽度
    readonly property int statusbarTimerWidth: Qt.platform.os === 'osx' ? 80 : 72       //底部状态栏时间显示宽度
    readonly property int statusbarPopRectWidth: 300     //底部状态栏弹出窗口宽度
    readonly property int statusbarPopRectHeight: 200    //底部状态栏弹出窗口高度

    readonly property int keyboardSpriteWidth: 302     //键盘精灵宽度
    readonly property int keyboardSpriteHeight: 370    //键盘精灵高度
    readonly property int keyboardSpriteInputHeight: 26    //键盘精灵输入框高度

    readonly property int redDotSize: 4                 //红点大小
    readonly property int redDotSpacing: 1              //红点间距

    readonly property int scrollbarSize: 10             //滚动条的宽度    
    readonly property int tableScrollbarSize: 12        //表格的滚动条的宽度
    readonly property int dropdownImageSize: 10         //下拉图片的宽度

    readonly property int tradeButtonWidth: 84          //交易设置界面按钮宽度
    readonly property int tradeButtonHeight: 30         //交易设置界面按钮高度
    readonly property int tradeSpace: 10                //交易设置界面按钮间隙
    readonly property int tradeButtonRadius: 3          //交易设置界面按钮圆角程度
    readonly property int tradeItemHeight: 30           //交易设置界面列表高度
    readonly property int tradeItemDefaultWidth: 88     //交易设置界面列表默认区域宽度

    readonly property int newsNavigationButtonWidth: stockTableNavigationButtonWidth           //资讯栏目二级导航宽度
    readonly property color newsNavigationButtonTextColor: stockTableNavigationButtonTextColor //资讯栏目二级导航颜色

    readonly property string imageSuffix: Screen.devicePixelRatio >= 2 ? '@2x.png': '.png'

    /*
        图片资源相关
    */

    //图片资源路径
    readonly property string logoPath:  "/dzh/images/logo" + imageSuffix
    readonly property string entrustIconPath: imagePath + "EntrustIcon" + imageSuffix
    readonly property string imagePath: '/dzh/images/themes/light/'

    //回退区域背景图片
    property string backItemBackground: Qt.resolvedUrl(imagePath + "BackItemBackground" + imageSuffix)
    property string rightImage: Qt.resolvedUrl(imagePath + "Right.png")
    property string upImage: Qt.resolvedUrl(imagePath + "Up.png")
    property string downImage: Qt.resolvedUrl(imagePath + "Down.png")
    property string selectedImage: Qt.resolvedUrl(imagePath + "Selected.png")
    property string dropdownImage: Qt.resolvedUrl(imagePath + "Dropdown.png")

    //滚动条图片
    property string scrollBarUpImage: Qt.resolvedUrl(imagePath + "ScrollBarUp.png")
    property string scrollBarDownImage: Qt.resolvedUrl(imagePath + "ScrollBarDown.png")
    property string scrollBarLeftImage: Qt.resolvedUrl(imagePath + "ScrollBarLeft.png")
    property string scrollBarRightImage: Qt.resolvedUrl(imagePath + "ScrollBarRight.png")

    property IconResource iconDxSpiritSet: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "DxSpiritSet" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    //自选图片 已激活
    property IconResource iconZiXuan: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "ZiXuan" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    property IconResource iconZiXuanNoActivate: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "ZiXuanNoActivate" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    //最近浏览
    property IconResource iconRecentRead: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "RecentRead" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    property IconResource iconRecentReadNoActivate: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "RecentReadNoActivate" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    //关闭按钮图片资源
    property IconResource iconClose: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "Close" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "CloseHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "ClosePress" + imageSuffix)
    }

    //关闭按钮图片资源
    property IconResource iconMiniClose: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "MiniClose" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "MiniCloseHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "MiniClosePress" + imageSuffix)
    }

    //委托关闭按钮资源
    property IconResource mediumIconClose: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "MediumClose" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "MediumCloseHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "MediumCloseHover" + imageSuffix)
    }

    //委托图标
    property IconResource iconEntrust: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "EntrustIcon" + imageSuffix)
        hoverIcon: ''
        pressIcon: ''
    }

    //最小化按钮图片资源
    property IconResource iconMinimize: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "Minimize" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "MinimizeHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "MinimizePress" + imageSuffix)
    }


    //最大化按钮图片资源
    property IconResource iconMaximize: IconResource{
        defaultIcon: Qt.resolvedUrl(imagePath + "Maximize" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "MaximizeHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "MaximizePress" + imageSuffix)
    }

    //复原按钮图片资源
    property IconResource iconRestore: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "Restore" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "RestoreHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "RestorePress" + imageSuffix)
    }

    //时间按钮图片资源
    property IconResource iconTimer: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "Timer" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    //网络断线状态按钮图片资源
    property IconResource iconNetworkOffline: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "NetworkOffline" + imageSuffix)
        hoverIcon:  Qt.resolvedUrl(imagePath + "NetworkOfflineHover" + imageSuffix)
        pressIcon:  Qt.resolvedUrl(imagePath + "NetworkOfflineHover" + imageSuffix)
    }

    //网络状态按钮图片资源
    property IconResource iconNetwork: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "Network" + imageSuffix)
        hoverIcon:  Qt.resolvedUrl(imagePath + "NetworkHover" + imageSuffix)
        pressIcon:  Qt.resolvedUrl(imagePath + "NetworkHover" + imageSuffix)
    }

    //搜索按钮图片资源
    property IconResource iconSearch: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "Search" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "SearchHover" + imageSuffix)
        pressIcon: ""
    }

    //无内容时的返回按钮资源
    property IconResource iconBackArrowNull: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "BackArrowNull" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "BackArrowNull" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "BackArrowNull" + imageSuffix)
    }

    //有内容时的返回按钮资源
    property IconResource iconBackArrow: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "BackArrow" + imageSuffix)
        hoverIcon: Qt.resolvedUrl(imagePath + "BackArrowHover" + imageSuffix)
        pressIcon: Qt.resolvedUrl(imagePath + "BackArrow" + imageSuffix)
    }

    //回退区域下拉按钮图片资源
    property IconResource iconBackItemDropdown: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "BackItemDropdown" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    property IconResource iconRightHide: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "RightHide" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    property IconResource iconList: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "List" + imageSuffix)
        hoverIcon: ""
        pressIcon: ""
    }

    // 下部隐藏按钮图片资源
    property IconResource iconBottomHide: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "BottomHide" + imageSuffix)
    }

    // 左边部分隐藏按钮图片资源
    property IconResource iconLeftHide: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "LeftHide" + imageSuffix)
    }

    // 添加自选股图片资源
    property IconResource iconAddMyStocks: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "AddMyStocks" + imageSuffix)
    }

    // 删除自选股图片资源
    property IconResource iconRemoveMyStocks: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "RemoveMyStocks" + imageSuffix)
    }

    // 删除自选股图片资源
    property IconResource iconIndicatorClose: IconResource {
        defaultIcon: Qt.resolvedUrl(imagePath + "IndicatorClose.png")
        hoverIcon: Qt.resolvedUrl(imagePath + "IndicatorCloseHover.png")
    }

    /**
     * RightSideBar 右边栏组件
     */
    readonly property int rightSideBarComponentMargin: 8
    readonly property int rightSideBarComponentRowSpacing: 0 //Screen.height < 800 ? 0 : 8

    // -1 表示自动高度，由字体大小而定
    readonly property int rightSideBarComponentRowHeight: 21

    readonly property color rightSideBarHighLight: '#ecf2ff'
    readonly property color rightSideBarLabelColor: '#666666'
    readonly property int rightSideBarTextFontSize: fontSize
    readonly property int rightSideBarTextFontWeight: fontWeight
    readonly property string rightSideBarTextFontFamily: fontFamily
    readonly property color rightSideBarTextColor: textColor
    readonly property color rightSideBarUpColor: redColor
    readonly property color rightSideBarDownColor: greenColor
    readonly property color rightSideBarVolumeColor: volColor

    readonly property int rightSideBarTitleLeftMargin: rightSideBarComponentMargin
    readonly property int rightSideBarTitleRightMargin: rightSideBarTitleLeftMargin
    readonly property int rightSideBarTitleTopMargin: 5
    readonly property int rightSideBarTitleBottomMargin: rightSideBarTitleTopMargin
    readonly property int rightSideBarTitleRowSpacing: Qt.platform.os === 'osx' ? 8 : 3//rightSideBarComponentRowSpacing
    readonly property int rightSideBarTitleColumnSpacing: rightSideBarComponentMargin

    readonly property color rightSideBarNameColor: rightSideBarTextColor
    readonly property int rightSideBarNameFontSize: 18
    readonly property int rightSideBarNameFontWeight: Font.Medium
    readonly property string rightSideBarNameFontFamily: rightSideBarTextFontFamily

    readonly property color rightSideBarCodeColor: rightSideBarTextColor
    readonly property int rightSideBarCodeFontSize: 16
    readonly property int rightSideBarCodeFontWeight: Font.Medium
    readonly property string rightSideBarCodeFontFamily: rightSideBarTextFontFamily

    readonly property color rightSideBarPriceColor: normalColor
    readonly property color rightSideBarPriceUpColor: rightSideBarUpColor
    readonly property color rightSideBarPriceDownColor: rightSideBarDownColor
    readonly property int rightSideBarPriceFontSize: 22
    readonly property int rightSideBarPriceFontWeight: Font.Medium
    readonly property string rightSideBarPriceFontFamily: rightSideBarTextFontFamily

    readonly property color rightSideBarUpDownColor: normalColor
    readonly property color rightSideBarUpDownUpColor: rightSideBarUpColor
    readonly property color rightSideBarUpDownDownColor: rightSideBarDownColor
    readonly property int rightSideBarUpDownFontSize: 12
    readonly property int rightSideBarUpDownFontWeight: rightSideBarTextFontWeight
    readonly property string rightSideBarUpDownFontFamily: rightSideBarTextFontFamily

    readonly property color rightSideBarRatioColor: normalColor
    readonly property color rightSideBarRatioUpColor: rightSideBarUpColor
    readonly property color rightSideBarRatioDownColor: rightSideBarDownColor
    readonly property int rightSideBarRatioFontSize: 12
    readonly property int rightSideBarRatioFontWeight: rightSideBarTextFontWeight
    readonly property string rightSideBarRatioFontFamily: rightSideBarTextFontFamily

    readonly property color rightSideBarMarkColor: '#ff8800'
    readonly property int rightSideBarMarkFontSize: 14
    readonly property int rightSideBarMarkFontWeight: rightSideBarTextFontWeight
    readonly property string rightSideBarMarkFontFamily: rightSideBarTextFontFamily
    readonly property int rightSideBarMarkWidth: 18
    readonly property int rightSideBarMarkHeight: rightSideBarMarkWidth

    readonly property color rightSideBarBorderColor: borderColor
    readonly property int rightSideBarMiniChartHeight: 240

    /**
     * BuySellComponent 买卖盘组件
     */
    readonly property color buySellLabelColor: rightSideBarLabelColor
    readonly property int buySellLabelFontSize: rightSideBarTextFontSize
    readonly property int buySellLabelFontWeight: rightSideBarTextFontWeight
    readonly property string buySellLabelFontFamily: rightSideBarTextFontFamily

    readonly property color buySellPriceColor: normalColor
    readonly property color buySellPriceUpColor: rightSideBarUpColor
    readonly property color buySellPriceDownColor: rightSideBarDownColor
    readonly property int buySellPriceFontSize: rightSideBarTextFontSize
    readonly property int buySellPriceFontWeight: rightSideBarTextFontWeight
    readonly property string buySellPriceFontFamily: rightSideBarTextFontFamily

    readonly property color buySellVolumeColor: rightSideBarVolumeColor
    readonly property int buySellVolumeFontSize: rightSideBarTextFontSize
    readonly property int buySellVolumeFontWeight: rightSideBarTextFontWeight
    readonly property string buySellVolumeFontFamily: rightSideBarTextFontFamily

    readonly property color buySellChangeColor: normalColor
    readonly property color buySellChangeUpColor: rightSideBarUpColor
    readonly property color buySellChangeDownColor: rightSideBarDownColor
    readonly property int buySellChangeFontSize: 10
    readonly property int buySellChangeFontWeight: rightSideBarTextFontWeight
    readonly property string buySellChangeFontFamily: rightSideBarTextFontFamily

    readonly property int buySellComponentRowLeftMargin: rightSideBarComponentMargin
    readonly property int buySellComponentRowRightMargin: rightSideBarComponentMargin
    readonly property int buySellComponentRowTopMargin: rightSideBarComponentRowSpacing / 2
    readonly property int buySellComponentRowBottomMargin: buySellComponentRowTopMargin
    readonly property int buySellComponentRowHeight: rightSideBarComponentRowHeight

    // -1 表示自动宽度
    readonly property int buySellLabelPreferredWidth: -1
    readonly property int buySellPricePreferredWidth: 80
    readonly property int buySellVolumePreferredWidth: 80
    readonly property int buySellChangePreferredWidth: 40

    /**
     * DynaComponent 动态详情组件
     */
    readonly property color dynaLabelColor: rightSideBarLabelColor
    readonly property int dynaLabelFontSize: rightSideBarTextFontSize
    readonly property int dynaLabelFontWeight: rightSideBarTextFontWeight
    readonly property string dynaLabelFontFamily: rightSideBarTextFontFamily
    readonly property int dynaLabelPreferredWidth: 30
    readonly property int dynaValuePreferredWidth: 60

    readonly property color dynaComponentColor: normalColor
    readonly property color dynaComponentUpColor: rightSideBarUpColor
    readonly property color dynaComponentDownColor: rightSideBarDownColor
    readonly property int dynaComponentFontSize: rightSideBarTextFontSize
    readonly property int dynaComponentFontWeight: rightSideBarTextFontWeight
    readonly property string dynaComponentFontFamily: rightSideBarTextFontFamily

    readonly property color dynaComponentDynaColor: orangeColor
    readonly property color dynaComponentFixColor: volColor

    readonly property int dynaComponentLeftMargin: rightSideBarComponentMargin
    readonly property int dynaComponentRightMargin: rightSideBarComponentMargin
    readonly property int dynaComponentTopMargin: 0
    readonly property int dynaComponentBottomMargin: 0
    readonly property int dynaComponentRowSpace: rightSideBarComponentRowSpacing
    readonly property int dynaComponentColumnSpace: 4
    readonly property int dynaComponentRowPreferredHeight: rightSideBarComponentRowHeight

    /**
     * DynaComponent 分笔组件
     */
    readonly property color tickLabelColor: rightSideBarLabelColor
    readonly property int tickLabelFontSize: rightSideBarTextFontSize
    readonly property int tickLabelFontWeight: rightSideBarTextFontWeight
    readonly property string tickLabelFontFamily: rightSideBarTextFontFamily
    readonly property int tickLabelPreferredWidth: 40

    readonly property color tickPriceColor: normalColor
    readonly property color tickPriceUpColor: rightSideBarUpColor
    readonly property color tickPriceDownColor: rightSideBarDownColor
    readonly property int tickPriceFontSize: rightSideBarTextFontSize
    readonly property int tickPriceFontWeight: rightSideBarTextFontWeight
    readonly property string tickPriceFontFamily: rightSideBarTextFontFamily
    readonly property int tickPricePreferredWidth: 70

    readonly property color tickVolumeColor: normalColor
    readonly property color tickVolumeUpColor: rightSideBarUpColor
    readonly property color tickVolumeDownColor: rightSideBarDownColor
    readonly property int tickVolumeFontSize: rightSideBarTextFontSize
    readonly property int tickVolumeFontWeight: rightSideBarTextFontWeight
    readonly property string tickVolumeFontFamily: rightSideBarTextFontFamily
    readonly property int tickVolumePreferredWidth: 60

    readonly property color tickChangeColor: rightSideBarVolumeColor
    readonly property int tickChangeFontSize: rightSideBarTextFontSize
    readonly property int tickChangeFontWeight: rightSideBarTextFontWeight
    readonly property string tickChangeFontFamily: rightSideBarTextFontFamily
    readonly property int tickChangePreferredWidth: 40

    readonly property int tickRowLeftMargin: rightSideBarComponentMargin
    readonly property int tickRowRightMargin: rightSideBarComponentMargin
    readonly property int tickRowTopMargin: rightSideBarComponentRowSpacing / 2
    readonly property int tickRowBottomMargin: buySellComponentRowTopMargin
    readonly property int tickRowHeight: 24


    /*StockTable 股票列表*/
    readonly property color stockTableNavigationBackGroundColor: "#dde9f8"
    readonly property int stockTableNavigationHeight: 30

    readonly property color stockTableHeadBackGroundColor: "#f3f8ff"

    readonly property int stockTableRowHeight: 30   //行高
    readonly property int stockTableHeadHeight: 30  //表头高度
    readonly property int stockTableScrollSpeed: 30 //滚轮速度

    readonly property int stockTableNomalColumnWidth: 100
    readonly property int stockTableSmallColumnWidth: 50

    readonly property color stockTableBackGroundColor: "white"
    readonly property color stockTableBorderColor: "#bdc3c7"
    readonly property color stockTableRowSelectColor: "#cfe2f3"
    readonly property color stockTableRowNoSelectColor: "transparent"
    readonly property color stockTableFontDefaultColor: "#222222" //默认字体颜色
    readonly property color stockTableChildRowBackGroundColor: "#e6f0ff" //板块指数，子节点背景颜色
    readonly property color stockTableRowChangeBackGroundColor: "#EEEE00" //板块指数，数据变化高亮背景颜色

    /*StockListView 个股左侧列表*/
    readonly property color stockListNavigationBackGroundColor: "#dde9f8"
    readonly property int stockListRowHeight: 54
    readonly property int stockListFontRightMargin: 10
    readonly property int stockListFontLeftMargin: 10
    readonly property int stockListFontTopMargin: 5

    readonly property color stockListRowSelectColor: "#dce5fa"
    readonly property color stockListRowOddColor: "#f6f7f7"
    readonly property color stockListRowEvenColor: "#ffffff"
    readonly property color stockListFontDefaultColor: "#222222"
    readonly property color stockListRowHoverColor: "#ecf2ff"


    /**
     * NewsWindow 新闻窗口
     */
    readonly property int newsWindowUpMargin: 30
    readonly property int newsWindowRightMargin: 30
    readonly property int newsWindowBottomMargin: 0
    readonly property int newsWindowLeftMargin: 30

    readonly property string newsTitleFontFamily: fontFamily
    readonly property int newsTitleFontSize: 24
    readonly property int newsTitleFontWeight: Font.Medium
    readonly property color newsTitleColor: textColor
    readonly property int newsTitleUpMargin: 0
    readonly property int newsTitleRightMargin: 0
    readonly property int newsTitleBottomMargin: 50
    readonly property int newsTitleLeftMargin: 0

    readonly property string newsSourceFontFamily: fontFamily
    readonly property int newsSourceFontSize: fontSize
    readonly property int newsSourceFontWeight: fontWeight
    readonly property color newsSourceColor: textColor
    readonly property int newsSourceUpMargin: 0
    readonly property int newsSourceRightMargin: 10
    readonly property int newsSourceBottomMargin: 0
    readonly property int newsSourceLeftMargin: 0

    readonly property string newsDateFontFamily: fontFamily
    readonly property int newsDateFontSize: fontSize
    readonly property int newsDateFontWeight: fontWeight
    readonly property color newsDateColor: textColor
    readonly property int newsDateUpMargin: 0
    readonly property int newsDateRightMargin: 0
    readonly property int newsDateBottomMargin: 0
    readonly property int newsDateLeftMargin: 0

    readonly property string newsContentFontFamily: fontFamily
    readonly property int newsContentFontSize: fontSize
    readonly property int newsContentFontWeight: fontWeight
    readonly property color newsContentColor: textColor
    readonly property int newsContentUpMargin: 35
    readonly property int newsContentRightMargin: 0
    readonly property int newsContentBottomMargin: 0
    readonly property int newsContentLeftMargin: 0

    /**
     * Panel 面板控件
     */
    readonly property color panelHeaderBackgroundColor: '#dde9f8'
    readonly property color panelBorderColor: borderColor
    readonly property real panelHeaderHeight: 30
    readonly property color panelContentBackgroundColor: backgroundColor


    /**
     * TabBar TabBar控件
     */
    readonly property color tabBarBackgroundColor: '#f0f0f5'
    readonly property color tabBarTabColor: 'transparent'
    readonly property color tabBarTabTextColor: textColor
    readonly property color tabBarTabHoveredColor: '#aec1da'
    readonly property color tabBarTabHoveredTextColor: '#ffffff'
    readonly property color tabBarTabCheckedColor: tabBarTabHoveredColor
    readonly property color tabBarTabCheckedTextColor: tabBarTabHoveredTextColor
    readonly property color tabBarTabBorderColor: borderColor
    readonly property real tabBarTabBorderWidth: 1
    readonly property real tabBarTabWidth: 60
    readonly property real tabBarTabPadding: 10

    /**
     * TabPanel Tab面板控件
     */
    readonly property color tabPanelTabColor: 'transparent'
    readonly property color tabPanelTabTextColor: textColor
    readonly property color tabPanelTabHoveredColor: backgroundColor
    readonly property color tabPanelTabHoveredTextColor: volColor
    readonly property color tabPanelTabCheckedColor: tabPanelTabHoveredColor
    readonly property color tabPanelTabCheckedTextColor: tabPanelTabHoveredTextColor
    readonly property color tabPanelTabBorderColor: borderColor
    readonly property real tabPanelTabWidth: 84

    /**
     * PanelButton 面板按钮控件
     */
    readonly property color panelButtonColor: 'transparent'
    readonly property color panelButtonTextColor: '#294683'
    readonly property color panelButtonBorderColor: panelButtonColor
    readonly property color panelButtonHoveredColor: '#edf5ff'
    readonly property color panelButtonHoveredTextColor: panelButtonTextColor
    readonly property color panelButtonHoveredBorderColor: '#aec1da'
    readonly property color panelButtonCheckedColor: backgroundColor
    readonly property color panelButtonCheckedTextColor: textColor
    readonly property color panelButtonCheckedBorderColor: '#294683'

    readonly property real panelButtonBorderWidth: 1
    readonly property real panelButtonBorderRadius: 2
    readonly property real panelButtonLeftPadding: 10
    readonly property real panelButtonRightPadding: panelButtonLeftPadding
    readonly property real panelButtonTopMargin: 2
    readonly property real panelButtonBottomMargin: panelButtonTopMargin
    readonly property real panelButtonMenuMinWidth: 100

    /**
     * Indicator 指示器控件
     */
    readonly property color indicatorBackgroundColor: '#dde9f8'
    readonly property color indicatorBorderColor: '#294683'
    readonly property color indicatorTextColor: '#294683'
    readonly property real indicatorMargin: 5
    readonly property real indicatorRadius: 3
    readonly property real indicatorTextTopPadding: 4
    readonly property real indicatorTextBottomPadding: indicatorTextTopPadding
    readonly property real indicatorTextLeftPadding: 6
    readonly property real indicatorTextRightPadding: indicatorTextLeftPadding

    /**
     * BaseChart 走势图控件
     */
    readonly property int chartFontSize: 13
    readonly property string chartFontFamily: fontFamily
    readonly property color chartUpColor: redColor
    readonly property color chartDownColor: greenColor
    readonly property color chartTextColor: textColor
    readonly property int chartDefaultLineWidth: 1

    readonly property int chartGridLineWidth: chartDefaultLineWidth
    readonly property color chartGridLineColor: '#eeeeee'

    readonly property color chartTickColor: chartTextColor
    readonly property string chartTickFontFamily: chartFontFamily
    readonly property int chartTickFontSize: chartFontSize

    readonly property color chartTopBackgroundColor: "#f0f0f5"
    readonly property color chartTopBorderColor: borderColor
    readonly property real chartTopHeight: 22

    /**
     * 十字光标样式
     */
    readonly property real chartCrossLineWidth: chartDefaultLineWidth
    readonly property color chartCrossLineColor: '#294683'
    readonly property color chartCrossLineLabelColor: '#3e6ac5'
    readonly property color chartCrossLineLabelTextColor: '#ffffff'
    readonly property string chartCrossLineLabelFontFamily: chartTickFontFamily
    readonly property int chartCrossLineLabelFontSize: chartTickFontSize

    /**
     * ChartTooltip
     */
    readonly property color chartTooltipBorderColor: borderColor

    /**
     * MAChart
     */
    readonly property color maChartMA5Color: '#222222'
    readonly property color maChartMA10Color: '#ff8802'
    readonly property color maChartMA20Color: '#d3141a'
    readonly property color maChartMA30Color: '#4ca92a'
    readonly property color maChartMA60Color: '#3e6ac5'
    readonly property color maChartMA120Color: '#e66de6'

    /**
     * MACDChart
     */
    readonly property color macdChartDEAColor: '#ff8802'
    readonly property color macdChartDIFFColor: '#3e6ac5'

    /**
     * KDJChart
     */
    readonly property color kdjChartKColor: '#222222'
    readonly property color kdjChartDColor: '#ff8802'
    readonly property color kdjChartJColor: '#e66de6'

    /**
     * RSIChart
     */
    readonly property color rsiChart1Color: '#222222'
    readonly property color rsiChart2Color: '#ff8802'
    readonly property color rsiChart3Color: '#e66de6'

    /**
     * DDXChart
     */
    readonly property color ddxChart1Color: '#ff8802'
    readonly property color ddxChart2Color: '#e66de6'
    readonly property color ddxChart3Color: '#4ca92a'

    /**
     * DDYChart
     */
    readonly property color ddyChart1Color: '#ff8802'
    readonly property color ddyChart2Color: '#e66de6'
    readonly property color ddyChart3Color: '#4ca92a'

    /**
     * TSChart
     */
    readonly property color tsChartUpNumberColor: '#ff00ff'
    readonly property color tsChartDownNumberColor: '#00aeff'
    readonly property color tsChartUpLineColor: tsChartUpNumberColor
    readonly property color tsChartDownLineColor: tsChartDownNumberColor
    readonly property color tsChartBuySignalColor: tsChartUpNumberColor
    readonly property color tsChartSellSignalColor: tsChartDownNumberColor
}
