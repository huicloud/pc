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

#include "qframelesswindow.h"
#include <QDebug>
#include <QScreen>
QFrameLessWindow::QFrameLessWindow(QQuickWindow *parent) :
    QQuickWindow(parent)
{

    //mOldCursor = this->cursor();
    mIsPressed = false;
    mCursorSection = Center;
    mLastTime = 0;
    mCanResize = true;

    setFlags(Qt::Window|Qt::FramelessWindowHint|Qt::WindowSystemMenuHint|Qt::WindowMinimizeButtonHint|Qt::WindowMaximizeButtonHint);
    this->setWidth(800);
    this->setHeight(600);
    this->setMinimumHeight(300);
    this->setMinimumWidth(200);

    // this->showMaximized();

    mIsSelectedWebViewState = false;
}

QFrameLessWindow::~QFrameLessWindow()
{

}


void QFrameLessWindow::mouseMoveEvent(QMouseEvent *e){

    if (!mCanResize){
          //不能拖动大小的状态标记
          QQuickWindow::mouseMoveEvent(e);
          return;
    }

    //1.拖动改变窗口大小时，不能小于最小宽度和最小高度
   // 2.暴露边框大小属性
    int posx = this->x();
    int posy = this->y();
    int width = this->width();
    int height = this->height();
    int margin = 5;

    int left1 = posx - margin;
    int left2 = posx + margin;
    int right1 = posx + width - margin;
    int right2 = posx + width + margin;
    int top1 = posy - margin;
    int top2 = posy + margin;
    int bottom1 = posy + height - margin;
    int bottom2 = posy + height + margin;

    int mousex = e->globalX();
    int mousey = e->globalY();
    mMouseX = mousex; //记录鼠标位置

    if(!mIsPressed){

        if(mousex > left1 && mousex < left2){
            if(mousey > bottom1 && mousey < bottom2){
                //leftbottom
                mCursorSection = LeftBottom;
            } else if(mousey > top1 && mousey < top2){
                //lefttop
                mCursorSection = LeftTop;
            } else if (mousey >= top2 && mousey <= bottom1){
                mCursorSection = Left;
            }
        } else if(mousex > right1 && mousex < right2){
            if(mousey > bottom1 && mousey < bottom2){
                //rightbottom
                mCursorSection = RightBottom;
            } else if(mousey > top1 && mousey < top2){
                //righttop
                mCursorSection = RightTop;
            } else if(mousey >= top2 && mousey <= bottom1) {
                mCursorSection = Right;
            }
        } else if(mousey > bottom1 && mousey < bottom2){
            mCursorSection = Bottom;
        } else if(mousey > top1 && mousey < top2){
            mCursorSection = Top;
        } else if((mousey >= top2 && mousey <= top2 + margin * 2)
                  || (mousex >= left2 && mousex <= left2 + margin * 2)
                  || (mousex >= right1 - margin * 2 && mousex <= right1)
                  || (mousey >= bottom1 - margin * 2 && mousey <= bottom1)){
            mCursorSection = InnerBorder;
        } else {
            mCursorSection = Center;
        }
    }else{
        //拖动时避免重绘太频繁，小于20毫秒的改变不处理
        int difMoveTime = e->timestamp() - mLastTime;
        if(difMoveTime < 30){
            return;
        }
        mLastTime = e->timestamp();

        //qDebug() << "mouseMoveEvent" << e->timestamp() ;
    }

    int newx, newy, newwidth, newheight;
    switch(mCursorSection){
    case Left:{
            this->setCursor(Qt::SizeHorCursor);
            if(mIsPressed){
                int dx = posx - mousex;
                if(dx != 0){
                    newx = posx - dx;
                    newwidth = width + dx;
                    if(newx > 0 && newwidth > 200)
                        this->setPosition(newx,posy);
                    if(newwidth > 200)
                        this->setWidth(newwidth);
                }
            }
            break;
        }
    case Right:{
            this->setCursor(Qt::SizeHorCursor);
            if(mIsPressed){
                int dx = mousex - posx - width;
                newwidth = width + dx;
                if(dx != 0 && newwidth > 200){
                    this->setWidth(newwidth);
                }
            }
            break;
        }
    case Bottom:{
            this->setCursor(Qt::SizeVerCursor);
            if(mIsPressed){
                int dy = mousey - posy - height;
                newheight = height + dy;
                if(dy != 0 && newheight > 400){
                    this->setHeight(newheight);
                }
            }
            break;
        }
    case Top:{
            this->setCursor(Qt::SizeVerCursor);
            if(mIsPressed){
                int dy = posy - mousey;
                newheight = height + dy;
                newy = posy - dy;
                if(dy != 0){
                    if(newheight > 400)
                        this->setHeight(height + dy);
                    if(newy > 0 && newheight > 400)
                        this->setPosition(posx,newy);
                }
            }
            break;
        }
    case LeftBottom:{
            this->setCursor(Qt::SizeBDiagCursor);
            if(mIsPressed){
                int dx = posx - mousex;
                int dy = mousey - posy - height;
                if(dx != 0 || dy != 0){
                    newwidth = width + dx;
                    newheight = height + dy;
                    newx = posx - dx;

                    if(newwidth > 200)
                        this->setWidth(newwidth);
                    if(newheight > 400)
                        this->setHeight(newheight);
                    if(newx > 0 && newheight > 400 && newwidth > 200)
                        this->setPosition(newx,posy);
                }
            }
            break;
        }
    case LeftTop:{
            this->setCursor(Qt::SizeFDiagCursor);
            if(mIsPressed){
                int dx = posx- mousex;
                int dy = posy - mousey;
                if(dx != 0 || dy != 0){
                    newx = posx - dx;
                    newy = posy - dy;
                    newwidth = width + dx;
                    newheight = height + dy;
                    if(newwidth > 200)
                        this->setWidth(newwidth);
                    if(newheight > 400)
                        this->setHeight(newheight);
                    if(newx > 0 && newy >= 0 && newheight > 400 && newwidth > 200)
                        this->setPosition(newx,newy);
                }
            }
            break;
        }
    case RightBottom:{
            this->setCursor(Qt::SizeFDiagCursor);
            if(mIsPressed){
                int dx = mousex - posx - width;
                int dy = mousey - posy - height;
                if(dx != 0 || dy != 0){
                    newwidth = width + dx;
                    newheight = height + dy;
                    if(newwidth > 200)
                        this->setWidth(newwidth);
                    if(newheight > 400)
                        this->setHeight(newheight);
                }
            }
            break;
        }
    case RightTop:{
            this->setCursor(Qt::SizeBDiagCursor);
            if(mIsPressed){
                int dx = mousex - posx - width;
                int dy = posy - mousey;
                if(dx != 0 || dy != 0){
                    newy = posy -dy;
                    newwidth = width + dx;
                    newheight = height + dy;
                    if(newy > 0 && newheight > 400 && newwidth > 200)
                        this->setPosition(posx,newy);
                    if(newwidth > 200)
                        this->setWidth(newwidth);
                    if(newheight > 400)
                        this->setHeight(newheight);
                }
            }
            break;
        }
    case InnerBorder:{
            this->unsetCursor();
            QQuickWindow::mouseMoveEvent(e);
            break;
        }
    case Center:{
            //if(!mIsSelectedWebViewState){
                //this->unsetCursor();
            //}
            QQuickWindow::mouseMoveEvent(e);
            break;
        }
    }
}

