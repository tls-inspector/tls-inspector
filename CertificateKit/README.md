# CertificateKit

CertificateKit is a iOS framework designed exclusively for TLS Inspector to fetch
detailed information about the certificates for any TLS server.

Having this as a Framework allows us to write the more complex portions of code
in Objective-C, letting us interface with libraries like OpenSSL, libCURL,
and SecureTransport more easily than if it were done in Swift.

# Requirements

OpenSSL and libCURL are required, both are downloaded and compiled automatically
by Xcode when you build the TLS Inspector project for the first time, or if the
version changes.

## Updating OpenSSL or libCURL

To update the version of OpenSSL or libCURL the library will use, update the
associated .want file in the build directory with the exact version to use.