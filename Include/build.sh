#!/bin/bash
set -e

OPENSSL_WANTS=$(cat openssl.wants)
CURL_WANTS=$(cat curl.wants)

echo "OpenSSL Version Needed: ${OPENSSL_WANTS}"
echo "CURL Version Needed: ${CURL_WANTS}"

NEED_COMPILE_SOMETHING=0
NEED_BUILD_OPENSSL=1
NEED_BUILD_CURL=1

if [ -f openssl.has ]; then
    OPENSSL_HAS=$(cat openssl.has)
    echo "OpenSSL Version Present: ${OPENSSL_HAS}"
    if [ "${OPENSSL_WANTS}" = "${OPENSSL_HAS}" ]; then
        NEED_BUILD_OPENSSL=0
    fi
fi

if [ -f curl.has ]; then
    CURL_HAS=$(cat curl.has)
    echo "CURL Version Present: ${CURL_HAS}"
    if [ "${CURL_WANTS}" = "${CURL_HAS}" ]; then
        NEED_BUILD_CURL=0
    fi
fi

if [ "${NEED_BUILD_OPENSSL}" = 1 ]; then
    NEED_COMPILE_SOMETHING=1
    echo "warning: OpenSSL needs to be built. Build times will be longer than normal."
fi

if [ "${NEED_BUILD_CURL}" = 1 ]; then
    NEED_COMPILE_SOMETHING=1
    echo "warning: CURL needs to be built. Build times will be longer than normal."
fi

if [ "${NEED_COMPILE_SOMETHING}" = 0 ]; then
    echo "All prerequisites satisfied"
    exit 0
fi

if [ "${NEED_BUILD_OPENSSL}" = 1 ]; then
    cd openssl-ios/
    ./build-openssl.sh ${OPENSSL_WANTS}
    rm -rf ../../CertificateKit/openssl.framework
    mv openssl.framework/ ../../CertificateKit/openssl.framework
    cd ../
    echo "${OPENSSL_WANTS}" > openssl.has
fi

if [ "${NEED_BUILD_CURL}" = 1 ]; then
    cd libcurl-ios/
    ./build-ios.sh ${CURL_WANTS}
    rm -rf ../../CertificateKit/curl.framework
    mv curl.framework/ ../../CertificateKit/curl.framework
    cd ../
    echo "${CURL_WANTS}" > curl.has
fi
