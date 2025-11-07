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

import TLSKit
import SwiftUI

public let closedInspectionViewNotification = Notification.Name(rawValue: "inspection.view.closed")

internal nonisolated(unsafe) var LogWriter: ILogger!
internal nonisolated(unsafe) var UserOptions: IOptions!

/// Prepares the TLSUI package for use in an app or extension. This must be called exactly once and before any of the views of this package are displayed.
/// - Parameters:
///   - logger: The logging interface
///   - userOptions: The options provider
public func setup(logger: ILogger, userOptions: IOptions) {
    LogWriter = logger
    UserOptions = userOptions
}
