#!/bin/sh

# This is meant to be used by copy_photos.sh
# We don't really do many sanity checks here.
# usage: copy_photo.sh source_filename target_dirname
#
# We assume that target_dirname/.checksums is an index of checksums in target_dirname

source_filename=$1
target_dirname=$2

checksum=`sha256sum "$source_filename" | cut -f1 -d" "`
checksums_index="$target_dirname/.checksums"

if grep "$checksum" "$checksums_index"; then
    exit 0
fi

target_basename=`basename "$source_filename"`

while [ -f "$target_dirname/$target_basename" ]; do
    target_basename="$RANDOM_$target_basename"
done;

target_filename="$target_dirname/$target_basename"
cp -p "$source_filename" "$target_filename"

target_checksum=`sha256sum "$target_filename" | cut -f1 -d" "`

# Need a way to get the PD_HOME out of here
if [ "$checksum" != "$target_checksum" ]; then
    echo "checksum mismatch! source='$checksum $source_filename', target='$target_checksum $target_basename'" >> /opt/photo_device/run/error;
    exit 1
fi

echo "$target_checksum $target_basename" >> "$checksums_index"

