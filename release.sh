#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage: $0 <ota zip>"
    exit 1
fi

ROM="$1"

METADATA=$(unzip -p "$ROM" META-INF/com/android/metadata)
SDK_LEVEL=$(echo "$METADATA" | grep post-sdk-level | cut -f2 -d '=')
TIMESTAMP=$(echo "$METADATA" | grep post-timestamp | cut -f2 -d '=')

OEM="xiaomi"
MAINTAINER="Aeoniixx"
FILENAME=$(basename $ROM)
SIZE=$(du -b $ROM | cut -f1 -d '	')
VERSION=$(echo $FILENAME | cut -f2 -d '-')
ROMTYPE=$(echo $FILENAME | cut -f6 -d '-')
DEVICE=$(echo $FILENAME | cut -f5 -d '-')

MD5SUM=$(md5sum $ROM | cut -f1 -d " ")
SHA256SUM=$(echo ${TIMESTAMP}${DEVICE}${SDK_LEVEL} | sha256sum | cut -f 1 -d ' ')

URL="https://sourceforge.net/projects/aeoniixx-lavender/files/releases/${FILENAME}/download"

response=$(jq -n --arg maintainer $MAINTAINER \
        --arg oem $OEM \
        --arg device $DEVICE\
        --arg version $VERSION \
        --arg romtype $ROMTYPE \
        --arg filename $FILENAME \
        --arg download $URL \
        --arg timestamp $TIMESTAMP \
        --arg md5 $MD5SUM \
        --arg sha256 $SHA256SUM \
        --argjson size $SIZE \
        '$ARGS.named'
)
wrapped_response=$(jq -n --argjson response "[$response]" '$ARGS.named')

echo "$wrapped_response" > $DEVICE.json
git add $DEVICE.json
git commit -m "lavender.json: autogenerated json for PixelStar $VERSION update"

git add changelog.txt
git commit -m "changelog.txt: PixelStar $VERSION update"

git push