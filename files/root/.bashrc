#!/bin/bash

EULA_FILE=/etc/YaST2/licenses/base/license.txt
EULA_ACCEPTED=/root/.EULA_ACCEPTED

if [ ! -e $EULA_ACCEPTED ]; then
    snapper -c root create-config /

    snapper create -d "Factory Status" --userdata "important=yes"

# /usr/sbin/setkeymap

    if [ $TERM = "dumb" ]; then
        cat $EULA_FILE
    else
        less $EULA_FILE
    fi
    echo
    ANSWER="undef"
    while [ ! "$ANSWER" = "y" -a ! "$ANSWER" = "Y" -a ! "$ANSWER" = "n" -a ! "$ANSWER" = "N" ]
    do
        echo
        echo -n "Do you accept this license (y/n)? "
        read ANSWER
    done
    if [ "$ANSWER" = "y" -o "$ANSWER" = "Y" ]; then
        echo "License accepted!"
        date > $EULA_ACCEPTED
    else
        echo
        echo
        echo
        echo "**************************************************"
        echo "* License NOT accepted!  Shutting down system... *"
        echo "**************************************************"
        halt -p
        exit 0
    fi

(
cat <<EOF
if [ -z "$extra_cmdline" ]; then
  submenu  "Start bootloader from a read-only snapshot" {
      if [ x$snapshot_found != xtrue ]; then
         submenu "Not Found" { true; }
      fi
  }
fi
EOF
) > /.snapshots/grub-snapshot.cfg

    grub2-mkconfig -o /boot/grub2/grub.cfg

    snapper create -d "Initial Status" --userdata "important=yes"
fi

