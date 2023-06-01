import UIKit

class SupportType {
    enum RequestType: String {
        case ReportABug = "Report a Bug"
        case RequestAFeature = "Request a Feature"
        case SomethingElse = "Something Else"

        static func allValues() -> [RequestType] {
            return [
            .ReportABug,
            .RequestAFeature,
            .SomethingElse,
            ]
        }
    }

    private(set) var type: RequestType = .ReportABug
    private(set) var comments: String = ""
    private(set) var device: String = ""
    private(set) var deviceVersion: String = ""
    private(set) var appIdentifier: String = ""
    private(set) var appVersion: String = ""
    private(set) var deviceLanguage: String = ""

    init(type: RequestType, comments: String) {
        self.type = type
        self.comments = comments
        self.device = UIDevice.current.platformName()
        self.deviceVersion = UIDevice.current.systemVersion
        self.appIdentifier = AppInfo.bundleName()
        self.appVersion = AppInfo.version() + " (" + AppInfo.build() + ")"
        if Locale.preferredLanguages.count > 0 {
            self.deviceLanguage = Locale.preferredLanguages[0]
        }
    }

    public func body() -> String {
        var commentsHtml = self.comments
        commentsHtml = commentsHtml.replacingOccurrences(of: "\n", with: "<br>")

        var body = """
<p>Type: <strong>\(self.type.rawValue)</strong><br>
Device: <strong>\(self.device)</strong><br>
Device Version: <strong>\(self.deviceVersion)</strong><br>
Device Language: <strong>\(self.deviceLanguage)</strong><br>
App Identifier: <strong>\(self.appIdentifier)</strong><br>
App Version: <strong>\(self.appVersion)</strong><br>
<br><strong>Comments:</strong><br></p>
<p>\(commentsHtml)</p>
"""

        return body
    }
}
