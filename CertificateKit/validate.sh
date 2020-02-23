#!/bin/bash

cd openssl.framework/
if ! grep "$(shasum -a 512 openssl)" CHECKSUM >/dev/null; then
    >&2 echo "Checksum for OpenSSL did not match"
    exit 1
fi
cd ../

cd curl.framework/
if ! grep "$(shasum -a 512 curl)" CHECKSUM >/dev/null; then
    >&2 echo "Checksum for curl did not match"
    exit 1
fi
cd ../
