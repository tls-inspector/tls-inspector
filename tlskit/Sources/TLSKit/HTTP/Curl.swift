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

import Curl
import Foundation

private final class DebugCallbackReciever {
    var writeFunc: (_: LogLevel, _: String) -> Void

    init(writeFunc: @escaping (_: LogLevel, _: String) -> Void) {
        self.writeFunc = writeFunc
    }
}

/// Describes the response from a curl request
internal struct CurlResponse {
    /// The HTTP status code
    let statusCode: Int32
    /// The HTTP response headers
    let headers: HTTPHeaders
    /// The HTTP response body
    let body: Data
}

/// The curl client. Do not re-use clients, instead create one client per request.
@preconcurrency
internal final class CurlClient {
    /// Optional request headers to be added when sending the request
    internal var headers = HTTPHeaders()
    /// Optional request body
    internal var body: Data?
    /// The maximum body size of a response. Defaults to 32MiB.
    internal var maxBodySize: Int32 = 33_554_432
    /// The maximum number of seconds to wait before failing
    internal var timeoutSeconds: Int32 = 5
    /// If HTTP redirections should be followed
    internal var followRedirects: Bool = false
    /// The URL of this handle.
    internal let url: String

    private var handle: UnsafeMutableRawPointer

    init(url: String) throws {
        printDebug("[\(#fileID):\(#line)] curl_global_init: \(url)")

        curl_global_init(Int(CURL_GLOBAL_DEFAULT))
        guard let curl = curl_easy_init() else {
            throw TLSKitError.internalError("curl_easy_init returned nil")
        }

        let userAgent = "TLSKit" + (UserAgentSuffix != nil ? " \(UserAgentSuffix!)" : "")

        curl_easy_setopt_string(curl, CURLOPT_URL, url)
        curl_easy_setopt_string(curl, CURLOPT_USERAGENT, userAgent)
        curl_easy_setopt_int(curl, CURLOPT_FORBID_REUSE, 1)

        self.url = url
        self.handle = curl
    }

    /// Send an HTTP GET request to the URL
    /// - Returns: The result, with the status code, headers, and body or an error
    func get() -> Result<CurlResponse, TLSKitError> {
        if self.body != nil {
            printError("[\(#fileID):\(#line)] HTTP body defined but sending HTTP GET request")
        }
        return send("GET")
    }

    /// Send an HTTP GET request to the URL and save the body to destination
    /// - Parameter destination: The destination path to write the body to
    /// - Returns: The size of the file
    func downloadFile(_ destination: URL) throws -> Int {
        let result: CurlResponse
        switch self.get() {
        case .success(let data):
            result = data
        case .failure(let error):
            throw error
        }

        if result.statusCode != 200 {
            throw TLSKitError.httpError(Int(result.statusCode))
        }

        try result.body.write(to: destination)
        return result.body.count
    }

    /// Send an HTTP POST request to the URL
    /// - Returns: The result, with the status code, headers, and body or an error
    func post() -> Result<CurlResponse, TLSKitError> {
        if let data = self.body {
            curl_easy_setopt_string(self.handle, CURLOPT_POSTFIELDS, (data as NSData).bytes)
            curl_easy_setopt_int(self.handle, CURLOPT_POSTFIELDSIZE, Int32(data.count))
        }
        return send("POST")
    }

    /// Send an HTTP PUT request to the URL
    /// - Returns: The result, with the status code, headers, and body or an error
    func put() -> Result<CurlResponse, TLSKitError> {
        if let data = self.body {
            curl_easy_setopt_string(self.handle, CURLOPT_POSTFIELDS, (data as NSData).bytes)
            curl_easy_setopt_int(self.handle, CURLOPT_POSTFIELDSIZE, Int32(data.count))
        }
        return send("PUT")
    }

