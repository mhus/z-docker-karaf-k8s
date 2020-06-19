#!/usr/bin/python

import sys
import os
import argparse

__author__ = "Mike Hummel"
__copyright__ = "Copyright 2020, Mike Hummel"
__license__ = "Apache 2.0"
__version__ = "1.0.0"
__maintainer__ = "Mike Hummel"
__email__ = "mike@mhus.de"
__status__ = "Production"

tagStart = "{{"
tagEnd = "}}"

def substline(line):
    global tagStart, tagEnd
    out = "";
    while True:
        pos = line.find(tagStart)
        if pos < 0:
            break
        out = out + line[0:pos];
        line = line[pos+len(tagStart):]
        pos = line.find(tagEnd)
        if pos < 0:
            break
        key = line[:pos]
        line = line[pos+len(tagEnd):]
        default = ""
        t = ""
        pos = key.find(":")
        if pos >= 0:
            t = key[:pos]
            key = key[pos+1:]
        pos = key.find(":")
        if pos >= 0:
            default = key[pos+1:]
            key = key[:pos]
        #print("Type: " + t + " key: " + key + " Def: " + default)
        if t == "env":
            out = out + os.getenv(key, default)
        if t == "file":
            if os.path.exists(key):
                with open(key) as f: s = f.read()
                out = out + s
            else:
                out = out + default
    out = out + line
    return out

parser = argparse.ArgumentParser(description='Substitute parameter tags in a file')
parser.add_argument('-start', help='Tag start delimiter')
parser.add_argument('-end', help='Tag end delimiter')
parser.add_argument('source', nargs='?', help='File to substitude or stdin / stdout, this will overwrite the file')
parser.add_argument('target', nargs='?', help='Output file or stdout')

args = parser.parse_args()

if not args.start is None:
    tagStart = args.start

if not args.end is None:
    tagEnd = args.end

#print("From " + tagStart + " to " + tagEnd)
#print("Source:" + args.source)
#print("Target:" + args.target)

if args.source is None:
    for line in sys.stdin:
        out = substline(line)
        sys.stdout.write(out);
elif args.target is None:
    with open(args.source) as f: content = f.read()
    for line in content.splitlines():
        out = substline(line)
        sys.stdout.write(out);
else:
    with open(args.source) as f: content = f.read()
    f = open(args.target, "w")
    for line in content.splitlines():
        out = substline(line)
        f.write(out)
    f.close()

