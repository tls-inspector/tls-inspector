#!/bin/bash
set -e

# Because we run this script from a Xcode build phase, it adds a million and one of it's own
# environment variables, which mess with compiling the library. To get around this, we run
# this script without any variables (env -i <script>), but need to provide a default PATH
# so that coreutils will still work
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin

CURL_WANT_VERSION=$(grep 'VERSION' curl.want | cut -d '=' -f 2)

echo "cURL version wanted: ${CURL_WANT_VERSION}"

if [ -f ../curl.framework/Headers/curlver.h ]; then
    CURRENT_VERSION=$(grep 'LIBCURL_VERSION' ../curl.framework/Headers/curlver.h | egrep -o '"[a-zA-Z0-9\.\-]+"' | tr -d '"')
    if [ "${CURRENT_VERSION}" == "${CURL_WANT_VERSION}" ]; then
        echo "cURL already built, nothing to do"
        exit 0
    else
        echo "warning: cURL version did not match. recompiling version ${CURL_WANT_VERSION}"
        rm -r ../curl.framework
    fi
fi

echo "warning: cURL needs to be compiled. This will take a while..."

cd curl-ios
./build-ios.sh ${CURL_WANT_VERSION}
mv curl.framework ../../
cd ../

if [ -f ../curl.framework/Headers/curlver.h ]; then
    CURRENT_VERSION=$(grep 'LIBCURL_VERSION' ../curl.framework/Headers/curlver.h | egrep -o '"[a-zA-Z0-9\.\-]+"' | tr -d '"')
    if [ "${CURRENT_VERSION}" == "${CURL_WANT_VERSION}" ]; then
        exit 0
    fi
fi

echo "error: cURL version did not match after building version ${CURL_WANT_VERSION}"
exit 1
