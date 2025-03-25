// TLSKit
// Copyright (C) 2024 Ian Spence
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

/// A client for interacting with the Root CA API
internal final class RootCAAPIClient: Sendable {
    nonisolated(unsafe) internal static var apiHost = "https://api.tlsinspector.com"

    /// Get the latest tag name
    /// - Returns: The latest tag name
    static func getLatestTag() throws -> String {
        let client: CurlClient
        do {
            client = try CurlClient(url: "\(apiHost)/rootca/latest")
        } catch {
            printError("[\(#fileID):\(#line)] Error loading curl: \(error)")
            throw error
        }

        struct tagResponseType: Codable {
            let version: String
        }

        let result: CurlResponse
        switch client.get() {
        case .success(let data):
            result = data
        case .failure(let error):
            printError("[\(#fileID):\(#line)] Error getting latest bundle metadata: \(error)")
            throw error
        }

        if result.statusCode != 200 {
            printError("[\(#fileID):\(#line)] HTTP error getting latest bundle metadata: \(result.statusCode)")
            throw TLSKitError.httpError(Int(result.statusCode))
        }

        let response: tagResponseType
        do {
            response = try JSONDecoder().decode(tagResponseType.self, from: result.body)
        } catch {
            printError("[\(#fileID):\(#line)] Unable to parse bundle metadata: \(error)")
            throw TLSKitError.invalidData("\(error)")
        }
        return response.version
    }

    /// Get the metadata for the given tag
    /// - Parameter tag: The tag name or `latest`
    /// - Returns: The metadata
    static func getMetadata(tag: String) throws -> RootCABundleMetadata {
        let client: CurlClient
        do {
            client = try CurlClient(url: "\(apiHost)/rootca/metadata/\(tag)")
        } catch {
            printError("[\(#fileID):\(#line)] Error loading curl: \(error)")
            throw error
        }

        let result: CurlResponse
        switch client.get() {
        case .success(let data):
            result = data
        case .failure(let error):
            printError("[\(#fileID):\(#line)] Error getting \(tag) bundle metadata: \(error)")
            throw error
        }

        if result.statusCode != 200 {
            printError("[\(#fileID):\(#line)] HTTP error getting \(tag) bundle metadata: \(result.statusCode)")
            throw TLSKitError.httpError(Int(result.statusCode))
        }

        let metadata: RootCABundleMetadata
        do {
            metadata = try JSONDecoder().decode(RootCABundleMetadata.self, from: result.body)
        } catch {
            printError("[\(#fileID):\(#line)] Unable to parse bundle metadata: \(error)")
            throw TLSKitError.invalidData("\(error)")
        }
        return metadata
    }

    static func downloadMetadataAndSignature(tag: String, downloadedBundleDirectory: URL) throws {
        // Download the bundle
        let fileName = "bundle_metadata.json"
        var filePath = downloadedBundleDirectory.appendingPathComponent(fileName)
        var url = "\(apiHost)/rootca/asset/\(tag)/\(fileName)"
        printDebug("[\(#fileID):\(#line)] Downloading \(url) to \(filePath)")
        var client = try CurlClient(url: url)
        var size = try client.downloadFile(filePath)
        printDebug("[\(#fileID):\(#line)] Saved \(size)B to \(filePath)")

        // Download the signature
        filePath = downloadedBundleDirectory.appendingPathComponent(fileName+".sig")
        url = "\(apiHost)/rootca/asset/\(tag)/\(fileName).sig"
        printDebug("[\(#fileID):\(#line)] Downloading \(url) to \(filePath)")
        client = try CurlClient(url: url)
        size = try client.downloadFile(filePath)
        printDebug("[\(#fileID):\(#line)] Saved \(size)B to \(filePath)")
    }

    static func downloadBundles(tag: String, metadata: RootCABundleMetadata, downloadedBundleDirectory: URL) throws {
        let queue = OperationQueue()
        let appleError: AtomicVar<Error> = .init()
        let googleError: AtomicVar<Error> = .init()
        let microsoftError: AtomicVar<Error> = .init()
        let mozillaError: AtomicVar<Error> = .init()
        let tlsInspectorError: AtomicVar<Error> = .init()

        queue.addOperation {
            do {
                try RootCAAPIClient.downloadVendor(tag, vendor: metadata.apple, to: downloadedBundleDirectory)
            } catch {
                appleError.Set(newValue: error)
            }
        }

        queue.addOperation {
            do {
                try RootCAAPIClient.downloadVendor(tag, vendor: metadata.google, to: downloadedBundleDirectory)
            } catch {
                googleError.Set(newValue: error)
            }
        }

        queue.addOperation {
            do {
                try RootCAAPIClient.downloadVendor(tag, vendor: metadata.microsoft, to: downloadedBundleDirectory)
            } catch {
                microsoftError.Set(newValue: error)
            }
        }

        queue.addOperation {
            do {
                try RootCAAPIClient.downloadVendor(tag, vendor: metadata.mozilla, to: downloadedBundleDirectory)
            } catch {
                mozillaError.Set(newValue: error)
            }
        }

        queue.addOperation {
            do {
                try RootCAAPIClient.downloadVendor(tag, vendor: metadata.tls_inspector, to: downloadedBundleDirectory)
            } catch {
                tlsInspectorError.Set(newValue: error)
            }
        }

        printDebug("[\(#fileID):\(#line)] Waiting for downloads...")
        queue.waitUntilAllOperationsAreFinished()
        if let error = appleError.Get() {
            throw error
        }
        if let error = googleError.Get() {
            throw error
        }
        if let error = microsoftError.Get() {
            throw error
        }
        if let error = mozillaError.Get() {
            throw error
        }
        if let error = tlsInspectorError.Get() {
            throw error
        }
        printDebug("[\(#fileID):\(#line)] Downloads complete")
    }

    /// Download the pem bundle & signature for the given vendor
    /// - Parameters:
    ///   - tag: The tag name or `latest`
    ///   - vendor: The vendor
    ///   - destination: The destination directory
    static func downloadVendor(_ tag: String, vendor: RootCABundleMetadataVendor, to destination: URL) throws {
        guard let fileName = vendor.bundles.keys.first(where: { name in
            return name.hasSuffix(".pem")
        }) else {
            throw TLSKitError.invalidData("No pem file found for vendor")
        }

        // Download the bundle
        var filePath = destination.appendingPathComponent(fileName)
        var url = "\(apiHost)/rootca/asset/\(tag)/\(fileName)"
        printDebug("[\(#fileID):\(#line)] Downloading \(url) to \(filePath)")
        var client = try CurlClient(url: url)
        var size = try client.downloadFile(filePath)
        printDebug("[\(#fileID):\(#line)] Saved \(size)B to \(filePath)")

        // Download the signature
        filePath = destination.appendingPathComponent(fileName+".sig")
        url = "\(apiHost)/rootca/asset/\(tag)/\(fileName).sig"
        printDebug("[\(#fileID):\(#line)] Downloading \(url) to \(filePath)")
        client = try CurlClient(url: url)
        size = try client.downloadFile(filePath)
        printDebug("[\(#fileID):\(#line)] Saved \(size)B to \(filePath)")
    }
}
