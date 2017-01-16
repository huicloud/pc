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

#include <QJsonObject>
#include <QJsonArray>

#include <proto/MSG.pb.h>
#include <string>
#include <limits>
#include <QDebug>
#include <math.h>
#include "yfloat.h"


double parseYFloat(qint64 val, double * r) {

    static double ratio[] = {1e2, 1e1, 1.0, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1.0};
    static int    dp[]    = {2,1,0,3,4,5,6,7,8,9,0};

    if (val < 0){
        return std::numeric_limits<double>::quiet_NaN();
    }

    qint64 B = (val >> 16) & 0xFF;
    qint64 L = B & 0x0F;
    qint64 H = (B >> 4) & 0x0F;

    if(L == 2){
        return std::numeric_limits<double>::quiet_NaN();
    }

    double Bx = ((val >> 24) << 16) + (val & 0xFFFF);


    if (r != NULL){
        *r = ratio[L];
    }

    if (H == 1){
        return -(Bx / ratio[L]);
    }else{
        return (Bx / ratio[L]);
    }
}


QJsonValue parseRepField(
    const google::protobuf::Message * msg,
    const google::protobuf::Reflection * ref,
    const google::protobuf::FieldDescriptor * field);



QJsonValue parsePb(const google::protobuf::Message * msg){

    const google::protobuf::Descriptor *d = msg->GetDescriptor();
    if(!d)
        return QJsonValue();
    size_t count = d->field_count();
    QJsonObject root;
    for (size_t i = 0; i != count ; ++i)
    {
        const google::protobuf::FieldDescriptor *field = d->field(i);
        if(!field)
            return QJsonValue();

        const google::protobuf::Reflection *ref = msg->GetReflection();
        if(!ref)
            return QJsonValue();
        const QString & name(field->name().c_str());

        //qDebug()<<"Field:"<<name<<field->is_repeated()<<" isHasField:"<<ref->HasField(*msg,field);
        if(field->is_repeated())
            root[name] = parseRepField(msg, ref, field);
        if(!field->is_repeated() && ref->HasField(*msg,field))
        {

            double parseValue = 0.0;
            switch (field->cpp_type())
            {
            case google::protobuf::FieldDescriptor::CPPTYPE_DOUBLE:
                root[name] = QJsonValue(ref->GetDouble(*msg, field));
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_FLOAT:
                root[name] = QJsonValue(ref->GetFloat(*msg, field));
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_INT64:
                parseValue = parseYFloat(ref->GetInt64(*msg, field));
                root[name] = isnan(parseValue) ? QJsonValue():QJsonValue(parseValue);
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_UINT64:
                root[name] = QJsonValue(qint64(ref->GetUInt64(*msg, field)));
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_INT32:
                root[name] = QJsonValue(ref->GetInt32(*msg, field));
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_UINT32:
                root[name] = QJsonValue(qint32(ref->GetUInt32(*msg, field)));
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_BOOL:
                root[name] = QJsonValue(ref->GetBool(*msg, field));
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_STRING:
                root[name] = QJsonValue(ref->GetString(*msg, field).c_str());
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_MESSAGE:{
                QJsonValue val = parsePb(&(ref->GetMessage(*msg, field)));
                if (!val.isNull())
                    root[name] = val;
            }
                break;
            case google::protobuf::FieldDescriptor::CPPTYPE_ENUM:
                root[name] = QJsonValue(ref->GetEnumValue(*msg, field));
                break;
            default:
                break;
            }
        }
    }
    return QJsonValue(root);
}

QJsonValue parseRepField(
    const google::protobuf::Message * msg,
    const google::protobuf::Reflection * ref,
    const google::protobuf::FieldDescriptor * field) {

    size_t count = ref->FieldSize(*msg,field);
    QJsonArray arr;
    double parseValue = 0.0;
    switch(field->cpp_type())
    {
    case google::protobuf::FieldDescriptor::CPPTYPE_DOUBLE:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(ref->GetRepeatedDouble(*msg,field,i));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_FLOAT:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(ref->GetRepeatedFloat(*msg,field,i));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_INT64:
        for(size_t i = 0 ; i != count ; ++i){
            parseValue = parseYFloat(ref->GetRepeatedInt64(*msg,field,i));
            arr.append(isnan(parseValue) ? QJsonValue():QJsonValue(parseValue));
        }

        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_UINT64:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(qint64(ref->GetRepeatedUInt64(*msg,field,i)));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_INT32:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(ref->GetRepeatedInt32(*msg,field,i));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_UINT32:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(qint32(ref->GetRepeatedUInt32(*msg,field,i)));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_BOOL:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(ref->GetRepeatedBool(*msg,field,i));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_STRING:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(ref->GetRepeatedString(*msg,field,i).c_str());
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_MESSAGE:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(parsePb(&(ref->GetRepeatedMessage(*msg,field,i))));
        break;
    case google::protobuf::FieldDescriptor::CPPTYPE_ENUM:
        for(size_t i = 0 ; i != count ; ++i)
            arr.append(ref->GetRepeatedEnumValue(*msg, field, i));
        break;
    default:
        break;
    }
    return arr;
}

QJsonValue msg2json(const dzhyun::MSG & msg){
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    const google::protobuf::Descriptor *d = msg.GetDescriptor();
    const google::protobuf::FieldDescriptor *field = d->FindFieldByNumber(msg.id());
    const google::protobuf::Reflection *ref = msg.GetReflection();

    if (field == NULL){
        return QJsonValue();
    }

    return parseRepField(&msg, ref, field);

}
