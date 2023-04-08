#!/bin/sh
set -e

curl -Ss https://www.gstatic.com/ct/log_list/v3/all_logs_list.json > ct_log_list.json
curl -Ss https://www.gstatic.com/ct/log_list/v3/all_logs_list.sig > ct_log_list.json.sig
openssl dgst -sha256 -verify ct_log_list_pubkey.pem -signature ct_log_list.json.sig ct_log_list.json > /dev/null
cat ct_log_list.json | jq -r tostring > ct_log_list.min.json
