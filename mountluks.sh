#!/bin/bash

getopts ':h' is_help
container=$1
mountpoint=$2
# give a random name to the volume and /crossfingers that it doesn't exist
random_string=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
volume_name="volume_$random_string"

ROOT_UID="0"

if [ "$is_help" == "h" ]; then
    echo "Usage:"
    echo $0' <CONTAINER> <MOUNT_POINT>'
    exit 0
fi

#Check if run as root
if [ "$UID" -ne "$ROOT_UID" ] ; then
    echo "You must be root to do mount encrypted containers!"
    exit 1
fi

if [ ! -f $container ]; then
    echo "Container file not found!"
    exit 1
fi

if [ ! -d $mountpoint ]; then
    echo "Destination mountpoint not found!"
    exit 1
fi

cryptsetup luksOpen $1 $volume_name
if [ $? != 0 ]; then
    printf "There was a problem opening the container located at %s.\n" $container
    exit 1
fi

mount "/dev/mapper/$volume_name" $mountpoint
if [ $? != 0 ]; then
    echo "There was a problem mounting the volume /dev/mapper/%s at %s.\n" $volume_name $mountpoint
    exit 1
fi

echo "Mounted $volume_name at mount point $mountpoint"
