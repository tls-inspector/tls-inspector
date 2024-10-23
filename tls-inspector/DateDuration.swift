// TLS Inspector
// Copyright (C) 2024 Ian Spence
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
    private static let unitSingular: [Calendar.Component: String] = [
        .year: "year",
        .month: "month",
        .day: "day",
        .hour: "hour",
        .minute: "minute",
    ]
    private static let unitPlural: [Calendar.Component: String] = [
        .year: "years",
        .month: "months",
        .day: "days",
        .hour: "hours",
        .minute: "minutes",
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
                results.append("\(value) \(DateDuration.unitSingular[unit]!)")
            } else {
                results.append("\(value) \(DateDuration.unitPlural[unit]!)")
            }
        }

        return results.joined(separator: " ")
    }
}
