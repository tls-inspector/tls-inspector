// TLS Inspector
// Copyright (C) 2024 Ian Spence
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import TLSKit

public struct CertificateView: View {
    public let certificate: Certificate

    public var body: some View {
        List {
            CertificateSubjectView(subject: certificate.subject, alternateNames: certificate.alternateNames)
            CertificateIssuerView(issuer: certificate.issuer)
            CertificateValidityPeriodView(validityPeriod: certificate.validity)
            if let keyUsage = certificate.keyUsage {
                CertificateKeyUsageView(keyUsage: keyUsage)
            }
            if let extensions = certificate.extensions {
                CertificateExtensionsView(extensions: extensions)
            }
            CertificatePublicKeyView(certificate: certificate)
            CertificateFingerprintView(certificate: certificate)
            if certificate.subjectKeyId != nil || certificate.authorityKeyId != nil {
                CertificateKeyIdentifiersView(certificate: certificate)
            }
            if let statusProviders = certificate.statusProviders {
                CertificateStatusProvidersView(providers: statusProviders)
            }
            CertificateMetadataView(certificate: certificate)
        }
        .navigationTitle(certificate.subject.description)
    }
}
