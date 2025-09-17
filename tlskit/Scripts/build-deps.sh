#!/bin/sh
set -e
set -x

BUILD_PWD=$(pwd)
BUILD_CURL_PATH="${1}"
BUILD_CURL_PATH=$(realpath "${BUILD_CURL_PATH}")
BUILD_CURL_VERSION="${2}"
BUILD_OPENSSL_PATH="${3}"
BUILD_OPENSSL_PATH=$(realpath "${BUILD_OPENSSL_PATH}")
BUILD_OPENSSL_VERSION="${4}"

# Build OpenSSL
if [[ -d "${BUILD_PWD}/openssl.xcframework" ]]; then
    rm -rf "${BUILD_PWD}/openssl.xcframework"
fi
cd "${BUILD_OPENSSL_PATH}"
./build-ios.sh -o "${BUILD_OPENSSL_VERSION}" -vsg -- -no-apps -no-argon2 -no-blake2 -no-camellia -no-deprecated -no-md4 -no-hw -no-engine
cp -fv "${BUILD_OPENSSL_PATH}/openssl.tar.xz" "${BUILD_CURL_PATH}/openssl-${BUILD_OPENSSL_VERSION}.tar.xz"
mv -v "${BUILD_OPENSSL_PATH}/openssl.xcframework" "${BUILD_PWD}/openssl.xcframework"
cd "${BUILD_PWD}"

# Build curl
if [[ -d "${BUILD_PWD}/curl.xcframework" ]]; then
    rm -rf "${BUILD_PWD}/curl.xcframework"
fi
cd "${BUILD_CURL_PATH}"
./build-ios.sh -c "${BUILD_CURL_VERSION}" -o "${BUILD_OPENSSL_VERSION}" -vsg -- --disable-docs --disable-ntlm --disable-unixsockets --disable-dict --disable-file --disable-ftp --disable-ftps --disable-gopher --disable-gophers --disable-imap --disable-imaps --disable-ipfs --disable-ipns --disable-mqtt --disable-pop3 --disable-pop3s --disable-rtsp --disable-smb --disable-smbs --disable-smtp --disable-smtps --disable-telnet --disable-tftp --disable-ws --disable-wss
mv -fv "${BUILD_CURL_PATH}/curl.xcframework" "${BUILD_PWD}/curl.xcframework"
cd "${BUILD_PWD}"
