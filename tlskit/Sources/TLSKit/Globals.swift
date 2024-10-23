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

internal let CertificateChainMaximumLength = 10

/// Optional value to append to the user agent header for HTTP requests.
///
/// The user agent value used by the HTTP client is:
/// ```
/// "DNSKit"[ + " " + UserAgentSuffix]
/// ```
/// 
/// This should only be set once, preferably during startup of the application, and must never be changed once TLSKit is used.
nonisolated(unsafe) public var UserAgentSuffix: String?
