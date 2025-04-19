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
import Network
import OpenSSL

private let maxHeaderSize = 102400 /* 100KiB - same as libcurl */

/// The embedded DNSKit HTTP client.
public final class HTTPClient: Sendable {
    // Nonisolated because the network framework only calls one callback at a time
    nonisolated(unsafe) private var headerData = Data()

    internal func requestFor(host: String) -> Data {
        let userAgent = "TLSKit" + (UserAgentSuffix != nil ? " \(UserAgentSuffix!)" : "")
        let request = "GET / HTTP/1.1\r\nHost: \(host)\r\nUser-Agent: \(userAgent)\r\nAccept: */*\r\n\r\n"
        printDebug("[\(#fileID):\(#line)] HTTP Request: \(request.escapeNewlines())")
        return request.data(using: .ascii)!
    }

    private func connectionReadLoop(_ connection: NWConnection, _ statusCode: UInt16, _ complete: @Sendable @escaping (Result<HTTPServerInfo, TLSKitError>) -> Void) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { oContent, _, _, oError in
            if let error = oError {
                printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                complete(.failure(.connectionError(error)))
                return
            }
            guard let content = oContent else {
                printError("[\(#fileID):\(#line)] No response from HTTP server")
                complete(.failure(.invalidData("No response")))
                return
            }
            let data: [UInt8] = Array(content)

            var hasAllHeaders = false
            var headersEndIdx = -1
            for i in 0...data.count - 3 {
                // look for the end of headers, denoted by two linebreaks (http uses CRLF)
                if data[i] == 0x0D /* \r */
                    && data[i+1] == 0x0A /* \n */
                    && data[i+2] == 0x0D /* \r */
                    && data[i+3] == 0x0A /* \n */ {
                    headersEndIdx = i
                    hasAllHeaders = true
                    printDebug("[\(#fileID):\(#line)] Found start of HTTP body at offset \(i)")
                    break
                }
            }

            if hasAllHeaders {
                self.headerData.append(Data(data[0..<headersEndIdx]))
                let headers = HTTPHeaders.fromResponse(self.headerData)
                let serverInfo = HTTPServerInfo(headers: headers, statusCode: statusCode)
                complete(.success(serverInfo))
                return
            } else if self.headerData.count + data.count > maxHeaderSize {
                printError("[\(#fileID):\(#line)] HTTP header data exceeded maximum length")
                complete(.failure(.responseError("HTTP header data exceeded maximum length")))
                return
            } else {
                printDebug("[\(#fileID):\(#line)] Still reading HTTP headers")
            }

            self.headerData.append(oContent!)
            self.connectionReadLoop(connection, statusCode, complete)
        }
    }

    internal func response(from connection: NWConnection, _ complete: @Sendable @escaping (Result<HTTPServerInfo, TLSKitError>) -> Void) {
        // Read the first 12 bytes, which should contain both the HTTP status code and version
        connection.receive(minimumIncompleteLength: 12, maximumLength: 12) { oContent, _, _, oError in
            if let error = oError {
                printError("[\(#fileID):\(#line)] Error recieving data: \(error)")
                complete(.failure(.connectionError(error)))
                return
            }
            if oContent == nil {
                printError("[\(#fileID):\(#line)] No response from HTTP server")
                complete(.failure(.invalidData("No response")))
                return
            }
            let data: [UInt8] = Array(oContent!)

            // The HTTP client only supports HTTP/1.1
            let httpVersion = String(decoding: data[..<8], as: UTF8.self).lowercased()
            if httpVersion != "http/1.1" {
                printError("[\(#fileID):\(#line)] Unknown or unsupported HTTP version in response: \(httpVersion)")
                complete(.failure(.responseError("Unsupported HTTP version \(httpVersion)")))
                return
            }

            let statusCodeString = String(decoding: data[9..<12], as: UTF8.self)
            guard let statusCode = UInt16(statusCodeString) else {
                printError("[\(#fileID):\(#line)] Invalid HTTP status code: \(statusCodeString)")
                complete(.failure(.invalidData("Invalid HTTP status code \(statusCodeString)")))
                return
            }
            if statusCode < 100 || statusCode > 599 {
                printError("[\(#fileID):\(#line)] Invalid HTTP status code: \(statusCode)")
                complete(.failure(.invalidData("Invalid HTTP status code \(statusCodeString)")))
                return
            }

            printDebug("[\(#fileID):\(#line)] HTTP response from server \(String(decoding: data, as: UTF8.self))")
            self.connectionReadLoop(connection, statusCode, complete)
        }
    }

    internal func response(from bio: OpaquePointer) -> Result<HTTPServerInfo, TLSKitError> {
        var responseGreeting = ContiguousArray(repeating: UInt8(0), count: 12)
        var read = responseGreeting.withUnsafeMutableBytes {
            printDebug("[\(#fileID):\(#line)] Reading HTTP greeting")
            return Int(BIO_read(bio, $0.baseAddress, 12))
        }
        if read != 12 {
            printError("[\(#fileID):\(#line)] No response from HTTP server")
            return .failure(.invalidData("No response"))
        }
        printDebug("[\(#fileID):\(#line)] Got HTTP greeting")

        // The HTTP client only supports HTTP/1.1
        let httpVersion = String(decoding: responseGreeting[..<8], as: UTF8.self).lowercased()
        if httpVersion != "http/1.1" {
            printError("[\(#fileID):\(#line)] Unknown or unsupported HTTP version in response: \(httpVersion)")
            return .failure(.responseError("Unsupported HTTP version \(httpVersion)"))
        }

        let statusCodeString = String(decoding: responseGreeting[9..<12], as: UTF8.self)
        guard let statusCode = UInt16(statusCodeString) else {
            printError("[\(#fileID):\(#line)] Invalid HTTP status code: \(statusCodeString)")
            return .failure(.invalidData("Invalid HTTP status code \(statusCodeString)"))
        }
        if statusCode < 100 || statusCode > 599 {
            printError("[\(#fileID):\(#line)] Invalid HTTP status code: \(statusCode)")
            return .failure(.invalidData("Invalid HTTP status code \(statusCodeString)"))
        }

        var headerData = Data()
        var hasAllHeaders = false
        var headersEndIdx = -1

        while !hasAllHeaders {
            var headerBuffer = ContiguousArray(repeating: UInt8(0), count: 1024)
            read = headerBuffer.withUnsafeMutableBytes {
                printDebug("[\(#fileID):\(#line)] Reading remaining data from HTTP reply")
                return Int(BIO_read(bio, $0.baseAddress, 1024))
            }
            if read == 0 {
                printError("[\(#fileID):\(#line)] No response from HTTP server")
                return .failure(.invalidData("No response"))
            }
            if headerData.count + headerBuffer.count > maxHeaderSize {
                printError("[\(#fileID):\(#line)] HTTP header data exceeded maximum length")
                return .failure(.responseError("HTTP header data exceeded maximum length"))
            }
            printDebug("[\(#fileID):\(#line)] Read \(read)B")

            let data: [UInt8] = Array(headerBuffer)

            for i in 0...data.count - 3 {
                // look for the end of headers, denoted by two linebreaks (http uses CRLF)
                if data[i] == 0x0D /* \r */
                    && data[i+1] == 0x0A /* \n */
                    && data[i+2] == 0x0D /* \r */
                    && data[i+3] == 0x0A /* \n */ {
                    headersEndIdx = i
                    hasAllHeaders = true
                    printDebug("[\(#fileID):\(#line)] Found start of HTTP body at offset \(i)")
                    break
                }
            }
            if headersEndIdx == -1 {
                headerData.append(Data(headerBuffer[0..<read]))
            } else {
                headerData.append(Data(headerBuffer[0..<headersEndIdx]))
            }
        }

        self.headerData = headerData
        let headers = HTTPHeaders.fromResponse(self.headerData)
        let serverInfo = HTTPServerInfo(headers: headers, statusCode: statusCode)
        return .success(serverInfo)
    }
}
