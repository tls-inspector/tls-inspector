# TLS Inspector

[![Follow us on Mastodon](https://img.shields.io/mastodon/follow/109742126529751070?domain=https%3A%2F%2Finfosec.exchange&logo=mastodon&logoColor=white&style=flat)](https://infosec.exchange/@tlsinspector)
[![Follow us on Bluesky](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fpublic.api.bsky.app%2Fxrpc%2Fapp.bsky.actor.getProfile%2F%3Factor%3Dtlsinspector.com&query=%24.followersCount&style=social&logo=bluesky&style=flat&label=Follow%20%40tlsinspector.com)](https://bsky.app/profile/tlsinspector.com)
[![Download](https://img.shields.io/itunes/v/1100539810.svg?label=iTunes%20App%20Store&logo=apple&style=flat)](https://tlsinspector.com/download.html)
[![LICENSE](https://img.shields.io/github/license/tls-inspector/tls-inspector.svg?logo=gnu&style=flat)](https://github.com/ecnepsnai/ds/blob/app-store/LICENSE)
[![OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/projects/6942/badge)](https://bestpractices.coreinfrastructure.org/projects/6942)

TLS Inspector is a free & open-source iOS app that enables you to inspect, analyze, and troubleshoot TLS connections.  
**[Learn More about TLS Inspector »](https://tlsinspector.com/)**

<img src="https://github.com/tls-inspector/tls-inspector/blob/app-store/.github/screenshots.png" alt="TLS Inspector Screenshots" />

## Project Structure

This is the Git repository for the TLS Inspector application. The code of the app and its associated extension are structured into subdirectories:

- `tls-inspector/` - This directory contains code and user interface that is specific to the app itself, for example the input view, recent inspections, about and option view.
- `inspect-website/` - This directory contains a minimal set of code for the show certificate share extension.
- `tlsui/` - This directory contains nearly all of the user interface and supporting systems for it, as well as all of the localization code and strings. As the user interface for the app is shared between both the app and the extension, a local swift package is used.
- `tlskit/` - This directory contains all of the logic that performs TLS connection and certificate inspection.

This project also depends on [DNSKit](https://github.com/dns-inspector/dnskit), [external pre-compiled copies of libcurl and openssl](https://github.com/tls-inspector/tlskit-external-dependencies), [root CA certificate bundles](https://github.com/tls-inspector/rootca), and [lists of certificate transparancy logs](https://github.com/google/certificate-transparency-community-site/blob/master/docs/google/known-logs.md).

## Building

Please see [BUILDING](https://github.com/tls-inspector/tls-inspector/blob/app-store/BUILDING.md) for information on how to build TLS Inspector yourself.

## Sharing & Licensing

The TLS Inspector application, which includes the front-end application and the share extension are GPLv3 licensed.

Localization strings use the C BY-SA 4.0 Attribution-ShareAlike 4.0 International license. 

The back-end framework, TLSKit, is LGPLv3 licensed.

The name "TLS Inspector" and associated brand imagery such the TLS Inspector logo are copyrighted material and may not be reused without permission.
