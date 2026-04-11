// TLSKit
// Copyright (C) Ian Spence and other TLSKit Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Testing
@testable import TLSKit

@Suite("Trust") struct AnchorBundleManagerTest {
    init() {
        RootCAAPIClient.apiHost = "http://127.0.0.1:8414"
        AnchorBundleManager.shared.ignoreOlderEmbeddedBundled = true
    }

    @Test func loadAndUpdateBundle() async throws {
        let manager = AnchorBundleManager.shared

        manager.purgeDownloadedBundles()
        try manager.loadBundles()

        let verifyBundle = { (name: String, bundle: CertificateBundle?, embedded: Bool) in
            guard let bundle = bundle else {
                Issue.record("\(embedded ? "Embedded" : "Downloaded") \(name) bundle was nil")
                return
            }
            #expect(bundle.embedded() == embedded)
            #expect(bundle.certificateCount == bundle.metadata.certificateCount)
        }

        verifyBundle("Apple", manager.appleBundle, true)
        verifyBundle("Google", manager.googleBundle, true)
        verifyBundle("Microsoft", manager.microsoftBundle, true)
        verifyBundle("Mozilla", manager.mozillaBundle, true)
        verifyBundle("TLS Inspector", manager.tlsinspectorBundle, true)

        // Fake the embedded bundle version
        EmbeddedAnchorBundleVersion = "bundle_20201126"

        let result = try await manager.updateNow()
        #expect(result == .updated)
        verifyBundle("Apple", manager.appleBundle, false)
        verifyBundle("Google", manager.googleBundle, false)
        verifyBundle("Microsoft", manager.microsoftBundle, false)
        verifyBundle("Mozilla", manager.mozillaBundle, false)
        verifyBundle("TLS Inspector", manager.tlsinspectorBundle, false)
    }
}
