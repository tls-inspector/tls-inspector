// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
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

import UIKit
import Crashpad
import TLSKit

internal struct Telemetry {
    private let platform: String
    private let systemVersion: String
    private let appVersion: String

    @MainActor public init() {
        self.platform = EnvironmentInfo.platform()
        self.systemVersion = UIDevice.current.systemVersion
        self.appVersion = EnvironmentInfo.version()
    }

    public func inspectionRequestSuccess(engineType: EngineType, request: InspectionRequest, elapsed: UInt64) {
        let event = Event(device_type: self.platform, os_version: self.systemVersion, app_version: self.appVersion, event: "inspection_request_success", data: [
            "engine_type": String(describing: engineType),
            "check_crl": String(describing: request.checkCRL),
            "check_ocsp": String(describing: request.checkOCSP),
            "check_http": String(describing: request.checkHTTP),
            "elapsed": String(elapsed),
        ])
        Crashpad.send(event: event) { error in
            if let error = error {
                LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error submitting crashpad event: \(error)")
            } else {
                LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Submitted crashpad event 'inspection_request_success'")
            }
        }
    }

    public func inspectionRequestFailed(engineType: EngineType, request: InspectionRequest, error: Error) {
        let event = Event(device_type: self.platform, os_version: self.systemVersion, app_version: self.appVersion, event: "inspection_request_failed", data: [
            "engine_type": String(describing: engineType),
            "check_crl": String(describing: request.checkCRL),
            "check_ocsp": String(describing: request.checkOCSP),
            "check_http": String(describing: request.checkHTTP),
            "error": "\(error)"
        ])
        Crashpad.send(event: event) { error in
            if let error = error {
                LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Error submitting crashpad event: \(error)")
            } else {
                LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] Submitted crashpad event 'inspection_request_failed'")
            }
        }
    }
}
