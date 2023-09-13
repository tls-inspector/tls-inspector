#!/bin/bash
set -e

# Because we run this script from a Xcode build phase, it adds a million and one of it's own
# environment variables, which mess with compiling the library. To get around this, we run
# this script without any variables (env -i <script>), but need to provide a default PATH
# so that coreutils will still work
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/opt/homebrew/bin

OPENSSL_WANT_VERSION=$(grep 'VERSION' openssl.want | cut -d '=' -f 2)

echo "OpenSSL version wanted: ${OPENSSL_WANT_VERSION}"

if [ -f ../openssl.xcframework/Info.plist ]; then
    CURRENT_VERSION=$(plutil -extract CFBundleVersion raw -o - ../openssl.xcframework/Info.plist)
    if [ "${CURRENT_VERSION}" == "${OPENSSL_WANT_VERSION}" ]; then
        echo "OpenSSL already built, nothing to do"
        exit 0
    else
        echo "warning: OpenSSL version did not match. recompiling version ${OPENSSL_WANT_VERSION}"
        rm -r ../openssl.xcframework
    fi
fi

echo "warning: OpenSSL needs to be compiled. This will take a while..."

cd openssl-ios
GPG_VERIFY=1 ./build-ios.sh ${OPENSSL_WANT_VERSION} -no-psk -no-srp
mv openssl.xcframework ../../
cd ../

if [ -f ../openssl.xcframework/Info.plist ]; then
    CURRENT_VERSION=$(plutil -extract CFBundleVersion raw -o - ../openssl.xcframework/Info.plist)
    if [ "${CURRENT_VERSION}" == "${OPENSSL_WANT_VERSION}" ]; then
        exit 0
    fi
fi

echo "error: OpenSSL version did not match after building. Wanted: ${OPENSSL_WANT_VERSION} Got: ${CURRENT_VERSION}"
