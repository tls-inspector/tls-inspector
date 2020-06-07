# Building TLS Inspector

This document will describe the process for building TLS Inspector.

# Requirements

- A computer running macOS Catalina (10.15.2 or later)
- Xcode 11.4.1 or later
- Git (1.8 or later)
- An Apple Developer Membership (only required for distribution)

*Note: while it may be possible to build the project on a virtual machine or "hackintosh", it is untested
and not supported. Furthermore, it may violate the Apple Developer rules to submit apps from unauthorized copies
of macOS.*

# Configuring the Project

By default the project is configured to use the Development team and codesigning certificate for [Ian Spence](https://github.com/ecnepsnai).

Unless you're Ian Spence, you will need to change this to your own team and codesigning certificate (if applicable) to
deploy the app to a physical iOS device.

This requires that you have an Apple Developer Membership, which can be purchased here: https://developer.apple.com/programs/

# Building the Project

TLS Inspector requires OpenSSL and cURL, both of which will be compiled the first time you build the project in Xcode.

**The first time you build the project in Xcode it will take a while (5-15 minutes).**

You can change the version of OpenSSL or cURL used by altering the associated `.want` file in `CertificateKit/build/`