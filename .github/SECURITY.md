# Security Policy

TLS Inspector is a security focused application that is designed to enhance your privacy
while browsing the web on your mobile device. This document describes our policy for handling
security vulnerabilities within the TLS Inspector software.

This policy does not apply to any websites, including the TLS Inspector website. To report
an issue with the TLS Inspector website, contact [Ian Spence](https://ianspence.com/).

## Supported Versions

We only provide support for the most recent version of TLS Inspector that is released in the Apple
App Store. Older versions are not supported and may contain unfixed security vulnerabilities.

We provide limited support to pre-release "Test Flight" versions of the app. These versions may
contain security vulnerabilities and use of pre-release software is at your own risk.

## Upstream Vulnerabilities

TLS Inspector relies on open source third-party software packages, most notably OpenSSL and cURL.

We require that software packages that are extensively used through the app to have an existing
security policy.

### OpenSSL

When a vulnerability for OpenSSL is announced, we must determine the impact of the issue on
TLS Inspector.

TLS Inspector does not implement all features of OpenSSL and therefor might not be impacted by a
vulnerability.

### cURL

When a vulnerability for cURL is announced, we must determine the impact of the issue on
TLS Inspector.

TLS Inspector does not implement all features of cURL and therefor might not be impacted by a
vulnerability.

## Reporting a Vulnerability

Please do not report security vulnerabilities as issues on Github as these are visible to the
public.
Depending on the severity of the issue, which may be larger than you think, we ask that we keep
reports private until we can determine the scope of the issue.

Instructions on how to report vulnerabilities to us are provided on our website:
https://tlsinspector.com/vulnerability.html

We prefer that you use the Google Form or Signal to report issues instead of regular email.
We do not provide a PGP public key and do not support responding to PGP encrypted emails.

# Q & A

**Do you offer any form of reward for identifying security issues?**
We do not run a bug bounty program and do not offer monetary rewards. TLS Inspector is an open
source project with absolutely no budget. All expenses for the project are donated. We will provide
credit to you (of a name of your choice and single link to a social media profile) in release notes
for discovered issues.

**I've found a vulnerable website, where do I report it?**
The website, not to us. We can't fix other peoples websites.
