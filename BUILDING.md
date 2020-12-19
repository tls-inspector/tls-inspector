# Building TLS Inspector

This document will describe the process for building TLS Inspector.

# Requirements

- The latest release of Xcode
- Git (1.8 or later)
- An Apple Developer Membership (only required for distribution or installing on physical devices)
- Swiftlint

*Note: while it may be possible to build the project on a virtual machine or "hackintosh", it is untested
and not supported. Furthermore, it may violate the Apple Developer rules to submit apps from unauthorized copies
of macOS.*

# Downloading the Source Code

TLS Inspector makes use of two git submodules that are required to build the project.

When cloning the source code, you need to tell git to also initialize these submodules.

If you are using git 2.13 or later, use:

```bash
git clone --recurse-submodules https://github.com/tls-inspector/tls-inspector.git
```

For older versions of git, use:

```bash
git clone --recursive https://github.com/tls-inspector/tls-inspector.git
```

# Configuring the Project

By default the project is configured to use the Development team and codesigning certificate for [Ian Spence](https://github.com/ecnepsnai).

Unless you're Ian Spence, you will need to change this to your own team and codesigning certificate (if applicable) to
deploy the app to a physical iOS device.

This requires that you have an Apple Developer Membership, which can be purchased here: https://developer.apple.com/programs/

# Building the Project

TLS Inspector requires OpenSSL and tiny-curl, both of which will be compiled the first time you build the project in Xcode.

**The first time you build the project in Xcode it will take a while (5-15 minutes depending on hardware).**

You can change the version of OpenSSL or tiny-curl used by altering the associated `.want` file in `CertificateKit/build/`
