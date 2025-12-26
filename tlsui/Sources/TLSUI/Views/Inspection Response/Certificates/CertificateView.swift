// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
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
import Localization

public struct CertificateView: View {
    public let certificate: Certificate
    private let sha256Thumbprint: String?
    @State private var exportedCertUrl: URL?

    public init(certificate: Certificate) {
        self.certificate = certificate
        self.sha256Thumbprint = try? certificate.fingerprint(.sha256).hexEncodedString()
    }

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
                CertificateStatusProvidersView(providers: statusProviders, statusResults: certificate.statusResults)
            }
            if let foundInBundles = self.certificate.foundInBundles {
                CertificateBundleTrustView(foundInBundles: foundInBundles)
            }
            CertificateMetadataView(certificate: certificate)
        }
        .sheet(isPresented: .init(get: {
            return self.exportedCertUrl != nil
        }, set: { _ in
            self.exportedCertUrl = nil
        })) {
            if let exportedCertUrl = self.exportedCertUrl {
                ExportSheet(activityItems: [exportedCertUrl])
            } else {
                Text("Huh?")
            }
        }
        .navigationTitle(certificate.subject.description)
        .toolbar {
            ToolbarItem {
                Menu {
                    Button {
                        exportCert()
                    } label: {
                        Label(Localize.exportcertificate(), systemImage: "square.and.arrow.up")
                    }
                    Menu {
                        Button(Localize.numbernot1weeks(number_not_1: "2")) {
                            // TODO
                        }
                        Button(Localize.n1month()) {
                            // TODO
                        }
                        Button(Localize.numbernot1months(number_not_1: "3")) {
                            // TODO
                        }
                        Button(Localize.numbernot1months(number_not_1: "6")) {
                            // TODO
                        }
                    } label: {
                        Label(Localize.addreminderforcertificateexpiry(), systemImage: "calendar")
                    }
                    if let sha256Thumbprint = self.sha256Thumbprint {
                        Link(destination: URL(string: "https://crt.sh/?q=\(sha256Thumbprint)")!) {
                            Label(Localize.showcertificateoncrtsh(), systemImage: "magnifyingglass")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func exportCert() {
        let certUrl = FileManager.default.temporaryDirectory.appendingPathComponent("certificate.pem")
        do {
            try self.certificate.pemString().write(toFile: certUrl.path, atomically: false, encoding: .ascii)
            self.exportedCertUrl = certUrl
        } catch {
            LogWriter.write(.Error, message: "[\(#fileID):\(#line)] Failed to write certificate to temporary file: \(error)")
        }
    }
}
