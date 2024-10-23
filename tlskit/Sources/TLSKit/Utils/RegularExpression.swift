// TLSKit
// Copyright (C) 2024 Ian Spence
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

internal final class RegularExpression: Sendable {
    fileprivate let patttern: NSRegularExpression

    init(_ patttern: String) {
        self.patttern = NSRegularExpression(patttern)
    }

    func replaceAllMatches(in string: String, with replace: String) -> String {
        let range = NSRange(location: 0, length: string.count)
        return patttern.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replace)
    }

    func matches(in string: String) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        return patttern.firstMatch(in: string, options: [], range: range) != nil
    }

    func firstMatch(in string: String) -> String? {
        let range = NSRange(location: 0, length: string.count)
        guard let match = patttern.firstMatch(in: string, options: [], range: range) else {
            return nil
        }

        // Bit hacky but I literally could not give less of a crap about multi-byte characters right now
        return (string as NSString).substring(with: match.range) as String
    }
}
