#!/bin/sh

clean(){
  umount $MNT
  qemu-nbd -d /dev/nbd${DEV}
  rmmod nbd
}

#set -x
set -e

# Defaults to zero, or one, respectively, unless set explicitly
DEV=${DEV-0}
PARTITION=${PARTITION-1}
IMG="$1"
MNT="$2"
PATCHES="$3"

if [ $# -lt 3 ]; then
  echo "There has to be three arguments"
  echo "Usage: $0 <image> <mountpoint> <patches>"
  exit 1
fi

if ! [ -r "$IMG" -a -d "$MNT" -a -r "$PATCHES" ]; then
  echo "One of following files either does not exist,"
  echo "or is not readable, or is not writable:"
  echo "  Image:                       $IMG"
  echo "  Mountpoint:                  $MNT"
  echo "  Patches (firstboot, others): $PATCHES"
  exit 2
fi

modprobe nbd max_part="10"
qemu-nbd -c /dev/nbd${DEV} "$IMG"
mount /dev/nbd${DEV}p${PARTITION} $MNT
[ ! -e "$MNT"/etc/YaST2/licenses/base/license.txt ] && \
  mkdir -p "$MNT"/etc/YaST2/licenses/base/ && \
  touch "$MNT"/etc/YaST2/licenses/base/license.txt
rm -fv "$MNT"/etc/YaST2/licenses/base/no-acceptance-needed
trap clean EXIT
for patch in `seq 3 $#`; do
  eval epatch=\$$patch
  patch -d "$MNT" -p1 < $epatch
done
