#!/bin/bash

set -x
. /usr/lib/jeos-firstboot-functions
rootfs="`stat -f -c %T /`"
if [ "$rootfs" = 'btrfs' ]; then
	echo "creating initial snapper config ..."
	# we can't call snapper here as the .snapshots subvolume
	# already exists and snapper create-config doens't like
	# that.
	cp /etc/snapper/config-templates/default /etc/snapper/configs/root
	# Change configuration to match SLES12-SP1 values
	sed -i -e '/^TIMELINE_CREATE=/s/yes/no/' /etc/snapper/configs/root
	sed -i -e '/^NUMBER_LIMIT=/s/50/10/'     /etc/snapper/configs/root

	sed -i -e '/^SNAPPER_CONFIGS=/s/"/"root/' /etc/sysconfig/snapper
	mount .snapshots
	retrofit_snapper_info 1 "first root filesystem"
	create_snapshot 2 "Intermediate status"
fi
#
# Fix btrfs subvolumes
chattr +C /var/lib/mysql
chattr +C /var/lib/mariadb
chattr +C /var/lib/pgsql
chattr +C /var/lib/libvirt/images
