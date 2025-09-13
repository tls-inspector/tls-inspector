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

internal final class TLS: NSObject, URLSessionDelegate {
    private let thumbprint: Data

    init(thumbprint: Data) {
        self.thumbprint = thumbprint
    }

    func dataTask(with request: URLRequest, completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }

    @available(iOS 15.0, *)
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        return try await session.data(for: request)
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace

        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            guard let trust = protectionSpace.serverTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            guard let cert = SecTrustGetCertificateAtIndex(trust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let certDer = SecCertificateCopyData(cert) as Data
            let thumbprint = certDer.sha256()

            if thumbprint == self.thumbprint {
                completionHandler(.useCredential, URLCredential(trust: trust))
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
