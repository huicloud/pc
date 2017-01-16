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

#ifndef QFRAMELESSWINDOW_H
#define QFRAMELESSWINDOW_H

#include <QQuickWindow>
#include <QMouseEvent>
#include <QCursor>

class QFrameLessWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(bool isSelectedWebViewState READ isSelectedWebViewState WRITE setIsSelectedWebViewState)
    Q_PROPERTY(bool isShowMaximized READ isShowMaximized WRITE setIsShowMaximized)
    Q_PROPERTY(bool canResize READ canResize WRITE setCanResize)
    Q_ENUMS(State)

public:
    enum BORDERSECTION{
        Left,Right,Bottom,Top,
        LeftBottom,LeftTop,
        RightBottom,RightTop,
        InnerBorder,Center
    };

    bool canResize() const;
    void setCanResize(const bool canResize);

    bool isSelectedWebViewState() const;
    void setIsSelectedWebViewState(const bool isSelected);

    bool isShowMaximized() const;
    void setIsShowMaximized(const bool isShowMaximized);

public:

    explicit QFrameLessWindow(QQuickWindow *parent = 0);
    ~QFrameLessWindow();

signals:
    void webViewKeyEventTrigger(const int key);

protected:

    virtual void mouseMoveEvent(QMouseEvent *e);
    virtual void mousePressEvent(QMouseEvent *e);
    virtual void mouseReleaseEvent(QMouseEvent *e);
    virtual void mouseDoubleClickEvent(QMouseEvent *e);
    virtual void keyPressEvent(QKeyEvent *e);
    virtual void keyReleaseEvent(QKeyEvent *e);
private:

    //QCursor mOldCursor;
    bool mIsSelectedWebViewState;
    bool mIsShowMaximized: true;
    bool mIsPressed;
    bool mCanResize;

    int mMouseX;
    QPoint mPressPoint;
    BORDERSECTION mCursorSection;
    ulong mLastTime;
};

#endif // QFRAMELESSWINDOW_H
