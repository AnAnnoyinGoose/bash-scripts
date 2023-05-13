#!/bin/bash

password=$1 
date=`date +%Y%m%d_%H%M%S` 
files=`ls ./*/*.jpg  ./*/*.png ./*/*.gif ./*/*.mp4 ./*/*.webm ./*/*.txt ./*.jpg ./*.png ./*.gif ./*.mp4 ./*.webm ./*.txt`

if [ -f $date.tar.gz ]; then
  echo -e "\e[31m$date.tar.gz already exists\e[0m"
  read -p "Do you want to remove it? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    rm $date.tar.gz
  else
    echo -e '\e[31mAborted\e[0m'
    exit 1
  fi
fi

tar -zcf $date.tar.gz $files


if [ $? -eq 0 ]; then 
  echo -e "\e[32mSuccess\e[0m"
else
  echo -e "\e[31mFailed\e[0m"
fi

read -p "Do you want to encrypt the file? (y/N) " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
  # check if file exists
  echo -e "\e[32mEncrypting...\e[0m"
  if [ -z $password ]; then
    echo -e "\e[31mPassword is required\e[0m"
    read -p "Password: " password
  fi
  openssl enc -e -aes-256-cbc -in $date.tar.gz -out $date.tar.gz.enc -pass pass:$password
  if [ $? -eq 0 ]; then 
    echo -e "\e[32mFile encrypted\e[0m"
    read -p  "Do you want to remove the unencrypted file? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
      then
        rm $date.tar.gz
    fi
    echo -e "\e[32mTo decrypt the file, use:\n\t openssl enc -d -aes-256-cbc -in $date.tar.gz.enc -out $date.tar.gz -pass pass:$password \n\t rm $date.tar.gz.enc \n\t \e[0m" 
  else 
    echo -e "\e[31mFailed\e[0m"
  fi
else 
  echo -e "\e[32mFile not encrypted\e[0m"
fi
echo -e "\e[32mTo extract the file, use: \n\t mkdir $date && tar -xf $date.tar.gz -C $date/\e[0m"
