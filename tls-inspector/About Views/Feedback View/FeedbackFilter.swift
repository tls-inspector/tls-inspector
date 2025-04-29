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

import Foundation

internal enum FeedbackFilterResult {
    case pass
    case warn
    case reject
}

@MainActor
internal class FeedbackFilter {
    // A core value of TLS Inspector is that it should be easy to get in touch with the development team.
    // This, however, comes at the cost of exposing that team to the potential for abuse from malicious users.
    // This class contains a basic set of keywords that either reject a message, or attempts to dissuade a user
    // from reaching out.
    //
    // The objective is both to protect the development team from abuse, as well as educate users on the limitations
    // of TLS Inspector - in that it does not protect them from direct malicious threats.
    private static let rejectWords: Set<Data> = [
        Data([0x66, 0x75, 0x63, 0x6b]),
        Data([0x73, 0x68, 0x69, 0x74]),
        Data([0x6e, 0x69, 0x67, 0x67, 0x65, 0x72]),
        Data([0x63, 0x75, 0x6e, 0x74]),
    ]
    private static let warnWords: Set<Data> = [
        Data([0x61, 0x75, 0x74, 0x68, 0x6F, 0x72, 0x69, 0x7A, 0x65, 0x64]),
        Data([0x62, 0x6C, 0x6F, 0x63, 0x6B]),
        Data([0x68, 0x61, 0x63, 0x6B]),
        Data([0x62, 0x72, 0x65, 0x61, 0x63, 0x68]),
        Data([0x73, 0x74, 0x6F, 0x6C, 0x65]),
        Data([0x70, 0x61, 0x73, 0x73, 0x77, 0x6F, 0x72, 0x64]),
    ]

    internal static func evalulate(_ message: String) -> FeedbackFilterResult {
        for binword in rejectWords {
            let word = String(data: binword, encoding: .utf8)!
            if message.lowercased().contains(word + " ") || message.lowercased().contains(" " + word) {
                return .reject
            }
        }
        for binword in warnWords {
            let word = String(data: binword, encoding: .utf8)!
            if message.lowercased().contains(word + " ") || message.lowercased().contains(" " + word) {
                return .warn
            }
        }
        return .pass
    }
}
