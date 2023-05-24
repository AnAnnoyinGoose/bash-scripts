#!/bin/bash

# Arch Java Switcher
# uses rofi to select a Java version
# archlinux-java for the java version list

java_version_list=()

while IFS= read -r line; do
  if [[ $line != "Available Java environments:" ]]; then
    java_version_list+=("$line")
  fi
done <<< "$(archlinux-java status)"



selected=$(printf '%s\n' "${java_version_list[@]}" | rofi -dmenu -i -p "Select Java version")

sudo archlinux-java set "$selected"
