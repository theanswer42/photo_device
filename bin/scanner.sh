#!/bin/sh

# This scans usb buses and figures out if the ones we need are connected
# right now. If both a disk and card(s) are found, then this should trigger
# the copy program.

# Note: If this is being called by something triggered by a device hotplug
# event, then this should wait a bit before starting the scan. Also, In this
# case, the scan itself should be protected by a lock file.

# What devices are we looking for?
# ID 8564:4000 - This is the transcend card reader) - There may be multiple
#  drives associated here
# ID 1058:0837 - This is the WD "My Passport Ultra" 1TB hard drive.
# 



for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    (
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        if echo "$devname" | grep "^bus/" > /dev/null; then
	    continue
	fi
	echo "-----------------------------------"
        udevadm info -q property --export -p $syspath
	echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
        # [[ -z "$ID_SERIAL" ]] && continue
        # echo "/dev/$devname - $ID_SERIAL"
    )
done
