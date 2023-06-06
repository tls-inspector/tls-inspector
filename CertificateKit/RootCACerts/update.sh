#!/bin/sh

LATEST_BUNDLE_TAG=$(curl -Ss https://api.github.com/repos/tls-inspector/rootca/releases/latest | egrep -o 'bundle_[0-9]+' | head -n1)
NEEDS_UPDATE=0

if [ -f bundle_version.txt ]; then
    CURRENT_VERSION=$(cat bundle_version.txt)
    if [ "$CURRENT_VERSION" != "$LATEST_BUNDLE_TAG" ]; then
        NEEDS_UPDATE=1
    fi
else
    NEEDS_UPDATE=1
fi

if [ -f apple_ca_bundle.p7b ]; then
    if [ -f apple_ca_bundle.p7b.sig ]; then
        if ! openssl dgst -sha256 -verify signing_key.pem -signature apple_ca_bundle.p7b.sig apple_ca_bundle.p7b > /dev/null 2>&1; then
            echo "warning: apple_ca_bundle.p7b signature verification failed"
            NEEDS_UPDATE=1
        fi
    fi
else
    NEEDS_UPDATE=1
fi

if [ -f google_ca_bundle.p7b ]; then
    if [ -f google_ca_bundle.p7b.sig ]; then
        if ! openssl dgst -sha256 -verify signing_key.pem -signature google_ca_bundle.p7b.sig google_ca_bundle.p7b > /dev/null 2>&1; then
            echo "warning: google_ca_bundle.p7b signature verification failed"
            NEEDS_UPDATE=1
        fi
    fi
else
    NEEDS_UPDATE=1
fi

if [ -f microsoft_ca_bundle.p7b ]; then
    if [ -f microsoft_ca_bundle.p7b.sig ]; then
        if ! openssl dgst -sha256 -verify signing_key.pem -signature microsoft_ca_bundle.p7b.sig microsoft_ca_bundle.p7b > /dev/null 2>&1; then
            echo "warning: microsoft_ca_bundle.p7b signature verification failed"
            NEEDS_UPDATE=1
        fi
    fi
else
    NEEDS_UPDATE=1
fi

if [ -f mozilla_ca_bundle.p7b ]; then
    if [ -f mozilla_ca_bundle.p7b.sig ]; then
        if ! openssl dgst -sha256 -verify signing_key.pem -signature mozilla_ca_bundle.p7b.sig mozilla_ca_bundle.p7b > /dev/null 2>&1; then
            echo "warning: mozilla_ca_bundle.p7b signature verification failed"
            NEEDS_UPDATE=1
        fi
    fi
else
    NEEDS_UPDATE=1
fi

if [ -f bundle_metadata.json ]; then
    if [ -f bundle_metadata.json.sig ]; then
        if ! openssl dgst -sha256 -verify signing_key.pem -signature bundle_metadata.json.sig bundle_metadata.json > /dev/null 2>&1; then
            echo "warning: bundle_metadata.json signature verification failed"
            NEEDS_UPDATE=1
        fi
    fi
else
    NEEDS_UPDATE=1
fi

if [ $NEEDS_UPDATE == 0 ]; then
    echo "Root CA Certificate Bundles up-to-date"
    exit 0
fi

echo "warning: Root CA Certificate Bundles need to be updated"

function download_github_asset() {
    ASSET_NAME=${1}

    rm -f ${ASSET_NAME}
    curl -SsL https://github.com/tls-inspector/rootca/releases/download/${LATEST_BUNDLE_TAG}/${ASSET_NAME} > ${ASSET_NAME}
    rm -f ${ASSET_NAME}.sig
    curl -SsL https://github.com/tls-inspector/rootca/releases/download/${LATEST_BUNDLE_TAG}/${ASSET_NAME}.sig > ${ASSET_NAME}.sig
}

download_github_asset apple_ca_bundle.p7b
download_github_asset google_ca_bundle.p7b
download_github_asset microsoft_ca_bundle.p7b
download_github_asset mozilla_ca_bundle.p7b
download_github_asset bundle_metadata.json
echo "${LATEST_BUNDLE_TAG}" > bundle_version.txt