    /// Act on the curl request
    private func send(_ method: String) -> Result<CurlResponse, TLSKitError> {
        printDebug("[\(#fileID):\(#line)] send: \(method)")

        defer {
            printDebug("[\(#fileID):\(#line)] curl_easy_cleanup >")
            curl_easy_cleanup(self.handle)
            printDebug("[\(#fileID):\(#line)] curl_easy_cleanup <")
        }

        // Load the ca bundle if we're connecting using https
        if self.url.hasPrefix("https://") {
            printDebug("[\(#fileID):\(#line)] https URL detected, loading apple_ca_bundle")
            guard let caBundlePath = Bundle.module.url(forResource: "apple_ca_bundle", withExtension: "pem")?.path else {
                printError("[\(#fileID):\(#line)] Unable to load CA bundle")
                return .failure(.internalError("CA bundle file not found"))
            }
            curl_easy_setopt_string(self.handle, CURLOPT_CAINFO, caBundlePath)
            printDebug("[\(#fileID):\(#line)] CA bundle loaded")
        }

        curl_easy_setopt_string(self.handle, CURLOPT_CUSTOMREQUEST, method)

        // Note: the use of NSMutableData here is intentional. Because we're passing references to these two buffers to
        // libcurl (a c library) we must be using a Swift class type. The Swift Data type is a struct, which cannot be passed.
        var headerData = NSMutableData()
        var bodyData = NSMutableData()

        // Similarly, we need to pass a class that lets us capture debug events from libcurl, so the DebugCallbackReciever class
        // is used to bridge that gap.
        var debugCallbackReciever = DebugCallbackReciever { l, m in
            log?.write(l, message: m)
        }

        var requestHeaders: UnsafeMutablePointer<curl_slist>?
        for (key, values) in self.headers.all() {
            for value in values {
                requestHeaders = curl_slist_append(requestHeaders, "\(key): \(value)") // curl copies the string
                printDebug("[\(#fileID):\(#line)] set header \(key): \(value)")
            }
        }
        curl_easy_setopt_slist(self.handle, CURLOPT_HTTPHEADER, requestHeaders)
        defer {
            printDebug("[\(#fileID):\(#line)] curl_slist_free_all >")
            curl_slist_free_all(requestHeaders)
            printDebug("[\(#fileID):\(#line)] curl_slist_free_all <")
        }

        curl_easy_setopt_int(self.handle, CURLOPT_MAXFILESIZE, Int32(self.maxBodySize))
        curl_easy_setopt_int(self.handle, CURLOPT_TIMEOUT, self.timeoutSeconds)
        curl_easy_setopt_string(self.handle, CURLOPT_PROTOCOLS_STR, "HTTP,HTTPS")
        curl_easy_setopt_int(self.handle, CURLOPT_FOLLOWLOCATION, self.followRedirects ? 1 : 0)
        curl_easy_setopt_int(self.handle, CURLOPT_TCP_NODELAY, 1)

        // Debug callback, takes in debug events from curl to capture them by our logger. Only used
        // if the log level is debug.
        let debugCallback: curl_debug_callback = { (_, type, data, _, userdata) -> Int32 in
            if data == nil {
                printError("[\(#fileID):\(#line)] Nil data")
                return 0
            }
            guard let recieverPtr = userdata?.assumingMemoryBound(to: DebugCallbackReciever.self) else {
                printError("[\(#fileID):\(#line)] Unable to cast userdata to debug callback reciever")
                return 0
            }
            let logLine = String(cString: data!).trimmingCharacters(in: .newlines)

            switch type {
            case CURLINFO_TEXT:
                recieverPtr.pointee.writeFunc(.Debug, "[\(#fileID):\(#line)] [CURL]: \(logLine)")
            case CURLINFO_HEADER_OUT:
                recieverPtr.pointee.writeFunc(.Debug, "[\(#fileID):\(#line)] [CURL]: > \(logLine)")
            case CURLINFO_HEADER_IN:
                recieverPtr.pointee.writeFunc(.Debug, "[\(#fileID):\(#line)] [CURL]: < \(logLine)")
            default:
                break
            }
            return 0
        }
        if log?.getLevel() == .Debug {
            curl_easy_setopt_int(self.handle, CURLOPT_VERBOSE, 1)
            curl_easy_setopt_debug_function(self.handle, CURLOPT_DEBUGFUNCTION, debugCallback)
        }

        // Header callback, repeatedly called by curl with chunks of header data. Writes to a NSMutableData.
        let headerCallback: curl_write_callback = { (ptr, size, nmemb, userdata) -> Int in
            let count = size * nmemb
            guard let headerData = userdata?.assumingMemoryBound(to: NSMutableData.self) else {
                return count
            }

            headerData.pointee.append(ptr!, length: count)
            return count
        }
        curl_easy_setopt_write_function(self.handle, CURLOPT_HEADERFUNCTION, headerCallback)

        // Body callbacks, repeatedly called by curl with chunks of body data. Writes to a NSMutableData.
        let bodyCallback: curl_write_callback = { (ptr, size, nmemb, userdata) -> Int in
            let count = size * nmemb
            guard let bodyData = userdata?.assumingMemoryBound(to: NSMutableData.self) else {
                return count
            }

            bodyData.pointee.append(ptr!, length: count)
            return count
        }
        curl_easy_setopt_write_function(self.handle, CURLOPT_WRITEFUNCTION, bodyCallback)

        // It's ugly as sin, but this is genuinly the best way to go about passing these pointers to curl without
        // Swift cleaning them up before we're done with them. Trust me, I spent hours fighing with this. If there was
        // a way to do this cleaner, believe me, I'd have done it.
        return withUnsafeMutablePointer(to: &debugCallbackReciever) { debugCallbackRecieverPtr in
            return withUnsafeMutablePointer(to: &headerData) { headerDataPtr in
                return withUnsafeMutablePointer(to: &bodyData) { bodyDataPtr in
                    printDebug("[\(#fileID):\(#line)] curl_do")
                    curl_easy_setopt_pointer(self.handle, CURLOPT_DEBUGDATA, debugCallbackRecieverPtr)
                    curl_easy_setopt_pointer(self.handle, CURLOPT_HEADERDATA, headerDataPtr)
                    curl_easy_setopt_pointer(self.handle, CURLOPT_WRITEDATA, bodyDataPtr)
                    let rv = curl_easy_perform(self.handle)
                    printDebug("[\(#fileID):\(#line)] curl_do = \(rv)")

                    if rv != CURLE_OK {
                        guard let error = curl_easy_strerror(rv) else {
                            return .failure(.internalError("Unknown libcurl error"))
                        }
                        let r = String(cString: error)
                        printError("[\(#fileID):\(#line)] CURL error \(r)")
                        return .failure(.internalError(r))
                    }

                    var responseCode: Int32 = 0
                    curl_easy_getinfo_int(self.handle, CURLINFO_RESPONSE_CODE, &responseCode)
                    printDebug("[\(#fileID):\(#line)] HTTP \(responseCode)")

                    if headerDataPtr.pointee.isEmpty {
                        printError("[\(#fileID):\(#line)] Empty header data")
                        return .failure(.invalidData("Empty HTTP headers"))
                    }

                    if bodyDataPtr.pointee.isEmpty {
                        printError("[\(#fileID):\(#line)] Empty body data")
                        return .failure(.invalidData("Empty HTTP body"))
                    }

                    guard let allHeaders = String.from(data: headerDataPtr.pointee as Data) else {
                        printError("[\(#fileID):\(#line)] Unable to parse HTTP header data as a UTF8 string")
                        return .failure(.invalidData("Unrecognized HTTP headers"))
                    }

                    printDebug("[\(#fileID):\(#line)] Going to parse \(headerDataPtr.pointee.count) bytes of headers")
                    let headers = HTTPHeaders.fromLines(allHeaders.split(separator: "\r\n"))
                    printDebug("[\(#fileID):\(#line)] Got \(headers.all().count) HTTP headers")

                    return .success(CurlResponse(statusCode: responseCode, headers: headers, body: Data(bodyDataPtr.pointee)))
                }
            }
        }
    }
}
