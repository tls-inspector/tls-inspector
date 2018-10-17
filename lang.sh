#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <strings plist file>"
    exit 1
fi

plutil -convert binary1 "$1" && plutil -convert xml1 "$1"
gsed -ie "4,\$s/'/\&apos;/g" "$1"
gsed -ie "4,\$s/\"/\&quot;/g" "$1"
rm -f "$1"e
