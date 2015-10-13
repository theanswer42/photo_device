#!/bin/sh

PD_HOME=/opt/photo_device
LOCK_FILE="$PD_HOME/run/copy_photos.lock"
mkdir -p "$PD_HOME/run"

# TODO: error exits

get_lock()
{
    if [ -f "$LOCK_FILE" ]; then
	lock=`cat $LOCK_FILE"`
	echo "Locked at $LOCK. Something else running?"
	return 1
    fi
    date > "$lock_file"
}

check_errors()
{
    if [ -f "$PD_HOME/run/error" ]; then
	echo "Something has gone wrong"
	return 1
    fi
}

message_exit()
{
    message=$1
    status=$2
    
    echo "$message"

    if [ -f "$LOCK_FILE" ]; then
	rm "$LOCK_FILE"
    fi
    exit $status
}

if ! check_errors; then
    exit 1
fi

if ! get_lock; then
    exit 1
fi

target="$PD_HOME/run/target"

if [ ! -f "$target" ]; then
    message_exit "no target location available" 0
fi

target_device=`cat "$target"`

if [ -z "$target_device" ]; then
    rm "$target"
    message_exit "no target location available" 0
fi

if [ ! -b "$target_device" ]; then
    message_exit "target location is not a block device? $target_device" 1
fi

echo "target location found: $target_device"

cards="$PD_HOME/run/target"

if [ ! -f "$cards" ]; then
    message_exit "no cards available" 0
fi

card=`cat "$cards" | head -1`

if [ -z "$card" ]; then
    message_exit "no card available" 0
fi

if [ ! -b "$card" ]; then
    message_exit "card is not a block device? $card" 1
fi

echo "source location found: $card"

mkdir -p "$source_mount"
mkdir -p "$target_mount"

source_mount=/mnt/copy_photos/card
target_mount=/mnt/copy_photos/disk

if ! mount "$card" "$source_mount"; then
    message_exit "could not mount $card $source_mount" 1
fi

if ! mount "$target_device" "$target_mount"; then
    umount "$source_mount"
    message_exit "could not mount $target_device $target_mount" 1
fi

if ! touch $target_mount/photo_backup_test; then
    umount "$source_mount"
    umount "$target_mount"
    message_exit "not enough permissions to write to $target_mount" 1
fi

# Finally, we're ready to start copying
target_location="$target_mount/photo_backup"
mkdir -p "$target_location"

checksums="$target_location/.checksums"
touch "$checksums"

echo "copying..."

find "$source_mount" \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.nef' -o -iname '*.mp4' \) \
     -exec "$PD_HOME/bin/copy_photo.sh" '{}' "$target_location" \;

sync
umount $source_mount
umount $target_mount

sleep 5

if ! check_errors; then
    message_exit "Done. There were errors" 1
else
    message_exit "Done!"
fi
