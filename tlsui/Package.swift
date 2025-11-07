// swift-tools-version: 6.2

// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
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
    name: "TLSUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "TLSUI",
            targets: ["TLSUI"]
        ),
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
    ],
    dependencies: [
        .package(name: "TLSKit", path: "../tlskit"),
        .package(name: "Crashpad", path: "../crashpad"),
    ],
    targets: [
        .target(
            name: "TLSUI",
            dependencies: ["Localization", "TLSKit", "Crashpad"],
            resources: [.process("Resources")],
        ),
        .target(
            name: "Localization",
            exclude: [
                "README.md",
                "lang.py",
                "Strings"
            ],
        ),
    ]
)
