#!/bin/bash
set -e

for FILE in *.plist; do
    plutil -convert binary1 en.plist && plutil -convert xml1 $FILE
    sed -i '' "s/'/\&apos;/g" $FILE
done
