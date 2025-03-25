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

public struct EngineOptions: Sendable, Codable {
    public let ciphers: String

    public init(ciphers: String = "HIGH:!aNULL:!MD5:!RC4") {
        self.ciphers = ciphers
    }
}

public enum EngineType: Int, Sendable, CaseIterable, Codable {
    case NetworkFramework = 1
    case OpenSSL = 2
}

internal protocol Engine: Sendable {
    init(engineOptions: EngineOptions)
    func execute(_ request: InspectionRequest,
                 _ target: InspectionTarget,
                 _ dispatchQueue: DispatchQueue,
                 _ complete: @Sendable @escaping (Result<InspectionResponse, TLSKitError>) -> Void)
}
