# Contributing to TLS Inspector

This document describes the guidelines for contributing to TLS Inspector. Items with the words **MUST** or **MUST NOT** are hard-requirements.

## Development Strategy

TLS Inspector follows a typical semantic version system of major, minor, and patch releases. Major releases are reserved for significant user-facing changes, minor releases may be used for signiciant non-user-facing changes, and patch releases are reserved for bugfixes that do not impact the behaviour of the application. Only project administrators can publish a new release of the app.

### Branching

The main branch of the app is the `app-store` branch.

Minor and patch releases can be developed and cut directly from the `app-store` branch, however major releases must be developed in a dedicated branch to ensure that minor and patch releases can occur during development, if needed.

All new releases MUST have an associated git tag.

### Critial Path

Throughout the rest of this document you will see mentions of a "critical path", this defines the most important functionality of the app and where the most attetion and care must be spent.

The critical path of TLS Inspector includes the following:
- Inspection Parameters & Request
- Name resolution
- TLS connections
- Certificate parsing
- Certificate status checks (CRL & OCSP)
- TLS connection trust verification

### Code Style

- Swift code MUST adhere to the project's defined style, enforced by the SwiftLint tool.
- Objective-C code should follow a similar style to existing code, however no defined style or enforcement tool exists at this time.
- Public methods, properties, and types within CertificateKit MUST be documented.

### Testing

- Any changes or new functionality to the critical path of the app MUST be covered by an automated test

### Security

These rules are **in additon** to the security policy of the app.

- No new code should be written in pure C unless deemed strictly nessecary. Objective-C should be used over pure C if possible.
- All C code MUST be included in automated tests, including fuzzing tests

### Privacy

These rules are **in addition** to the privacy policy of the app.**

- With the exception of certificate status checks, the app MUST NOT contact any third-party without the explicit action and consent of the user
- User-provided data, including the inspection target, MUST NOT appear in error logs. Such data can appear in debug logs, which are disabled by default.

## Conduct

All contributors of the TLS Inspector project must follow our [Code of Conduct](https://github.com/tls-inspector/tls-inspector/blob/app-store/.github/CODE_OF_CONDUCT.md). These rules apply to **every member**, including project leaders.
