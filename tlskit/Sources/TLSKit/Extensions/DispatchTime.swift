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

internal extension DispatchTime {
    func adding(seconds: UInt8) -> DispatchTime {
        if #available(iOS 13, macOS 10.15, *) {
            return DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(Int(seconds)))
        } else {
            let timeout = DispatchTime.now().uptimeNanoseconds + UInt64(seconds) * NSEC_PER_SEC
            return DispatchTime(uptimeNanoseconds: timeout)
        }
    }
}
