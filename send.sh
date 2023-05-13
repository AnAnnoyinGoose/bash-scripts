#!/bin/bash

# arguments:
# $1: file to send
# $2: user@x.x.x.x:/dir/dir/

if  [ $# -ne 2 ]; then
  echo "a"
    echo "Usage: $0 <file> <user@x.x.x.x:/dir/dir/>"
    exit 1
fi

if [ ! -f .sshpwd.gpg ]; then
    echo "No .sshpwd.gpg file found, exiting..."
    exit 1
fi

if ! command -v ssh &> /dev/null; then
    echo "ssh is not installed.."
    read -p "Do you want to install it? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if [ -f ect/os-release ]; then
        . ./ect/os-release
        if [ "$ID" = "ubuntu" ]; then
          sudo apt install ssh
          echo "ssh installed rerun the command"
          exit 1
        fi
        if [ "$ID" = "debian" ]; then
          sudo apt install ssh
          echo "ssh installed rerun the command"
          exit 1
        fi
        if [ "$ID" = "centos" ]; then
          sudo yum install ssh
          echo "ssh installed rerun the command"
          exit 1
        fi
        if [ "$ID" = "fedora" ]; then
          sudo dnf install ssh
          echo "ssh installed rerun the command"
          exit 1
        fi
        if [ "$ID" = "arch" ]; then
          sudo pacman -S ssh
          echo "ssh installed rerun the command"
          exit 1
        fi
      fi
      echo "No supported distro found, please install ssh manually and rerun the script"
      exit 1
    fi
    exit 1
fi
# check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass is not installed.."
  read -p "Do you want to install it? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # get the distro
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      echo "OS: $PRETTY_NAME"
      if [ "$ID" = "ubuntu" ]; then
        sudo apt install sshpass
        echo "sshpass installed rerun the command"
        exit 1
      fi
      if [ "$ID" = "debian" ]; then
        sudo apt install sshpass
        echo "sshpass installed rerun the command"
        exit 1
      fi
      if [ "$ID" = "centos" ]; then
        sudo yum install sshpass
        echo "sshpass installed rerun the command"
        exit 1
      fi
      if [ "$ID" = "fedora" ]; then
        sudo dnf install sshpass
        echo "sshpass installed rerun the command"
        exit 1
      fi
      if [ "$ID" = "arch" ]; then
        sudo pacman -S sshpass
        echo "sshpass installed rerun the command"
        exit 1
      fi
    fi
    echo "No supported distro found, please install sshpass manually and rerun the script"
    exit 1
  fi
  exit 1
fi
gpg -d -q .sshpwd.gpg | sshpass scp "$1" "$2"
if [ $? -eq 0 ]; then
    echo "File sent successfully"
    exit 0
else
    echo "File not sent"
    echo "Error code: $?"
    exit 1
fi

