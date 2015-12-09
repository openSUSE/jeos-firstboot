#!/bin/bash

set -x
. /usr/lib/jeos-firstboot-functions
rootfs="`stat -f -c %T /`"
if [ "$rootfs" = 'btrfs' ]; then
	echo "creating initial snapper config ..."
	snapper --no-dbus -v -c root create-config /
	# add fstab entry for .snapshots
	sed -i -e '/@\/tmp/{p;s/tmp/.snapshots/g}' /etc/fstab
	mount .snapshots
	create_snapshot 1 "Factory status"
fi
zypper ar -f http://download.opensuse.org/tumbleweed/repo/oss/ repo-oss
zypper ar -f http://download.opensuse.org/tumbleweed/repo/non-oss/ repo-non-oss
zypper ar -f http://download.opensuse.org/update/tumbleweed repo-update-oss
# Fix btrfs subvolumes
chattr +C /var/lib/mysql
chattr +C /var/lib/mariadb
chattr +C /var/lib/pgsql
chattr +C /var/lib/libvirt/images
