#!/bin/bash
set -e

CURL_WANT_VERSION=$(grep 'VERSION' curl.want | cut -d '=' -f 2)
CURL_WANT_HASH=$(grep 'HASH' curl.want | cut -d '=' -f 2)

echo "cURL version wanted: ${CURL_WANT_VERSION}"
echo "cURL hash wanted: ${CURL_WANT_HASH}"

if [ -f ../curl.framework/curl ]; then
    CURRENT_HASH=$(shasum -a 512 ../curl.framework/curl | cut -d ' ' -f 1)
    if [ "${CURRENT_HASH}" == "${CURL_WANT_HASH}" ]; then
        echo "cURL already built, nothing to do"
        exit 0
    else
        echo "warning: cURL hash did not match. recompiling version ${CURL_WANT_VERSION}"
        rm -r ../curl.framework
    fi
fi

cd libcurl-ios
./build-curl.sh ${CURL_WANT_VERSION}
cd ../
mv curl.framework ../

if [ -f ../curl.framework/curl ]; then
    if [ "${CURRENT_HASH}" == "${CURL_WANT_HASH}" ]; then
        exit 0
    fi
fi

echo "error: cURL hash did not match after building version ${CURL_WANT_VERSION}"
exit 1
