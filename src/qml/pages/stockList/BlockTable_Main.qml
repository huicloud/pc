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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../../core"
import "../../components"
import "../../components/blockList/main"

/*沪深股列表*/
BasePage {
    id: root;

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        StockTable {
            id : blockTableView
            Layout.fillHeight: true
            Layout.fillWidth: true
            focus: true

            onSetRightSideBarVisible: {
                rightSideBar.visible = isVisible;
                //console.log("onSetRightSideBarVisible focus:"+blockTableView.focusobjRow+" start:"+blockTableView.startPos);
            }
        }

        RightSideBar {
            id: rightSideBar
            Layout.fillHeight: true
            Layout.preferredWidth: 260
            visible: false

            obj: {
                return blockTableView.focusobjParam;
            }

            sideBarType: 1
        }
    }

    onAfterActive:{
        //激活页面
        blockTableView.activePage();
        blockTableView.focus = true;
    }

    onAfterDeactive: {
        //休眠页面
        blockTableView.deActivePage();
        blockTableView.focus = false;
    }

    onReconnect: {
        //console.log("onReconnect");
        // 重连后重新请求页面
        //休眠页面
        blockTableView.deActivePage();
        blockTableView.focus = false;

        //激活页面
        blockTableView.activePage();
        blockTableView.focus = true;
    }
}
