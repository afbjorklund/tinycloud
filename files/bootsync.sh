#!/bin/sh
# put other system startup commands here, the boot process will wait until they complete.
# Use bootlocal.sh for system startup commands that can run in the background 
# and therefore not slow down the boot process.
/usr/bin/sethostname box

echo "event=button/power" > /usr/local/etc/acpi/events/power
echo "action=/sbin/poweroff" >> /usr/local/etc/acpi/events/power
/usr/local/etc/init.d/acpid start

/opt/bootlocal.sh &
