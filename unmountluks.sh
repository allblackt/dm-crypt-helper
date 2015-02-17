#!/bin/bash

getopts ':h' is_help
mountpoint=$1
#trims trailing slash
mountpoint=${mountpoint%/}

ROOT_UID="0"

usage() {
    echo "Unmounts a dm-crypt container and removes device linked to container"
    echo "Usage:"
    echo $1" <MOUNT_POINT>"
}

if [ "$is_help" == "h" ]; then
    usage $0
    exit 0
fi

#Check if run as root
if [ "$UID" -ne "$ROOT_UID" ] ; then
   echo "You must be root to unmount encrypted containers!"
   exit 1
fi

if [ "$#" -ne 1 ]; then
    usage $0
    exit 1
fi

mountpoint -q $mountpoint
if [ "$?" -ne 0 ]; then
    echo $mountpoint" is not a mountpoint."
    exit 1
fi

volume_name=$(mount | grep $mountpoint | awk '{ print $1 }')
umount $mountpoint
cryptsetup luksClose $volume_name

echo "Removed device $volume_name from mount point $mountpoint"
