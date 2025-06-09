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

import Foundation
import OpenSSL

/// Possible outcomes from updating anchor bundles
public enum AnchorBundleUpdateResult: Sendable, Hashable {
    /// The embedded or downloaded bundles are the latest available
    case isLatest
    /// The latest bundles were downloaded
    case updated
}

/// The manager for anchor bundles
public final class AnchorBundleManager: NSObject, Sendable, URLSessionDelegate {
    /// The shared instance of the anchor manager
    public static let shared = AnchorBundleManager()

    private override init() {
        downloadedBundleDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent("rootca")
        updateQueue = DispatchQueue(label: "io.ecn.dnskit.anchorbundlemanager")
        super.init()
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }

    /// The Apple root CA certificate bundle
    nonisolated(unsafe) public private(set) var appleBundle: CertificateBundle?

    /// The Google root CA certificate bundle
    nonisolated(unsafe) public private(set) var googleBundle: CertificateBundle?

    /// The Microsoft root CA certificate bundle
    nonisolated(unsafe) public private(set) var microsoftBundle: CertificateBundle?

    /// The Mozilla root CA certificate bundle
    nonisolated(unsafe) public private(set) var mozillaBundle: CertificateBundle?

    /// The TLS Inspector root CA certificate bundle
    nonisolated(unsafe) public private(set) var tlsinspectorBundle: CertificateBundle?

    /// If the currently loaded bundles are downloaded (true) or embedded (false)
    nonisolated(unsafe) public private(set) var usingDownloadedBundles: Bool = false

    private let bundleFiles: [String] = [
        "bundle_metadata.json",
        "apple_ca_bundle.pem",
        "google_ca_bundle.pem",
        "microsoft_ca_bundle.pem",
        "mozilla_ca_bundle.pem",
        "tlsinspector_ca_bundle.pem",
    ]

    nonisolated(unsafe) private var urlSession: URLSession!
    private let downloadedBundleDirectory: URL!
    private let updateQueue: DispatchQueue!
    nonisolated(unsafe) private var embeddedBundleMetadata: RootCABundleMetadata?
    private let downloadedBundleTag: String? = nil
    nonisolated(unsafe) private var downloadedBundleMetadata: RootCABundleMetadata?

    // Only modified for unit tests
    nonisolated(unsafe) internal var ignoreOlderEmbeddedBundled: Bool = false

    /// Loads either the embedded or downloaded bundles into the manager depending on whichever is newer
    public func loadBundles() throws {
        guard let bundleMetadataPath = Bundle.module.url(forResource: "bundle_metadata", withExtension: "json") else {
            printError("[\(#fileID):\(#line)] Unable to locate bundle metadata file")
            throw TLSKitError.internalError("Unable to locate bundle metadata file")
        }

        do {
            self.embeddedBundleMetadata = try self.readBundleMetadata(bundleMetadataPath)
        } catch {
            printError("[\(#fileID):\(#line)] Unable to load bundle metadata file: \(error)")
            throw TLSKitError.internalError("Unable to load bundle metadata file: \(error)")
        }

        do {
            try FileManager.default.createDirectory(at: self.downloadedBundleDirectory, withIntermediateDirectories: true)
        } catch {
            printError("[\(#fileID):\(#line)] Error creating downloaded bundle directory: \(error)")
            throw TLSKitError.internalError("Unable to create download directory")
        }

        if self.shouldUseDownloadedBundle() {
            printDebug("[\(#fileID):\(#line)] Loading downloaded bundles")
            try self.loadDownloadedBundles()
            printDebug("[\(#fileID):\(#line)] Loaded downloaded bundles")
            self.usingDownloadedBundles = true
        } else {
            printDebug("[\(#fileID):\(#line)] Loading embedded bundles")
            try self.loadEmbeddedBundles()
            printDebug("[\(#fileID):\(#line)] Loaded embedded bundles")
            self.usingDownloadedBundles = false
        }
    }

    internal func unloadBundles() {
        self.appleBundle = nil
        self.googleBundle = nil
        self.microsoftBundle = nil
        self.mozillaBundle = nil
        self.tlsinspectorBundle = nil
    }

    internal func purgeDownloadedBundles() {
        try? FileManager.default.removeItem(at: self.downloadedBundleDirectory)
    }

    private static func documentsDirectory() -> URL? {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        return URL(fileURLWithPath: documentsDirectory)
    }

