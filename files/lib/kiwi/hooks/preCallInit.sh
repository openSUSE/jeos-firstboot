#!/bin/bash

set -x
rootfs="`stat -f -c %T /`"
if [ "$rootfs" = 'btrfs' ]; then
	echo "creating initial snapper config ..."
	snapper --no-dbus -v -c root create-config /
	# add fstab entry for .snapshots
	sed -i -e '/@\/tmp/{p;s/tmp/.snapshots/g}' /etc/fstab
	mount .snapshots
	# we can't use snapper here due to missing dbus daemon in
	# firstboot. So we have to create a snapshot manually.
	#snapper --no-dbus -v create -d "Factory Status" --userdata "important=yes"
	mkdir .snapshots/1
	btrfs subvolume snapshot / .snapshots/1/snapshot
	now="`date '+%Y-%m-%d %H:%M:%S'`"
	cat > .snapshots/1/info.xml <<-EOF
	<?xml version="1.0"?>
	<snapshot>
	  <type>single</type>
	  <num>1</num>
	  <uid>0</uid>
	  <date>$now</date>
	  <description>Factory status</description>
	  <userdata>
	    <key>important</key>
	    <value>yes</value>
	  </userdata>
	</snapshot>
	EOF
fi
