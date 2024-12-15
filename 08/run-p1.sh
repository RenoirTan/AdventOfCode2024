#!/bin/sh

if [ -z $1 ]; then
    echo "No file included!"
    exit 1
fi

cat p1.sql | sed "s|@FILEPATH@|$1|g" | sqlite3 # dangerous