#!/bin/sh

clean(){
  umount $MNT
  qemu-nbd -d /dev/nbd${DEV}
  rmmod nbd
}

set -x
set -e

# Defaults to zero, or one, respectively, unless set explicitly
DEV=${DEV-0}
PARTITION=${PARTITION-1}
IMG="$1"
MNT="$2"
CONTRIB="$3"

if [ $# -ne 3 ]; then
  echo "There has to be three arguments"
  echo "  Usage: $0 <VM image> <dir mountpoint> <contrib-root>"
  echo "  Example of contrib-root structure:
    contrib/
    ├── etc
    │   └── YaST2
    │       └── licenses
    │           └── base
    │               └── license.txt
    ├── jeos-firstboot.patch
    ├── root
    │   └── add_jeos_qa_fakes.patch
    └── usr
        └── lib
            ├── jeos-firstboot
            └── jeos-firstboot-functions"
  exit 1
fi

echo "VM image file : $IMG"
echo "Mountpoint dir: $MNT"
echo "Contrib-root  : $CONTRIB" # ← contributed patches, and files here
if ! [ -r "$IMG" -a -d "$MNT" -a -d "$CONTRIB" ]; then
  echo "One of following files either does not exist,"
  echo "or is not readable, or is not writable:"
  exit 2
fi

modprobe nbd max_part="10"
qemu-nbd -c /dev/nbd${DEV} "$IMG"
mount /dev/nbd${DEV}p${PARTITION} $MNT
trap clean EXIT

# prepare the system
rm -fv "$MNT"/etc/YaST2/licenses/base/no-acceptance-needed
# Copy files/dirs first, then patch them
for file in `ls --group-directories-first ${CONTRIB}`; do
  if [[ "$file" =~ .*\.patch$ ]]; then
    patch -d "$MNT" -p1 < "$CONTRIB"/"$file"
  else
    # Do not overwrite existing files
    cp -nvr "$CONTRIB""$file" "$MNT"
  fi
done
