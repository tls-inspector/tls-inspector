import UIKit

class RandomDomainName {
    private static var placeholderDomains: [String]?

    private static func loadDomains() {
        guard let domainListPath = Bundle.main.path(forResource: "DomainList", ofType: "plist") else {
            return
        }
        guard let domains = NSArray.init(contentsOfFile: domainListPath) as? [String] else {
            return
        }

        RandomDomainName.placeholderDomains = domains
    }


    /// Get a random domain name. Will lazily load the domain list on first call.
    /// - Returns: A domain name. Will always return a domain name, even if the list fails to load.
    public static func get() -> String? {
        objc_sync_enter(self)
        if placeholderDomains == nil {
            RandomDomainName.loadDomains()
        }
        objc_sync_exit(self)

        return placeholderDomains?.randomElement() ?? "tlsinspector.com"
    }
}
