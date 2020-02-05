import Foundation

/// Class for getting meta information about the app
class AppInfo {
    /// Get the current version of the app
    static func version() -> String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "Unknown"
    }

    /// Get the current build number of the app
    static func build() -> String {
        return (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? "Unknown"
    }

    /// Get the bundle identifer of the app
    static func bundleName() -> String {
        return Bundle.main.bundleIdentifier ?? "Unknown"
    }
}
