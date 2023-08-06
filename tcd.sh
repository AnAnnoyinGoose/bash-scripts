#!/bin/bash
#
# TCD [temp change directory]
# Allows running commands in a different directory
# Usage: tcd [directory] [command]
# example: tcd ~/tmp 'ls -l' or tcd build make
#
# !The command will create the directory if it doesn't exist!
#

OLDPWD=$PWD
cd $1
if [ ! -d $1 ]; then
  mkdir $1
fi 

if [ -n "$2" ]; then
  eval $2
fi 
cd
cd $OLDPWD

