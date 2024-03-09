#!/bin/bash

if [ ! -f $1 ]
then
    echo "$1 does not exist"
    exit -1
fi

if [ ! -f $2 ]
then
    echo "$2 does not exist"
    exit -1
fi

echo "'$1' -> '$2'"

first='`$'
last='^`'
sed -i "/$first/,/$last/{ /$first/{p; r $1
}; /$last/p; d }" $2
