import Foundation

private let LIST_KEY = "RECENT_DOMAINS"

class RecentLookups {
    public static func GetRecentLookups() -> [String] {
        guard let list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return []
        }

        return list
    }

    public static func AddLookup(query: String) {
        var list: [String] = []
        if let savedList = AppDefaults.array(forKey: LIST_KEY) as? [String] {
            list = savedList
        }

        if let index = list.firstIndex(of: query) {
            list.remove(at: index)
        }

        if list.count >= 5 {
            list.remove(at: 4)
        }
        list.insert(query, at: 0)

        AppDefaults.set(list, forKey: LIST_KEY)
    }

    public static func RemoveLookup(index: Int) {
        guard var list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return
        }
        list.remove(at: index)

        AppDefaults.set(list, forKey: LIST_KEY)
    }

    public static func RemoveAllLookups() {
        AppDefaults.set([], forKey: LIST_KEY)
    }
}
