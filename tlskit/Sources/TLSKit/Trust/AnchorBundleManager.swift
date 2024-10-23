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

/// The manager for anchor bundles
@MainActor
public final class AnchorBundleManager: NSObject, URLSessionDelegate {
    /// The shared instance of the anchor manager
    public static let shared = AnchorBundleManager()

    fileprivate override init() {
        super.init()
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        self.downloadedBundleDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("rootca")
    }

    /// The Apple root CA certificate bundle
    public private(set) var appleBundle: CertificateBundle? = nil

    /// The Google root CA certificate bundle
    public private(set) var googleBundle: CertificateBundle? = nil

    /// The Microsoft root CA certificate bundle
    public private(set) var microsoftBundle: CertificateBundle? = nil

    /// The Mozilla root CA certificate bundle
    public private(set) var mozillaBundle: CertificateBundle? = nil

    fileprivate var urlSession: URLSession!
    fileprivate var downloadedBundleDirectory: String!

    fileprivate let embeddedBundleTag = String(decoding: PackageResources.bundle_version_txt, as: UTF8.self)
    fileprivate var embeddedBundleMetadata: RootCABundleMetadata? = nil

    fileprivate let downloadedBundleTag: String? = nil
    fileprivate var downloadedBundleMetadata: RootCABundleMetadata? = nil

    /// Loads either the embedded or downloaded bundles into the manager depending on whichever is newer
    public func loadBundles() throws {
        /*
         NSString * bundleDatePath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"bundle_version" ofType:@"txt"];
         NSString * bundleTag = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:bundleDatePath] encoding:NSUTF8StringEncoding];
         bundleTag = [bundleTag stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
         self.embeddedBundleTag = bundleTag;

         NSString * bundleMetadataPath = [[NSBundle bundleWithIdentifier:@"com.tlsinspector.CertificateKit"] pathForResource:@"bundle_metadata" ofType:@"json"];
         NSData * bundleData = [NSData dataWithContentsOfFile:bundleMetadataPath];
         self.embeddedBundleMetadata = [NSJSONSerialization JSONObjectWithData:bundleData options:kNilOptions error:nil];

         if ([self shouldUseDownloadedBundles]) {
             PDebug(@"[rootca] loading downloaded bundles");
             self.usingDownloadedBundles = [self loadDownloadedBundles];
         } else {
             PDebug(@"[rootca] loading embedded bundles");
             [self loadEmbeddedBundles];
             self.usingDownloadedBundles = NO;
         }
         */

        guard let bundleMetadataPath = Bundle.module.url(forResource: "", withExtension: ""),
              let bundleMetadataData = try? Data(contentsOf: bundleMetadataPath),
              let bundleMetadata = try? JSONDecoder().decode(RootCABundleMetadata.self, from: bundleMetadataData) else {
            printError("[\(#fileID):\(#line)] Error reading bundle_metadata.json")
            throw MakeError("Error reading bundle metadata")
        }

        self.embeddedBundleMetadata = bundleMetadata
    }

    /*
     - (BOOL) shouldUseDownloadedBundles {
         BOOL isDirectory = NO;
         if (![NSFileManager.defaultManager fileExistsAtPath:self.bundleDirectory isDirectory:&isDirectory]) {
             return NO; // Dir does not exist
         }
         if (!isDirectory) {
             PError(@"[rootca] File at path where bundle directory was expected");
             [NSFileManager.defaultManager removeItemAtPath:self.bundleDirectory error:nil];
             return NO; // Dir exists but is file
         }

         for (NSString * fileName in self.bundleFiles) {
             NSString * filePath = [self.bundleDirectory stringByAppendingPathComponent:fileName];
             NSString * signatureName = [NSString stringWithFormat:@"%@.sig", fileName];
             NSString * signaturePath = [self.bundleDirectory stringByAppendingPathComponent:signatureName];

             if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
                 return NO; // file does not exist
             }
             if (![NSFileManager.defaultManager fileExistsAtPath:signaturePath]) {
                 PError(@"[rootca] Downloaded file does not have associated signature file");
                 return NO; // signature does not exist
             }

             if (![self verifyFileSignature:filePath signature:signaturePath]) {
                 PError(@"[rootca] Downloaded file has bad signature %@", filePath);
                 return NO; // bad signature
             }
         }

         NSData * bundleData = [NSData dataWithContentsOfFile:[self.bundleDirectory stringByAppendingPathComponent:@"bundle_metadata.json"]];
         NSError * jsonError;
         NSDictionary<NSString *, id> * metadata = [NSJSONSerialization JSONObjectWithData:bundleData options:kNilOptions error:&jsonError];
         if (jsonError) {
             PError(@"[rootca] Downloaded metadata file is invalid: %@", jsonError.localizedDescription);
             return NO;
         }
         NSDateFormatter * formatter = [NSDateFormatter new];
         formatter.dateFormat = @"yyyy-MM-ddTHH:mm:ssZ"; // 2022-10-11T03:12:05Z

         for (NSString * key in @[@"apple", @"google", @"microsoft", @"mozilla"]) {
             NSDate * downloadDate = [formatter dateFromString:metadata[key][@"date"]];
             NSDate * embedDate = [formatter dateFromString:self.embeddedBundleMetadata[key][@"date"]];
             if (embedDate > downloadDate) {
                 return NO; // embedded bundle is newer
             }

             NSString * fileName = [NSString stringWithFormat:@"%@_ca_bundle.p7b", key];
             NSString * filePath = [self.bundleDirectory stringByAppendingPathComponent:fileName];
             NSString * expectedChecksum = [metadata[key][@"bundles"][fileName][@"sha256"] uppercaseString];
             NSString * actualChecksum = [self getFileChecksum:filePath];
             if (actualChecksum == nil) {
                 return NO;
             }
             if (![expectedChecksum isEqualToString:actualChecksum]) {
                 PDebug(@"[rootca] Checksum result for %@:\r- Expected: %@\r- Actual: %@", fileName, expectedChecksum, actualChecksum);
                 PError(@"[rootca] Downloaded bundle file failed checksum validation: %@", fileName);
                 return NO;
             }
         }

         return YES;
     }
     */

    internal func shouldUseDownloadedBundle() -> Bool {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: self.downloadedBundleDirectory, isDirectory: &isDirectory) {
            // Directory does not exist
            return false
        }
        if !isDirectory.boolValue {
            // File exists at path where directory should be
            return false
        }

        return false
    }
}
