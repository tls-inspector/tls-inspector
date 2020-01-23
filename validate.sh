#!/bin/zsh

HAS_MISSING_KEY=0
function check_lang() {
	FILE=$1
	KEY=$2

	grep "${KEY}" 'TLS Inspector/Localization/Strings/en.plist' >/dev/null
	if [ $? != 0 ]; then
		HAS_MISSING_KEY=1
		echo $FILE:$KEY
	fi
}

LANG_CALLS=$(egrep -o 'lang\(key: "[^"]+"' **/*.swift)
LAST_FILE=""
while IFS= read -r STRING; do
	if [[ $STRING == lang* ]]; then
		STRING=$LAST_FILE:$STRING
	fi

	FILE=$(cut -d ':' -f 1 <<< "$STRING")
	LAST_FILE=$FILE
	LANG=$(cut -d ':' -f 2- <<< "$STRING")
	LANG=$(echo "${LANG}" | sed 's/lang(key: "//g')
	LANG=$(echo "${LANG}" | sed 's/&/&amp;/g')
	LANG=${LANG:0:-1}
	check_lang "${FILE}" "${LANG}"
done <<< "$LANG_CALLS"

STORYBOARD_ATTRIBUTES=$(egrep 'userDefinedRuntimeAttribute type="string"' **/*.storyboard)
while IFS= read -r STRING; do
	FILE=$(cut -d ':' -f 1 <<< "$STRING")
	LANG=$(cut -d ':' -f 2- <<< "$STRING")
	LANG=$(echo "${LANG}" | egrep -o 'value=".+"')
	LANG=$(echo "${LANG}" | sed 's/value="//g')
	LANG=${LANG:0:-1}
	check_lang "${FILE}" "${LANG}"
done <<< "$STORYBOARD_ATTRIBUTES"

if [[ $HAS_MISSING_KEY == 1 ]]; then
	exit 1
fi
