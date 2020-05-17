#!/bin/bash
set -e

# Because we run this script from a Xcode build phase, it adds a million and one of it's own
# environment variables, which mess with compiling the library. To get around this, we run
# this script without any variables (env -i <script>), but need to provide a default PATH
# so that coreutils will still work
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin

OPENSSL_WANT_VERSION=$(grep 'VERSION' openssl.want | cut -d '=' -f 2)

echo "OpenSSL version wanted: ${OPENSSL_WANT_VERSION}"

if [ -f ../openssl.framework/Headers/opensslv.h ]; then
    CURRENT_VERSION=$(grep 'OPENSSL_FULL_VERSION_STR' ../openssl.framework/Headers/opensslv.h | egrep -o '"[a-zA-Z0-9\.\-]+"' | tr -d '"')
    if [ "${CURRENT_VERSION}" == "${OPENSSL_WANT_VERSION}" ]; then
        echo "OpenSSL already built, nothing to do"
        exit 0
    else
        echo "warning: OpenSSL version did not match. recompiling version ${OPENSSL_WANT_VERSION}"
        rm -r ../openssl.framework
    fi
else
    echo "warning: OpenSSL needs to be compiled. This will take a while..."
fi

cd openssl-ios
rm -rf build/ output/
./build-openssl.sh ${OPENSSL_WANT_VERSION}
mv openssl.framework ../../
cd ../

if [ -f ../openssl.framework/Headers/opensslv.h ]; then
    CURRENT_VERSION=$(grep 'OPENSSL_FULL_VERSION_STR' ../openssl.framework/Headers/opensslv.h | egrep -o '"[a-zA-Z0-9\.\-]+"' | tr -d '"')
    if [ "${CURRENT_VERSION}" == "${OPENSSL_WANT_VERSION}" ]; then
        exit 0
    fi
fi

echo "error: OpenSSL version did not match after building version ${OPENSSL_WANT_VERSION}"
exit 1
