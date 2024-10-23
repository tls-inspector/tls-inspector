// TLS Inspector
// Copyright (C) 2024 Ian Spence
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import TLSKit

public struct CertificateValidityPeriodView: View {
    public let validityPeriod: ValidityPeriod
    private let notBefore: String
    private let notAfter: String
    private let validFor: String
    private let willExpireIn: String

    public init(validityPeriod: ValidityPeriod) {
        self.validityPeriod = validityPeriod

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        self.notBefore = dateFormatter.string(from: validityPeriod.notBefore)
        self.notAfter = dateFormatter.string(from: validityPeriod.notAfter)
        self.validFor = DateDuration.between(first: validityPeriod.notBefore, second: validityPeriod.notAfter)
        self.willExpireIn = DateDuration.between(first: Date(), second: validityPeriod.notAfter)
    }

    public var body: some View {
        Section("Validity Period") {
            HStack {
                Text("Not Before").opacity(0.5)
                Spacer()
                Text("\(notBefore)")
            }
            HStack {
                Text("Not After").opacity(0.5)
                Spacer()
                Text("\(notAfter)")
            }
            HStack {
                Text("Valid For").opacity(0.5)
                Spacer()
                Text("\(validFor)")
            }
            HStack {
                Text("Expires In").opacity(0.5)
                Spacer()
                Text("\(willExpireIn)")
            }
        }
    }
}
