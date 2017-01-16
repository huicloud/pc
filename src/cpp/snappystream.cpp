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

#include "snappystream.h"
#include <snappy.h>

int copy_plain(const char * buff, std::string * output) {
    size_t len = (unsigned char)buff[1] | (unsigned char)buff[2] << 8 | (unsigned char)buff[3]<< 16;
    output->append(buff + 8, len - 4);
    return 4 + len;
}

int copy_snappy(const char * buff, std::string * output) {
    size_t len = (unsigned char)buff[1] | (unsigned char)buff[2] << 8 | (unsigned char)buff[3]<< 16;
    bool success = snappy::Uncompress(buff + 8, len - 4, output);
    return 4 + len;
}

int DecompressSnappyStream(const char * buff, size_t len, std::string * decompress) {

    size_t pos = 0;

    std::string output;

    while(pos < len) {
        unsigned char b = (unsigned char)(buff[pos]);
        switch(b) {
            case 0xFF:
                pos += 10;
                break;
            case 0x01:
                output.resize(0);
                pos += copy_plain(buff + pos, &output);
                decompress->append(output);
                break;
            case 0x00:
                output.resize(0);
                pos += copy_snappy(buff + pos, &output);
                decompress->append(output);
                break;
        }
    }
    return 0;
}
