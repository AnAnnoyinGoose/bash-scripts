#!/bin/bash
# as of 8-6-23 just found out that this isnt mine lol 
declare -a devices=(GPP0) 
for device in "${devices[@]}"; do
    if grep -qw ^$device.*enabled /proc/acpi/wakeup; then
        sudo sh -c "echo $device > /proc/acpi/wakeup"
    fi
done
