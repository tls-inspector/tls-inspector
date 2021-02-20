import UIKit
import CertificateKit

private let LIST_KEY = "RECENT_DOMAINS"

struct Lookup {
    var Host: URL
    var Address: String
    var IPversion: IPVersion

    static func decode(_ lookupstr: String) -> Lookup? {
        let parts = lookupstr.components(separatedBy: ",")
        if parts.count != 3 {
            return nil
        }
        guard let host = URL.fromString(str: parts[0]) else {
            return nil
        }
        guard let version = IPVersion.init(rawValue: parts[2]) else {
            return nil
        }

        return Lookup(Host: host, Address: parts[1], IPversion: version)
    }

    func encode() -> String {
        let versionStr = self.IPversion.rawValue
        return "\(self.Host.absoluteURL),\(self.Address),\(versionStr)".lowercased()
    }

    func toString() -> String {
        var port = 443
        if let urlPort = self.Host.port {
            port = urlPort
        }

        var domain = self.Host.host ?? ""
        if port != 443 {
            domain += ":\(port)"
        }

        if self.Address != "" || self.IPversion != .Automatic {
            domain += "*"
        }

        return domain
    }

    func parameters() -> CKGetterParameters {
        let parameters = CKGetterParameters()
        parameters.queryURL = self.Host
        if self.Address != "" {
            parameters.ipAddress = self.Address
        }
        switch self.IPversion {
        case .Automatic:
            break
        case .IPv4:
            parameters.ipVersion = IP_VERSION_IPV4
        case .IPv6:
            parameters.ipVersion = IP_VERSION_IPV6
        }

        return parameters
    }
}

/// Class for managing recently inspected domains
class RecentLookups {
    /// Return all recently inspected domains
    public static func GetRecentLookups() -> [Lookup] {
        guard let list = AppDefaults.array(forKey: LIST_KEY) as? [String] else {
            return []
        }

        var lookups: [Lookup] = []
        for entry in list {
            guard let lookup = Lookup.decode(entry) else {
                continue
            }
            lookups.append(lookup)
        }

        return lookups
    }

    /// Add a new recently inspected domain. If the domain was already in the list, it is moved to index 0.
    /// - Parameter domain: The domain to add. Case insensitive.
    public static func Add(_ lookup: Lookup) {
        var list: [String] = []
        if let savedList = AppDefaults.array(forKey: LIST_KEY) as? [String] {
            list = savedList
        }

        if lookup.Host.host == nil {
            LogError("Unable to add host to lookup list as URL is nil")
            return
        }

        let lookupStr = lookup.encode()

        if let index = list.firstIndex(of: lookupStr) {
            list.remove(at: index)
        }

        if list.count >= 5 {
            list.remove(at: 4)
        }
        LogDebug("Adding query '\(lookupStr)' to recent lookup list")
        list.insert(lookupStr, at: 0)

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

    /// Remove all recently inspected domains.
    public static func RemoveAllLookups() {
        AppDefaults.set([], forKey: LIST_KEY)
    }
}
