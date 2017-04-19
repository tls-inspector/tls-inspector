#!/bin/bash
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null


info_plists=("${SCRIPTPATH}/TLS Inspector/Info.plist" "${SCRIPTPATH}/Inspect Website/Info.plist")
for ((i = 0; i < ${#info_plists[@]}; i++)); do
    info_plist=${info_plists[i]}

    current_build_number=$(defaults read "${info_plist}" CFBundleVersion)
    new_build_number=$(($current_build_number + 1))
    echo "Build number: '$current_build_number' -> '$new_build_number'."
    defaults write "${info_plist}" CFBundleVersion $new_build_number
    plutil -convert xml1 "${info_plist}"
done
