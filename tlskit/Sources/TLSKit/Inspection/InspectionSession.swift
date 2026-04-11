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

/// An inspection session. Sessions are the primary entrypoint for TLSKit and should be retained for the duration of the inspection request.
public final class InspectionSession: Sendable {
    private let dispatchQueue: DispatchQueue
    private let engineType: EngineType
    private let engine: Engine
    private let engineOptions: EngineOptions

    /// Create a new inspection session
    /// - Parameters:
    ///   - engineType: The engine type to use
    ///   - engineOptions: Optional set of options for the engine
    public init(engineType: EngineType, engineOptions: EngineOptions = EngineOptions()) {
        self.dispatchQueue = DispatchQueue(label: "io.ecn.dnskit.inspectionsession", qos: .userInteractive)
        self.engineType = engineType

        switch engineType {
        case .OpenSSL:
            self.engine = OpenSSLEngine(engineOptions: engineOptions)
        case .NetworkFramework:
            self.engine = NetworkFrameworkEngine(engineOptions: engineOptions)
        }

        self.engineOptions = engineOptions
    }

    /// Execute the request
    /// - Parameter request: The request to perform
    /// - Returns: The inspection response
    ///
    /// > Important: TLSKit does not officially support multiple inspections being performed at the same time, even if
    /// > it may work without issue.
    @available(iOS 13.0, *)
    public func execute(_ request: InspectionRequest) async throws -> InspectionResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.execute(request) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Execute the request in the background
    /// - Parameters:
    ///   - request: The request to perform
    ///   - complete: Called when the request is complete
    ///
    /// > Important: TLSKit does not officially support multiple inspections being performed at the same time, even if
    /// > it may work without issue.
    public func execute(_ request: InspectionRequest, complete: @Sendable @escaping (Result<InspectionResponse, TLSKitError>) -> Void) {
        request.getInspectionTarget { resolveResult in
            switch resolveResult {
            case .success(let target):
                self.engine.execute(request, target, self.dispatchQueue, complete)
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
}
