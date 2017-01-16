#!/usr/bin/env python3
# coding: utf-8


from os import walk
from os.path import join as join_path, splitext


lic = ''

with open("copyright.txt") as f:
    lic = f.read()

def ccread(name, mode = 'r'):
    content = ''
    try:
        with open(name, mode, encoding="utf-8") as f:
            content = f.read()
        return content, 'utf-8'
    except:
        with open(name, mode, encoding="gbk") as f:
            content = f.read()
        return f, 'gbk'
    return '', ''

def work():
    exts = [".qml", ".js", ".h", ".cpp", ".cc"]
    for root, dirs, files in walk("src"):
        for fname in files:
            name, ext = splitext(fname)
            ext = ext.lower()
            if ext in exts:
                fullpath = join_path(root, fname)
                print(fullpath)
                content, enc = ccread(fullpath)


                with open(fullpath, "w", encoding=enc) as f:
                    print(lic, file=f)
                    print(content, file=f)


if __name__ == "__main__":
    work()
