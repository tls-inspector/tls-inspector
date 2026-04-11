# Building TLS Inspector

This document will describe the process for building TLS Inspector.

# Requirements

- The latest release of Xcode
- An Apple Developer Membership (only required for distribution or installing on physical devices)

> [!NOTE]
> While it may be _possible_ to build the project on a virtual machine or "hackintosh", it is untested
and not _supported_. Furthermore, it may violate the Apple Developer rules to submit apps from unauthorized copies
of macOS.

# External Dependencies

## Certificate Transparancy Logs

The app depends on, but does not include in its source code, lists of certificate transparancy logs. This list is provided by Google on Github.

The first time you check out the app, or to update the list, run:

```bash
cd tlskit/Scripts
./update-ctlogs.sh ../Sources/TLSKit/External/CT-Logs
```

## Root CA Certificate Bundles

The app depends on, but does not include in its source code, collections of root CA certificates.

The first time you check out the app, or to update the list, run:

```bash
cd tlskit/Scripts
./update-rootca-bundles.sh ../Sources/TLSKit/External/Anchors
```

## Curl & OpenSSL

The first time you open the TLS Inspector project, Xcode will download the required libraries from our [dedicated repo](https://github.com/tls-inspector/tlskit-external-dependencies). Refer to that repo for build instructions.

# Configuring the Project

By default the project is configured to use the Development team and codesigning certificate for [Ian Spence](https://github.com/ecnepsnai).

Unless you're Ian Spence, you will need to change this to your own team and codesigning certificate (if applicable) to
deploy the app to a physical iOS device.

This requires that you have an Apple Developer Membership, which can be purchased here: https://developer.apple.com/programs/