    private func shouldUseDownloadedBundle() -> Bool {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: self.downloadedBundleDirectory.path, isDirectory: &isDirectory) {
            // Directory does not exist
            printError("[\(#fileID):\(#line)] Downloaded bundle directory does not exist")
            return false
        }
        if !isDirectory.boolValue {
            // File exists at path where directory should be
            printError("[\(#fileID):\(#line)] Downloaded bundle directory is a file")
            return false
        }

        for fileName in self.bundleFiles {
            let filePath = self.downloadedBundleDirectory.appendingPathComponent(fileName)
            let signatureName = fileName + ".sig"
            let signaturePath = self.downloadedBundleDirectory.appendingPathComponent(signatureName)

            if !FileManager.default.fileExists(atPath: filePath.path) {
                printDebug("[\(#fileID):\(#line)] Downloaded bundle file '\(fileName)' not found")
                return false
            }
            if !FileManager.default.fileExists(atPath: signaturePath.path) {
                printError("[\(#fileID):\(#line)] Downloaded bundle file '\(fileName)' does not have matching signature file")
                return false
            }
            if !self.validateSignature(filePath, signatureURL: signaturePath) {
                printError("[\(#fileID):\(#line)] Downloaded file '\(filePath)' has bad signature compared to '\(signaturePath)'")
                return false
            }
        }

        guard let bundleMetadata = try? self.readBundleMetadata(self.downloadedBundleDirectory.appendingPathComponent("bundle_metadata.json")) else {
            printError("[\(#fileID):\(#line)] Downloaded bundle has invalid metadata file")
            return false
        }

        let dateFormatter = DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")

        let checkBundle: (RootCABundleMetadataVendor, RootCABundleMetadataVendor) -> Bool = { downloaded, embedded in
            guard let downloadDate = dateFormatter.date(from: downloaded.date) else {
                printError("[\(#fileID):\(#line)] Downloaded bundle has invalid date \(downloaded.date)")
                return false
            }
            guard let embeddedDate = dateFormatter.date(from: embedded.date) else {
                return false
            }
            if embeddedDate > downloadDate && !self.ignoreOlderEmbeddedBundled {
                printDebug("[\(#fileID):\(#line)] Downloaded bundle is older than embedded bundle")
                return false
            }

            for fileName in downloaded.bundles.keys {
                if !fileName.hasSuffix(".pem") {
                    continue
                }

                let filePath = self.downloadedBundleDirectory.appendingPathComponent(fileName)
                let expectedChecksum = downloaded.bundles[fileName]!.sha256.lowercased()
                let actualChecksum: String
                do {
                    actualChecksum = try hashFile(filePath).lowercased()
                } catch {
                    printError("[\(#fileID):\(#line)] File \(fileName) checksum failed: \(error)")
                    return false
                }
                if expectedChecksum != actualChecksum {
                    printError("[\(#fileID):\(#line)] File \(fileName) checksum mismatched. Expected \(expectedChecksum) got \(actualChecksum)")
                    return false
                }
            }
            return true
        }

        if !checkBundle(bundleMetadata.apple, self.embeddedBundleMetadata!.apple) {
            return false
        }
        if !checkBundle(bundleMetadata.google, self.embeddedBundleMetadata!.google) {
            return false
        }
        if !checkBundle(bundleMetadata.microsoft, self.embeddedBundleMetadata!.microsoft) {
            return false
        }
        if !checkBundle(bundleMetadata.mozilla, self.embeddedBundleMetadata!.mozilla) {
            return false
        }
        if !checkBundle(bundleMetadata.tls_inspector, self.embeddedBundleMetadata!.tls_inspector) {
            return false
        }

