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

import Foundation

public struct Event: Sendable, Codable {
    public let device_type: String
    public let os_version: String
    public let app_version: String
    public let event: String
    public let data: [String: String]
    public let mock: Bool

    public init(device_type: String, os_version: String, app_version: String, event: String, data: [String : String], mock: Bool = false) {
        self.device_type = device_type
        self.os_version = os_version
        self.app_version = app_version
        self.event = event
        self.data = data
        self.mock = mock
    }
}

public enum CrashpadError: Error {
    case submitError
}

public struct Crashpad: Sendable {
    public static func send(event: Event, complete: @Sendable @escaping (Error?) -> Void) {
        let thumbprint: Data
        do {
            thumbprint = try DNS.getAndVerifyFingerprint(forHost: "tlsinspector.com")
        } catch {
            print("Error getting and verifying TLS certificate fingerprint: \(error)")
            complete(CrashpadError.submitError)
            return
        }

        let request: URLRequest
        do {
            request = try self.urlRequest(for: event)
        } catch {
            complete(CrashpadError.submitError)
            return
        }

        TLS(thumbprint: thumbprint).dataTask(with: request) { body, response, error in
            if let error = error {
                complete(error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                complete(CrashpadError.submitError)
                return
            }
            if response.statusCode == 204 {
                complete(nil)
                return
            }
            if let body = body {
                let bodyStr = String(decoding: body, as: UTF8.self)
                print("Error submitting events: \(bodyStr)")
            }
            complete(CrashpadError.submitError)
        }
    }

    @available(iOS 15.0, *)
    public static func sendAsync(event: Event) async throws {
        let thumbprint: Data
        do {
            thumbprint = try DNS.getAndVerifyFingerprint(forHost: "tlsinspector.com")
        } catch {
            print("Error getting and verifying TLS certificate fingerprint: \(error)")
            throw CrashpadError.submitError
        }

        let request = try self.urlRequest(for: event)

        let (data, response) = try await TLS(thumbprint: thumbprint).data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw CrashpadError.submitError
        }
        if response.statusCode == 204 {
            return
        }
        let bodyStr = String(decoding: data, as: UTF8.self)
        print("Error submitting events: \(bodyStr)")
        throw CrashpadError.submitError
    }

    internal static func urlRequest(for event: Event) throws -> URLRequest {
        let body = try JSONEncoder().encode(event)
        var request = URLRequest(url: URL(string: "https://api.tlsinspector.com/crashpad/events")!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("CrashPad/1.0 (tls-inspector/3.0)", forHTTPHeaderField: "User-Agent")
        request.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        return request
    }
}
