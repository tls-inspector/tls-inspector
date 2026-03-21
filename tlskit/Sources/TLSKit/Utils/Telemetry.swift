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

import UIKit
import Crashpad

public struct Telemetry: Sendable {
    private let source: String
    private let platform: String
    private let systemVersion: String
    private let appVersion: String
    private let appBuild: String

    @MainActor public init() {
        self.source = Bundle.main.bundleIdentifier ?? "Unknown"
        self.systemVersion = UIDevice.current.systemVersion
        self.appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "Unknown"
        self.appBuild = (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? "Unknown"

        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)

        let machineString = machine.withUnsafeBufferPointer {
            $0.baseAddress.map { String(cString: $0) }
        }
        self.platform = machineString ?? "Unknown"
    }

    public func inspectionRequestSuccess(engineType: EngineType, request: InspectionRequest, elapsed: UInt64) {
        let event = Event(device_type: self.platform, os_version: self.systemVersion, app_version: self.appVersion, event: "inspection_request_success", data: [
            "target": request.address,
            "engine_type": String(describing: engineType),
            "check_crl": String(describing: request.checkCRL),
            "check_ocsp": String(describing: request.checkOCSP),
            "check_http": String(describing: request.checkHTTP),
            "elapsed": String(elapsed),
            "source": source,
        ])
        Crashpad.send(event: event) { error in
            if let error = error {
                printError("[\(#fileID):\(#line)] Error submitting crashpad event: \(error)")
            } else {
                printError("[\(#fileID):\(#line)] Submitted crashpad event 'inspection_request_success'")
            }
        }
    }

    public func inspectionRequestFailed(engineType: EngineType, request: InspectionRequest, error: Error) {
        let event = Event(device_type: self.platform, os_version: self.systemVersion, app_version: self.appVersion, event: "inspection_request_failed", data: [
            "target": request.address,
            "engine_type": String(describing: engineType),
            "check_crl": String(describing: request.checkCRL),
            "check_ocsp": String(describing: request.checkOCSP),
            "check_http": String(describing: request.checkHTTP),
            "error": "\(error)",
            "source": source,
        ])
        Crashpad.send(event: event) { error in
            if let error = error {
                printError("[\(#fileID):\(#line)] Error submitting crashpad event: \(error)")
            } else {
                printError("[\(#fileID):\(#line)] Submitted crashpad event 'inspection_request_failed'")
            }
        }
    }

    public func httpInspectionFailed(request: InspectionRequest, error: Error) {
        let event = Event(device_type: self.platform, os_version: self.systemVersion, app_version: self.appVersion, event: "http_inspection_request_failed", data: [
            "target": request.address,
            "error": "\(error)",
            "source": source,
        ])
        Crashpad.send(event: event) { error in
            if let error = error {
                printError("[\(#fileID):\(#line)] Error submitting crashpad event: \(error)")
            } else {
                printError("[\(#fileID):\(#line)] Submitted crashpad event 'http_inspection_request_failed'")
            }
        }
    }
}
