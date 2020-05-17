#!/bin/bash
set -e

OPENSSL_WANT_VERSION=$(grep 'VERSION' openssl.want | cut -d '=' -f 2)
OPENSSL_WANT_HASH=$(grep 'HASH' openssl.want | cut -d '=' -f 2)

echo "OpenSSL version wanted: ${OPENSSL_WANT_VERSION}"
echo "OpenSSL hash wanted: ${OPENSSL_WANT_HASH}"

if [ -f ../openssl.framework/openssl ]; then
    CURRENT_HASH=$(shasum -a 512 ../openssl.framework/openssl | cut -d ' ' -f 1)
    if [ "${CURRENT_HASH}" == "${OPENSSL_WANT_HASH}" ]; then
        echo "OpenSSL already built, nothing to do"
        exit 0
    else
        echo "warning: OpenSSL hash did not match. recompiling version ${OPENSSL_WANT_VERSION}"
        rm -r ../openssl.framework
    fi
fi

cd openssl-ios
./build-openssl.sh ${OPENSSL_WANT_VERSION}
cd ../
mv openssl.framework ../

if [ -f ../openssl.framework/openssl ]; then
    if [ "${CURRENT_HASH}" == "${OPENSSL_WANT_HASH}" ]; then
        exit 0
    fi
fi

echo "error: OpenSSL hash did not match after building version ${OPENSSL_WANT_VERSION}"
exit 1