        return true
    }

    private func readBundleMetadata(_ metadataPath: URL) throws -> RootCABundleMetadata {
        return try JSONDecoder().decode(RootCABundleMetadata.self, from: try Data(contentsOf: metadataPath))
    }

    private func validateSignature(_ fileURL: URL, signatureURL: URL) -> Bool {
        guard let fileData = try? Data(contentsOf: fileURL) else {
            printError("[\(#fileID):\(#line)] Error loading file data \(fileURL)")
            return false
        }
        if fileData.count == 0 {
            return false
        }
        guard let signatureData = try? Data(contentsOf: signatureURL) else {
            printError("[\(#fileID):\(#line)] Error loading signature data \(signatureURL)")
            return false
        }
        if signatureData.count == 0 {
            return false
        }

        guard let mctx = EVP_MD_CTX_new() else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] EVP_MD_CTX_new returned nil")
            return false
        }
        defer {
            EVP_MD_CTX_free(mctx)
        }

        guard let keyBio = try? EmbeddedAnchorBundleVersion.data(using: .utf8)?.toBIO() else {
            return false
        }
        defer {
            BIO_free(keyBio)
        }

        guard let pubKey = PEM_read_bio_PUBKEY(keyBio, nil, nil, nil) else {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] PEM_read_bio_PUBKEY returned nil")
            return false
        }
        defer {
            EVP_PKEY_free(pubKey)
        }

        var pctx: OpaquePointer?
        if EVP_DigestVerifyInit(mctx, &pctx, EVP_sha256(), nil, pubKey) <= 0 {
            logOpenSSLError(inFile: #fileID, atLine: #line)
            printError("[\(#fileID):\(#line)] EVP_DigestVerifyInit returned nil")
            return false
        }

        let status = signatureData.withUnsafeBytes { sigBuf in
            return fileData.withUnsafeBytes { fileBuf in
                return EVP_DigestVerify(mctx, sigBuf.baseAddress, signatureData.count, fileBuf.baseAddress, fileData.count)
            }
        }

        let verified = status == 1

        if verified {
            printDebug("[\(#fileID):\(#line)] File \(fileURL) signature verified")
        } else {
            printError("[\(#fileID):\(#line)] File \(fileURL) signature verification failed")
        }
        return verified
    }

    // MARK: - Embedded
    private func loadEmbeddedBundles() throws {
        // Apple
        guard let appleBundlePath = Bundle.module.url(forResource: "apple_ca_bundle", withExtension: "pem") else {
            throw TLSKitError.internalError("Unable to locate bundle file apple_ca_bundle.pem")
        }
        guard let metadata = self.embeddedBundleMetadata?.apple.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid embedded metadata for apple bundle")
        }
        do {
            self.appleBundle = try CertificateBundle.from(appleBundlePath, name: "Apple", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading embedded Apple bundle")
            throw error
        }

        // Google
        guard let googleBundlePath = Bundle.module.url(forResource: "google_ca_bundle", withExtension: "pem") else {
            throw TLSKitError.internalError("Unable to locate bundle file google_ca_bundle.pem")
        }
        guard let metadata = self.embeddedBundleMetadata?.google.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid embedded metadata for google bundle")
        }
        do {
            self.googleBundle = try CertificateBundle.from(googleBundlePath, name: "Google", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading embedded Google bundle")
            throw error
        }

        // Microsoft
        guard let microsoftBundlePath = Bundle.module.url(forResource: "microsoft_ca_bundle", withExtension: "pem") else {
            throw TLSKitError.internalError("Unable to locate bundle file microsoft_ca_bundle.pem")
        }
        guard let metadata = self.embeddedBundleMetadata?.microsoft.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid embedded metadata for microsoft bundle")
        }
        do {
            self.microsoftBundle = try CertificateBundle.from(microsoftBundlePath, name: "Microsoft", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading embedded Microsoft bundle")
            throw error
        }

        // Mozilla
        guard let mozillaBundlePath = Bundle.module.url(forResource: "mozilla_ca_bundle", withExtension: "pem") else {
            throw TLSKitError.internalError("Unable to locate bundle file mozilla_ca_bundle.pem")
        }
        guard let metadata = self.embeddedBundleMetadata?.mozilla.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid embedded metadata for mozilla bundle")
        }
        do {
            self.mozillaBundle = try CertificateBundle.from(mozillaBundlePath, name: "Mozilla", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading embedded Mozilla bundle")
            throw error
        }

        // TLS Inspector
        guard let tlsinspectorBundlePath = Bundle.module.url(forResource: "tlsinspector_ca_bundle", withExtension: "pem") else {
            throw TLSKitError.internalError("Unable to locate bundle file tlsinspector_ca_bundle.pem")
        }
        guard let metadata = self.embeddedBundleMetadata?.tls_inspector.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid embedded metadata for tlsinspector bundle")
        }
        do {
            self.tlsinspectorBundle = try CertificateBundle.from(tlsinspectorBundlePath, name: "TLS Inspector", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading embedded TLS Inspector bundle")
            throw error
        }
    }

    // MARK: - Downloaded

    private func loadDownloadedBundles() throws {
        guard let bundleMetadata = try? self.readBundleMetadata(self.downloadedBundleDirectory.appendingPathComponent("bundle_metadata.json")) else {
            printError("[\(#fileID):\(#line)] Downloaded bundle has invalid metadata file")
            throw TLSKitError.invalidData("Invalid downloaded bundle metadata")
        }

        // Apple
        guard let metadata = bundleMetadata.apple.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid downloaded metadata for Apple bundle")
        }
        do {
            self.appleBundle = try CertificateBundle.from(self.downloadedBundleDirectory.appendingPathComponent("apple_ca_bundle.pem"), name: "Apple", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading downloaded Apple bundle")
            throw error
        }

        // Google
        guard let metadata = bundleMetadata.google.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid downloaded metadata for Google bundle")
        }
        do {
            self.googleBundle = try CertificateBundle.from(self.downloadedBundleDirectory.appendingPathComponent("google_ca_bundle.pem"), name: "Google", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading downloaded Google bundle")
            throw error
        }

        // Microsoft
        guard let metadata = bundleMetadata.microsoft.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid downloaded metadata for Microsoft bundle")
        }
        do {
            self.microsoftBundle = try CertificateBundle.from(self.downloadedBundleDirectory.appendingPathComponent("microsoft_ca_bundle.pem"), name: "Microsoft", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading downloaded Microsoft bundle")
            throw error
        }

        // Mozilla
        guard let metadata = bundleMetadata.mozilla.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid downloaded metadata for Mozilla bundle")
        }
        do {
            self.mozillaBundle = try CertificateBundle.from(self.downloadedBundleDirectory.appendingPathComponent("mozilla_ca_bundle.pem"), name: "Mozilla", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading downloaded Mozilla bundle")
            throw error
        }

        // TLS Inspector
        guard let metadata = bundleMetadata.tls_inspector.toCertificateBundleMetadata() else {
            throw TLSKitError.invalidData("Invalid downloaded metadata for TLS Inspector bundle")
        }
        do {
            self.tlsinspectorBundle = try CertificateBundle.from(self.downloadedBundleDirectory.appendingPathComponent("tlsinspector_ca_bundle.pem"), name: "TLS Inspector", metadata: metadata)
        } catch {
            printError("[\(#fileID):\(#line)] Error loading downloaded TLS Inspector bundle")
            throw error
        }
    }

    /// Check for and download, if needed, a newer root CA certificate bundle.
    @available(iOS 13.0, *)
    public func updateNow() async throws -> AnchorBundleUpdateResult {
        try await withCheckedThrowingContinuation { continuation in
            self.updateNow { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Check for and download, if needed, a newer root CA certificate bundle.
    /// - Parameter complete: Called when complete.
    public func updateNow(_ complete: @Sendable @escaping (Result<AnchorBundleUpdateResult, Error>) -> Void) {
        self.updateQueue.async {
            do {
                complete(.success(try self.updateNowSync()))
            } catch {
                complete(.failure(error))
            }
        }
    }

    private func updateNowSync() throws -> AnchorBundleUpdateResult {
        let latestTag = try RootCAAPIClient.getLatestTag()

        if EmbeddedAnchorBundleVersion == latestTag {
            printDebug("[\(#fileID):\(#line)] Embedded bundles are up to date: \(EmbeddedAnchorBundleVersion)")
            return .isLatest
        }
        printDebug("[\(#fileID):\(#line)] Embedded bundles are outdated: \(EmbeddedAnchorBundleVersion) -> \(latestTag)")

        let metadata = try RootCAAPIClient.getMetadata(tag: latestTag)

        try RootCAAPIClient.downloadMetadataAndSignature(tag: latestTag, downloadedBundleDirectory: self.downloadedBundleDirectory)
        try RootCAAPIClient.downloadBundles(tag: latestTag, metadata: metadata, downloadedBundleDirectory: self.downloadedBundleDirectory)

        if !self.shouldUseDownloadedBundle() {
            throw TLSKitError.internalError("Downloaded bundles failed validation after update")
        }
        self.unloadBundles()
        try self.loadBundles()

        return .updated
    }

    /// Clear any downloaded bundles and revert to the embedded bundles
    public func clearDownloadedBundles() {
        do {
            try FileManager.default.removeItem(at: self.downloadedBundleDirectory)
            try self.loadBundles()
        } catch {
            printError("[\(#fileID):\(#line)] Error clearing downloaded bundles: \(error)")
        }
    }
}
