#!/bin/sh
TARGET=/persisted/.aws
if [ ! -f ${TARGET}/config ]
then 
    mkdir -p /persisted/.aws
    cp -f -R ${HOME}/.awsCOPY/* ${TARGET}
    for a in ${TARGET}/*
    do
        dos2unix "${a}" 2>/dev/null
    done
fi