void QFrameLessWindow::mousePressEvent(QMouseEvent *e){
    mIsPressed = true;  //移到外面暂不影响
    if(mCursorSection >= Left && mCursorSection < InnerBorder){
        mIsPressed = true;
        mPressPoint = e->globalPos();
    } else {
        if (mIsSelectedWebViewState && (e->button() == Qt::RightButton)){
            //屏蔽WebView上的鼠标右键事件
            //QQuickWindow::mousePressEvent(e);
        }else{
           QQuickWindow::mousePressEvent(e);
        }
    }
}
void QFrameLessWindow::mouseDoubleClickEvent(QMouseEvent *e){
    if (mIsSelectedWebViewState && (e->button() == Qt::RightButton)){
        //屏蔽WebView上的鼠标右键事件
    }else{
       QQuickWindow::mousePressEvent(e);
    }
}
void QFrameLessWindow::keyPressEvent(QKeyEvent *e){
    if (mIsSelectedWebViewState && (e->key() == Qt::Key_Escape)){
        //WebView中屏蔽ESC键
        int key = e->key();
        emit webViewKeyEventTrigger(key);
    }else{
       if (mIsPressed && (mMouseX > (this->screen()->size().width() - 8))){
            //do nothing 屏蔽系统产生的键盘事件的特殊处理
       }else{
            QQuickWindow::keyPressEvent(e);
       }
    }
}

void QFrameLessWindow::keyReleaseEvent(QKeyEvent *e){
    QQuickWindow::keyReleaseEvent(e);
}

void QFrameLessWindow::mouseReleaseEvent(QMouseEvent *e){
    if(mIsPressed){
        mIsPressed = false;
    }
    QQuickWindow::mouseReleaseEvent(e);
}

bool QFrameLessWindow::canResize() const{
   return mCanResize;
}

void QFrameLessWindow::setCanResize(const bool canResize){
    mCanResize = canResize;
}

bool QFrameLessWindow::isSelectedWebViewState() const{
    return mIsSelectedWebViewState;
}

void QFrameLessWindow::setIsSelectedWebViewState(const bool isSelected){
   mIsSelectedWebViewState = isSelected;
}

bool QFrameLessWindow::isShowMaximized() const{
    return mIsShowMaximized;
}

void QFrameLessWindow::setIsShowMaximized(const bool isShowMaximized){
   mIsShowMaximized = isShowMaximized;
}

