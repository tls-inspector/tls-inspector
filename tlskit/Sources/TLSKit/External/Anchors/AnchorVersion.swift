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

// This file is modified by the update-root-ca-bundles.sh script

#if DEBUG
nonisolated(unsafe) internal var EmbeddedAnchorBundleVersion = "bundle_20260422"
#else
internal let EmbeddedAnchorBundleVersion = "bundle_20260422"
#endif

internal let AnchorBundleSigningKey = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAExiFIwNh/FbegHR6DEqSZz0QcDQPI
oeMuS45AzI8Mbrs9yA9FYkgFcowDtPSO5adwZTTeCfKBamuYuIYSBlshiA==
-----END PUBLIC KEY-----
"""
