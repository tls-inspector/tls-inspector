// swift-tools-version: 6.0

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

import PackageDescription

let package = Package(
    name: "TLSKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "TLSKit",
            targets: ["TLSKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/dns-inspector/dnskit", revision: "d5883384c61d69e7b2a80e813b0824d341672b5f"),
        .package(url: "https://github.com/Wevah/IDNA-Cocoa", revision: "96de66e18f27edd40e41321f63637fbf2a83eb41")
    ],
    targets: [
        .target(
            name: "TLSKit",
            dependencies: [
                "OpenSSL",
                "Curl",
                .product(name: "IDNA", package: "idna-cocoa"),
                .product(name: "DNSKit", package: "dnskit"),
            ],
            resources: [
                .copy("External/Anchors/apple_ca_bundle.pem"),
                .copy("External/Anchors/google_ca_bundle.pem"),
                .copy("External/Anchors/microsoft_ca_bundle.pem"),
                .copy("External/Anchors/mozilla_ca_bundle.pem"),
                .copy("External/Anchors/tlsinspector_ca_bundle.pem"),
                .copy("External/Anchors/bundle_metadata.json"),
                .copy("External/CT Logs/ct_log_list.min.json"),
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .binaryTarget(name: "OpenSSL", path: "openssl.xcframework"),
        .binaryTarget(name: "Curl", path: "curl.xcframework"),
        .testTarget(
            name: "TLSKitTests",
            dependencies: ["TLSKit", "OpenSSL", "Curl"],
            exclude: [
                "TestServer/"
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        )
    ]
)
