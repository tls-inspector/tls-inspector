import Foundation

class MigrateAssistant {
    private static let appVersionKey = "last_launched_version"

    static func AppLaunch() {
        var lastLaunchedVersion = AppInfo.version()
        if let lastVersion = AppDefaults.string(forKey: appVersionKey) {
            lastLaunchedVersion = lastVersion
        }
        AppDefaults.set(AppInfo.version(), forKey: appVersionKey)

        if lastLaunchedVersion == AppInfo.version() {
            return
        }

        // Do any migration here, keep things idempotent

        print("Migration completed successfully")
    }
}
