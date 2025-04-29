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
        AnchorBundleManager.shared.purgeDownloadedBundles()
        try AnchorBundleManager.shared.loadBundles()

        let verifyBundle = { (bundle: CertificateBundle?, embedded: Bool) in
            #expect(bundle != nil)
            #expect(bundle!.embedded() == embedded)
            #expect(bundle!.certificateCount == bundle!.metadata.certificateCount)
        }

        verifyBundle(AnchorBundleManager.shared.appleBundle, true)
        verifyBundle(AnchorBundleManager.shared.googleBundle, true)
        verifyBundle(AnchorBundleManager.shared.microsoftBundle, true)
        verifyBundle(AnchorBundleManager.shared.mozillaBundle, true)
        verifyBundle(AnchorBundleManager.shared.tlsinspectorBundle, true)

        // Fake the embedded bundle version
        AnchorBundleManager.shared.embeddedBundleTag = "bundle_20201126"

        let result = try await AnchorBundleManager.shared.updateNow()
        #expect(result == .updated)
        verifyBundle(AnchorBundleManager.shared.appleBundle, false)
        verifyBundle(AnchorBundleManager.shared.googleBundle, false)
        verifyBundle(AnchorBundleManager.shared.microsoftBundle, false)
        verifyBundle(AnchorBundleManager.shared.mozillaBundle, false)
        verifyBundle(AnchorBundleManager.shared.tlsinspectorBundle, false)
    }
}
