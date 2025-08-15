#!/bin/zsh
set -e

ANCHORS_DIR=${1:?Must specify path to anchors directory}

cd $ANCHORS_DIR
CURRENT_VERSION=$(cat bundle_version.txt)
LATEST_VERSION=$(curl -A "tls-inspector/tlskit" -Ss https://api.tlsinspector.com/rootca/latest | jq -r .version)

if [[ $CURRENT_VERSION == $LATEST_VERSION ]]; then
    exit 0
fi

echo "Updating root CA bundles to ${LATEST_VERSION}..."

curl -A "tls-inspector/tlskit" -Ss https://api.tlsinspector.com/rootca/metadata/${LATEST_VERSION} > bundle_metadata.json
curl -A "tls-inspector/tlskit" -OSs https://api.tlsinspector.com/rootca/asset/${LATEST_VERSION}/bundle_metadata.json.sig

echo -n "Validating bundle_metadata.json... "
openssl dgst -sha256 -verify signing_key.pem -signature bundle_metadata.json.sig bundle_metadata.json

function download_bundle {
    NAME=$1

    curl -A "tls-inspector/tlskit" -OSs https://api.tlsinspector.com/rootca/asset/${LATEST_VERSION}/${NAME}_ca_bundle.pem
    curl -A "tls-inspector/tlskit" -OSs https://api.tlsinspector.com/rootca/asset/${LATEST_VERSION}/${NAME}_ca_bundle.pem.sig

    echo -n "Validating ${NAME}_ca_bundle.pem... "
    openssl dgst -sha256 -verify signing_key.pem -signature ${NAME}_ca_bundle.pem.sig ${NAME}_ca_bundle.pem
}

download_bundle apple
download_bundle google
download_bundle mozilla
download_bundle microsoft
download_bundle tlsinspector

printf ${LATEST_VERSION} > bundle_version.txt

cat AnchorVersion.swift | sed "s/${CURRENT_VERSION}/${LATEST_VERSION}/g" > AnchorVersion.swift.new
mv AnchorVersion.swift.new AnchorVersion.swift
