import UIKit
import CertificateKit

private let LIST_KEY = "RECENT_DOMAINS"

/// Class for managing recently inspected domains
class RecentLookups {
    /// Return all recently inspected domains
    public static func GetRecentLookups() -> [CKInspectParameters] {
        guard let list = AppDefaults.array(forKey: LIST_KEY) as? [[String: Any]] else {
            return []
        }

        var lookups: [CKInspectParameters] = []
        for (i, l) in list.enumerated() {
            guard let parameters = CKInspectParameters.fromDictionary(l) else {
                RemoveLookup(index: i)
                continue
            }
            lookups.append(parameters)
        }

        return lookups
    }

    /// Add a new recently inspected domain. If the domain was already in the list, it is moved to index 0.
    public static func Add(_ parameters: CKInspectParameters) {
        let dict = parameters.dictionaryValue()
        var list = AppDefaults.array(forKey: LIST_KEY) as? [[String: Any]] ?? []

        var index = -1
        for (i, d) in list.enumerated() {
            guard let p = CKInspectParameters.fromDictionary(d) else {
                continue
            }
            if p.isEqual(parameters) {
                index = i
                break
            }
        }
        if index >= 0 {
            list.remove(at: index)
        }

        if list.count >= 5 {
            list.remove(at: 4)
        }

        list.insert(dict, at: 0)
        AppDefaults.setValue(list, forKey: LIST_KEY)
    }

    /// Remove the recently inspected domain at the specified index.
    /// - Parameter index: The index to remove.
    public static func RemoveLookup(index: Int) {
        guard var list = AppDefaults.array(forKey: LIST_KEY) as? [[String: Any]] else { return }
        if index > list.count || index < 0 {
            return
        }
        list.remove(at: index)
        AppDefaults.set(list, forKey: LIST_KEY)
    }

    /// Remove all recently inspected domains.
    public static func RemoveAllLookups() {
        let lookups: [String] = []
        AppDefaults.set(lookups, forKey: LIST_KEY)
    }
}
