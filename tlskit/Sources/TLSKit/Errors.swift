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

/// All possible errors that TLSKit can produce
public enum TLSKitError: Error, Sendable, LocalizedError {
    /// The connection to the target was unsuccessful. More details are available.
    case connectionError(Error)
    /// The remote host took too long to respond.
    case timedOut
    /// The server produced a response that indicated an error has occured. More details are available.
    case responseError(String)
    /// An internal error occured while processing the data. More details are available.
    case invalidData(String)
    /// The certificate is invalid. More details are available.
    case invalidCertificate(String)
    /// The cryptographic algorithm presented is not supported by DNSKit.
    case unrecognizedAlgorithm
    /// An internal processing error has occured. More details are available.
    case internalError(String)
    /// The HTTP request was unsuccessful. Contains the HTTP status code.
    case httpError(Int)
    /// The content type header on the response was unexpected or missing. Contains the value of the content type
    /// header, or an empty string if it was missing.
    case invalidContentType(String)

    public var errorDescription: String? {
        switch self {
        case .connectionError(let underlaying):
            return "Connection error: \(underlaying)"
        case .timedOut:
            return "Timed out"
        case .responseError(let underlaying):
            return "Response error: \(underlaying)"
        case .invalidData(let underlaying):
            return "Invalid data: \(underlaying)"
        case .invalidCertificate(let underlaying):
            return "Invalid certificate: \(underlaying)"
        case .unrecognizedAlgorithm:
            return "Unrecognized algorithm"
        case .internalError(let underlaying):
            return "Internal error: \(underlaying):"
        case .httpError(let underlaying):
            return "HTTP error: \(underlaying)"
        case .invalidContentType(let underlaying):
            return "Invalid content type: \(underlaying)"
        }
    }
}
