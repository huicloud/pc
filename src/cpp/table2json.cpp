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

#include "proto/dzhpbtable.pb.h"
#include "proto/MSG.pb.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>
#include <QVariantList>
#include "yfloat.h"
#include <math.h>

QJsonArray table2array(const dzhyun::Table & table){
    QJsonArray array;


    int firstType = table.info(0).type();

    int rows = 0;

    switch(firstType){
    case dzhyun::Type_Table:
        rows = table.data(0).tvalues_size();
        break;
    case dzhyun::Type_SInt:
        rows = table.data(0).xvalues_size();
        break;
    case dzhyun::Type_Int:
        rows = table.data(0).ivalues_size();
        break;
    case dzhyun::Type_String:
        rows = table.data(0).svalues_size();
        break;
    }

    QString tableName (table.name().c_str());

    double * sValue = new double[table.info_size()];
    double * rValue = new double[table.info_size()];
    for (int i = 0; i < rows; i++){
        QJsonObject obj;
        for(int j = 0; j < table.info_size(); j++){
            const dzhyun::CInfo & info = table.info(j);
            QString name(info.name().c_str());

            switch(info.type()){
            case dzhyun::Type_Table:
                obj[name] = table2array(table.data(j).tvalues(i));
                break;
            case dzhyun::Type_SInt:{
                if (i == 0){
                    sValue[j] = floor(parseYFloat(table.data(j).xvalues(i), rValue + j) * rValue[j] + 0.5);
                }else{
                    int ratio = info.ratio() ? info.ratio() : 1;
                    sValue[j] += table.data(j).xvalues(i) * ratio;
                }
                obj[name] = sValue[j] / rValue[j];
            }
                break;
            case dzhyun::Type_Int:{
                obj[name] = parseYFloat(table.data(j).ivalues(i));
            }
                break;
            case dzhyun::Type_String:
                obj[name] = QString(table.data(j).svalues(i).c_str());
                break;
            }
        }
        array.append(obj);
    }
    delete sValue;
	delete rValue;
    return array;

}

QJsonValue table2json(const dzhyun::MSG & msg){
    return table2array(msg.tbl().data(0).tvalues(0));
}
