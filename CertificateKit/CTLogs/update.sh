#!/bin/sh
set -e

LATEST_LIST_VERSION=$(curl -Ss https://www.gstatic.com/ct/log_list/v3/all_logs_list.json | jq -r '.version')
NEEDS_UPDATE=0

if [ -f ct_log_list.min.json ]; then
    CURRENT_LIST_VERSION=$(cat ct_log_list.min.json | jq -r '.version')
    if [ $CURRENT_LIST_VERSION != $LATEST_LIST_VERSION ]; then
        NEEDS_UPDATE=1
    fi
else
    NEEDS_UPDATE=1
fi

if [ $NEEDS_UPDATE == 0 ]; then
    echo "Certificate Transparency lists up-to-date"
    exit 0
fi

echo "warning: Certificate Transparency lists need to be updated"

curl -Ss https://www.gstatic.com/ct/log_list/v3/all_logs_list.json > ct_log_list.json
curl -Ss https://www.gstatic.com/ct/log_list/v3/all_logs_list.sig > ct_log_list.json.sig
openssl dgst -sha256 -verify ct_log_list_pubkey.pem -signature ct_log_list.json.sig ct_log_list.json > /dev/null
cat ct_log_list.json | jq -r tostring > ct_log_list.min.json
rm -f ct_log_list.json ct_log_list.json.sig
echo "${LATEST_LIST_VERSION}" > ct_log_version.txt
