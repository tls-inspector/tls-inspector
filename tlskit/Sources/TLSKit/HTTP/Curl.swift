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

private final class DebugCallbackData {
    var writeFunc: (_: LogLevel, _: String) -> Void

    init(writeFunc: @escaping (_: LogLevel, _: String) -> Void) {
        self.writeFunc = writeFunc
    }
}

private final class WriteCallbackData {
    var data = Data()
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
        /**
         Developer note: you need to be careful and pay attetion to which values
         are copied by curl, and which are referenced. For anything that is not
         copied, i.e. a pointer, you need to ensure that swift does not release
         that pointer before curl is finished using it.
         */
        defer {
            curl_easy_cleanup(self.handle)
        }

        // Load the ca bundle if we're connecting using https
        if self.url.hasPrefix("https://") {
            guard let caBundlePath = Bundle.module.url(forResource: "apple_ca_bundle", withExtension: "pem")?.path else {
                return .failure(.internalError("CA bundle file not found"))
            }
            curl_easy_setopt_string(self.handle, CURLOPT_CAINFO, caBundlePath)
        }

        curl_easy_setopt_string(self.handle, CURLOPT_CUSTOMREQUEST, method)
        printDebug("[\(#fileID):\(#line)] HTTP \(method) \(self.url)")
        var headerCallbackData = WriteCallbackData()
        var bodyCallbackData = WriteCallbackData()
        var debugCallbackData = DebugCallbackData { l, m in
            log?.write(l, message: m)
        }

        var requestHeaders: UnsafeMutablePointer<curl_slist>?
        for (key, values) in self.headers.all() {
            for value in values {
                requestHeaders = curl_slist_append(requestHeaders, "\(key): \(value)") // curl copies the string
            }
        }
        curl_easy_setopt_slist(self.handle, CURLOPT_HTTPHEADER, requestHeaders)
        defer { curl_slist_free_all(requestHeaders) }

        curl_easy_setopt_int(self.handle, CURLOPT_MAXFILESIZE, Int32(self.maxBodySize))
        curl_easy_setopt_int(self.handle, CURLOPT_TIMEOUT, self.timeoutSeconds)
        curl_easy_setopt_string(self.handle, CURLOPT_PROTOCOLS_STR, "HTTP,HTTPS")
        curl_easy_setopt_int(self.handle, CURLOPT_FOLLOWLOCATION, self.followRedirects ? 1 : 0)
        curl_easy_setopt_int(self.handle, CURLOPT_TCP_NODELAY, 1)

        // Debug (log) Callback
        let debugCallback: curl_debug_callback = { (_, type, data, _, userdata) -> Int32 in
            if data == nil {
                printError("[\(#fileID):\(#line)] Nil data")
                return 0
            }
            guard let debugCallbackDataPointer = userdata?.assumingMemoryBound(to: DebugCallbackData.self) else {
                printError("[\(#fileID):\(#line)] Unable to cast userdata to debug callback data")
                return 0
            }
            let logLine = String(cString: data!).trimmingCharacters(in: .newlines)

            switch type {
            case CURLINFO_TEXT:
                debugCallbackDataPointer.pointee.writeFunc(.Debug, "[\(#fileID):\(#line)] [CURL]: \(logLine)")
            case CURLINFO_HEADER_OUT:
                debugCallbackDataPointer.pointee.writeFunc(.Debug, "[\(#fileID):\(#line)] [CURL]: > \(logLine)")
            case CURLINFO_HEADER_IN:
                debugCallbackDataPointer.pointee.writeFunc(.Debug, "[\(#fileID):\(#line)] [CURL]: < \(logLine)")
            default:
                break
            }
            return 0
        }
        if log?.getLevel() == .Debug {
            curl_easy_setopt_int(self.handle, CURLOPT_VERBOSE, 1)
            curl_easy_setopt_debug_function(self.handle, CURLOPT_DEBUGFUNCTION, debugCallback)
        }

        // Header Callback
        let headerCallback: curl_write_callback = { (ptr, size, nmemb, userdata) -> Int in
            let count = size * nmemb
            if let writeCallbackDataPointer = userdata?.assumingMemoryBound(to: WriteCallbackData.self) {
                let writeCallbackData = writeCallbackDataPointer.pointee
                ptr?.withMemoryRebound(to: UInt8.self, capacity: count) {
                    writeCallbackData.data.append(&$0.pointee, count: count)
                }
            }
            return count
        }
        curl_easy_setopt_write_function(self.handle, CURLOPT_HEADERFUNCTION, headerCallback)

        // Body Callback
        let bodyCallback: curl_write_callback = { (ptr, size, nmemb, userdata) -> Int in
            let count = size * nmemb
            if let writeCallbackDataPointer = userdata?.assumingMemoryBound(to: WriteCallbackData.self) {
                let writeCallbackData = writeCallbackDataPointer.pointee
                ptr?.withMemoryRebound(to: UInt8.self, capacity: count) {
                    writeCallbackData.data.append(&$0.pointee, count: count)
                }
            }
            return count
        }
        curl_easy_setopt_write_function(self.handle, CURLOPT_WRITEFUNCTION, bodyCallback)

        let rv = self.curl_do(
            debugData: &debugCallbackData,
            headerData: &headerCallbackData,
            bodyBody: &bodyCallbackData
        )

        var responseCode: Int32 = 0
        curl_easy_getinfo_int(self.handle, CURLINFO_RESPONSE_CODE, &responseCode)

        if rv != CURLE_OK {
            guard let error = curl_easy_strerror(rv) else {
                return .failure(.internalError("Unknown libcurl error"))
            }
            let r = String(cString: error)
            printError("[\(#fileID):\(#line)] CURL error \(r)")
            return .failure(.internalError(r))
        }

        guard let allHeaders = String(data: headerCallbackData.data, encoding: .utf8) else {
            return .failure(.invalidData("Unrecognized HTTP headers"))
        }

        let headers = HTTPHeaders.fromLines(allHeaders.split(separator: "\r\n"))

        return .success(CurlResponse(statusCode: responseCode, headers: headers, body: bodyCallbackData.data))
    }

    // Break out this into a dedicated function to avoid needing to do a nest of withUnsafeMutablePointer
    private func curl_do(
        debugData: UnsafeMutablePointer<DebugCallbackData>,
        headerData: UnsafeMutablePointer<WriteCallbackData>,
        bodyBody: UnsafeMutablePointer<WriteCallbackData>
    ) -> CURLcode {
        curl_easy_setopt_pointer(self.handle, CURLOPT_DEBUGDATA, debugData)
        curl_easy_setopt_pointer(self.handle, CURLOPT_HEADERDATA, headerData)
        curl_easy_setopt_pointer(self.handle, CURLOPT_WRITEDATA, bodyBody)
        return curl_easy_perform(self.handle)
    }
}
