import Foundation

class DateDuration {
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
                results.append(lang(key: "{amount} {date_unit}", args: [String(value), lang(key: "date_unit_singular::\(unit)")]))
            } else {
                results.append(lang(key: "{amount} {date_unit}", args: [String(value), lang(key: "date_unit_plural::\(unit)")]))
            }
        }

        return results.joined(separator: " ")
    }
}
