import Foundation

private let LIST_KEY = "RECENT_DOMAINS"

/// Class for managing recently inspected domains
class RecentLookups {
    /// Return all recently inspected domains
    public static func GetRecentLookups() -> [String] {
        guard let list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return []
        }

        return list
    }

    /// Add a new recently inspected domain. If the domain was already in the list, it is moved to index 0.
    /// - Parameter domain: The domain to add. Case insensitive.
    public static func AddLookup(_ domain: String) {
        var list: [String] = []
        if let savedList = AppDefaults.array(forKey: LIST_KEY) as? [String] {
            list = savedList
        }

        if let index = list.firstIndex(of: domain.lowercased()) {
            list.remove(at: index)
        }

        if list.count >= 5 {
            list.remove(at: 4)
        }
        list.insert(domain.lowercased(), at: 0)

        AppDefaults.set(list, forKey: LIST_KEY)
    }

    /// Remove the recently inspected domain at the specified index.
    /// - Parameter index: The index to remove.
    public static func RemoveLookup(index: Int) {
        guard var list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return
        }
        if index > list.count || index < 0 {
            return
        }
        list.remove(at: index)

        AppDefaults.set(list, forKey: LIST_KEY)
    }

    /// Remove the specified recently inspected domain.
    /// - Parameter domain: The domain to remove. Case insensitive.
    public static func RemoveLookup(domain: String) {
        guard var list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return
        }
        guard let index = IndexOfDomain(domain) else {
            return
        }
        list.remove(at: index)

        AppDefaults.set(list, forKey: LIST_KEY)
    }

    /// Remove all recently inspected domains.
    public static func RemoveAllLookups() {
        AppDefaults.set([], forKey: LIST_KEY)
    }

    /// Get the index of the specified domain. Returns nil if not found.
    /// - Parameter domain: The domain to search for. Case insenstivie.
    public static func IndexOfDomain(_ domain: String) -> Int? {
        guard let list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return nil
        }

        return list.firstIndex(of: domain.lowercased())
    }
}
