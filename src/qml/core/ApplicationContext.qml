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

import "./"
import "data"

/**
 * 应用上下文单例组件
 */
QtObject {

    // 页面导航，在window启动后赋值
    property PageNavigator pageNavigator

    // 主题管理
    property var themeManager: ThemeManager

    // 数据连接
    property var dataChannel: DataChannel

    // 全局配置
    property var setting: GlobalSetting

    // 主窗体
    property var mainWindow
    // 通用的新闻 公告展示窗口
    property var commonNewsWindow
}
