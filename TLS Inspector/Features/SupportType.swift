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

    init(type: RequestType, comments: String) {
        self.type = type
        self.comments = comments
        self.device = UIDevice.current.platformName()
        self.deviceVersion = UIDevice.current.systemVersion

        if let bundleName = Bundle.main.bundleIdentifier {
            self.appIdentifier = bundleName
        }

        if let infoDict = Bundle.main.infoDictionary {
            let bundleVersion = infoDict["CFBundleShortVersionString"] as? String
            let build = infoDict["CFBundleVersion"] as? NSNumber
            let bundleBuild = build?.stringValue
            self.appVersion = (bundleVersion ?? "Unknown") + " (" + (bundleBuild ?? "Unknown") + ")"
        }
    }

    public func body() -> String {
        var body = ""
        body += "<p>Type: <strong>" + self.type.rawValue + "</strong><br>"
        body += "Device: <strong>" + self.device + "</strong><br>"
        body += "Device Version: <strong>" + self.deviceVersion + "</strong><br>"
        body += "App Identifier: <strong>" + self.appIdentifier + "</strong><br>"
        body += "App Version: <strong>" + self.appVersion + "</strong><br>"
        body += "Comments:<br></p>"
        body += "<p>" + self.comments + "</p>"
        return body
    }
}
