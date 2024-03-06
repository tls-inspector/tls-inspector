#!/bin/sh

function show_help {
    echo "One of: -M (major), -m (minor), -p (patch), or -b (build)"
}

MODE="major"
while getopts "h?Mmpb" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    M)  MODE="major"
      ;;
    m)  MODE="minor"
      ;;
    p)  MODE="patch"
      ;;
    b)  MODE="build"
      ;;
  esac
done

CURRENT_VERSION=$(egrep -o 'MARKETING_VERSION = [0-9\.]+' "tls-inspector.xcodeproj/project.pbxproj" | tail -n1 | cut -d '=' -f2 | xargs)
CURRENT_MAJOR=$(echo $CURRENT_VERSION | cut -d '.' -f1)
CURRENT_MINOR=$(echo $CURRENT_VERSION | cut -d '.' -f2)
CURRENT_PATCH=$(echo $CURRENT_VERSION | cut -d '.' -f3)
NEW_MAJOR=$CURRENT_MAJOR
NEW_MINOR=$CURRENT_MINOR
NEW_PATCH=$CURRENT_PATCH

if [[ $MODE == "major" ]]; then
    NEW_MAJOR=$(expr ${CURRENT_MAJOR} + 1)
    NEW_MINOR="0"
    NEW_PATCH="0"
elif [[ $MODE == "minor" ]]; then
    NEW_MINOR=$(expr ${CURRENT_MINOR} + 1)
    NEW_PATCH="0"
elif [[ $MODE == "patch" ]]; then
    NEW_PATCH=$(expr ${CURRENT_PATCH} + 1)
fi
NEW_VERSION="${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"

CURRENT_BUILD=$(egrep -o 'CURRENT_PROJECT_VERSION = [0-9\.]+' "tls-inspector.xcodeproj/project.pbxproj" | tail -n1 | cut -d '=' -f2 | xargs)
NEW_BUILD=$(expr ${CURRENT_BUILD} + 1)

perl -pi -e "s,MARKETING_VERSION = ${CURRENT_VERSION},MARKETING_VERSION = ${NEW_VERSION},g" "tls-inspector.xcodeproj/project.pbxproj"
perl -pi -e "s,CURRENT_PROJECT_VERSION = ${CURRENT_BUILD},CURRENT_PROJECT_VERSION = ${NEW_BUILD},g" "tls-inspector.xcodeproj/project.pbxproj"
