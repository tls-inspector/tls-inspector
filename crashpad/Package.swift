// swift-tools-version: 6.1

// Crashpad
// Copyright (C) Ian Spence and other Crashpad Contributors
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
    name: "Crashpad",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "Crashpad",
            targets: ["Crashpad"]
        ),
    ],
    targets: [
        .target(
            name: "Crashpad",
            dependencies: ["Bsdresolve"],
            linkerSettings: [
                .linkedLibrary("resolv")
            ]
        ),
        .systemLibrary(
            name: "Bsdresolve",
            pkgConfig: nil,
            providers: nil
        ),
        .testTarget(
            name: "CrashpadTests",
            dependencies: ["Crashpad"],
            linkerSettings: [
                .linkedLibrary("resolv")
            ]
        ),
    ]
)
