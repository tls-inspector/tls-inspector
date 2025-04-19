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

import Testing
import Network
@testable import TLSKit

@Suite("HTTP") struct HTTPClientTests {
    @Test func httpGet() throws {
        let queue = DispatchQueue(label: "HTTPClientTests.httpGet")
        let semaphore = DispatchSemaphore(value: 0)
        let didComplete = AtomicBool(initialValue: false)

        let client = HTTPClient()
        let connection = NWConnection(host: .name("example.com", nil), port: .https, using: .tls)
        connection.stateUpdateHandler = { state in
            if state == .ready {
                let request = client.requestFor(host: "example.com")
                connection.send(content: request, completion: .contentProcessed({ error in
                    if let error = error {
                        Issue.record(error)
                        didComplete.Set(newValue: true)
                        semaphore.signal()
                        return
                    }
                    client.response(from: connection) { result in
                        switch result {
                        case .success(let serverInfo):
                            #expect(serverInfo.statusCode == 200)
                            #expect(serverInfo.headers.get1("Content-Length") != nil)
                        case .failure(let failure):
                            Issue.record(failure)
                        }
                        connection.cancel()
                        didComplete.Set(newValue: true)
                        semaphore.signal()
                    }
                }))
            }
        }
        connection.start(queue: queue)

        _ = semaphore.wait(timeout: DispatchTime.now().adding(seconds: 10))
        didComplete.If(false) {
            connection.cancel()
            printError("[\(#fileID):\(#line)] Connection timed out")
            Issue.record("Connection timed out")
            return true
        }
    }
}
