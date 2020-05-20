#!/bin/bash
# date: 2020-04-24
# purpose: config.guess as found in TGZ are outdated,
#          they do not work on uncommon platforms
#          e.g. powerpc64le-unknown-linux-gnu
#          this script will patch config.guess
#          with the 2020-01-01 version

if [ "$#" -ne 2 ]; then
  echo "usage: $0 filename directory"
  exit 1
fi

for file_to_patch in $(find $2 -name "$(basename $1)"); do
  cp $1 $file_to_patch
  chmod 555 $file_to_patch
done
