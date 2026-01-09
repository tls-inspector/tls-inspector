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

/// Describes the response from an inspection
public struct InspectionResponse: Identifiable, Sendable {
    public let tlsConnection: TLSConnection
    public let httpServerInfo: HTTPServerInfo?
    public let httpServerError: TLSKitError?
    public let elapsedNs: UInt64
    public var id = UUID()

    public init(tlsConnection: TLSConnection, httpServerInfo: HTTPServerInfo?, httpServerError: TLSKitError?, elapsedNs: UInt64, id: UUID = UUID()) {
        self.tlsConnection = tlsConnection
        self.httpServerInfo = httpServerInfo
        self.httpServerError = httpServerError
        self.elapsedNs = elapsedNs
        self.id = id
    }
}
