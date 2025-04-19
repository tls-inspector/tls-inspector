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

internal typealias X509_NAME = OpaquePointer
internal typealias X509_NAME_ENTRY = OpaquePointer

/// Describes a X.509 name object.
///
/// Note that X.509 allows multiple values per each
public struct Name: Equatable, Sendable {
    /// The common name
    public let commonName: [String]
    /// The two-letter country code
    public let country: [String]
    /// The state or provice
    public let state: [String]
    /// The city or locality
    public let locality: [String]
    /// The organization name
    public let organization: [String]
    /// The organizational unit
    public let organizationUnit: [String]
    /// The email address
    public let emailAddress: [String]
    /// General description of the name. This is typically the first common name.
    public let description: String

    internal init(commonName: [String] = [], country: [String] = [], state: [String] = [], locality: [String] = [], organization: [String] = [], organizationUnit: [String] = [], emailAddress: [String] = []) {
        self.commonName = commonName
        self.country = country
        self.state = state
        self.locality = locality
        self.organization = organization
        self.organizationUnit = organizationUnit
        self.emailAddress = emailAddress
        self.description = commonName.count > 0 ? commonName[0] : "Unnamed Certificate"
    }

    internal init(_ name: X509_NAME) {
        self = Name(
            commonName: Name.getNidValuesFromName(name, nid: NID_commonName),
            country: Name.getNidValuesFromName(name, nid: NID_countryName),
            state: Name.getNidValuesFromName(name, nid: NID_stateOrProvinceName),
            locality: Name.getNidValuesFromName(name, nid: NID_localityName),
            organization: Name.getNidValuesFromName(name, nid: NID_organizationName),
            organizationUnit: Name.getNidValuesFromName(name, nid: NID_organizationalUnitName),
            emailAddress: Name.getNidValuesFromName(name, nid: NID_pkcs9_emailAddress)
        )
    }

    internal static func getNidValuesFromName(_ name: X509_NAME, nid: Int32) -> [String] {
        var values: [String] = []
        var lastPos: Int32 = -1
        while true {
            let idx = X509_NAME_get_index_by_NID(name, nid, lastPos)
            if idx < 0 {
                return values
            }
            lastPos = idx

            guard let entry: X509_NAME_ENTRY = X509_NAME_get_entry(name, idx) else {
                return values
            }

            guard let data = X509_NAME_ENTRY_get_data(entry) else {
                return values
            }

            guard let value = String.from(asn1: data) else {
                return values
            }
            values.append(value)
        }

        return values
    }
}
