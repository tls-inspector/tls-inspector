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

@MainActor
internal class DateDuration {
    private static let unitSingular: [Calendar.Component: () -> String] = [
        .year: { return Localize.n1year() },
        .month: { return Localize.n1month() },
        .day: { return Localize.n1day() },
        .hour: { return Localize.n1hour() },
        .minute: { return Localize.n1minute() },
    ]
    private static let unitPlural: [Calendar.Component: (String) -> String] = [
        .year: { v in return Localize.numberyears(number: v) },
        .month: { v in return Localize.numbermonths(number: v) },
        .day: { v in return Localize.numberdays(number: v) },
        .hour: { v in return Localize.numberhours(number: v) },
        .minute: { v in return Localize.numberminutes(number: v) },
    ]

    static func between(first: Date, second: Date) -> String {
        var units: [Calendar.Component] = [.year, .month, .day, .hour, .minute]
        if second.timeIntervalSince(first) > 2629800 {
            units = [.year, .month, .day]
        }

        let components = Calendar.current.dateComponents(Set(units), from: first, to: second)

        var results: [String] = []
        for unit in units {
            guard let value = components.value(for: unit) else {
                continue
            }
            if value == 0 {
                continue
            }
            if value == 1 {
                results.append((DateDuration.unitSingular[unit]!)())
            } else {
                results.append((DateDuration.unitPlural[unit]!)(String(format: "%i", arguments: [value])))
            }
        }

        return results.joined(separator: " ")
    }
}
