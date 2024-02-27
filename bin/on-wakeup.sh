#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin

# Workaround to keep laptop suspended if it wakes during lid close
if [[ "${1}" == "post" ]]; then
    echo "$(date) Have resumed..." >> /tmp/wake.log
    grep -q closed /proc/acpi/button/lid/LID0/state
    if [ $? = 0 ]
    then
        echo "$(date) Have resumed and lid is closed, attempting to suspend..." >> /tmp/wake.log
        echo freeze > /sys/power/state
    fi
fi

