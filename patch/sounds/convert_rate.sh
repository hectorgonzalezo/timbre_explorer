#!/bin/bash

read -p 'Directory to convert to 48k: ' ORIGINAL

#ORIGINAL=./oboeFluteBass16/
TARGET=./${ORIGINAL//16/}/
mkdir $TARGET

for f in ./${ORIGINAL}/* 
do
	name=$(echo "$f" | cut -d'/' -f3 )
	echo $name
	ffmpeg -i $f -ar 48000 -y $TARGET$name
done
