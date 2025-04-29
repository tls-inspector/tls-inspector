// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

/// Class for getting meta information about the app
@MainActor
public struct EnvironmentInfo {
    public static func feedbackBodyHtml(withMessage message: String) -> String {
        return "<p><b>App Version: \(version()) (\(build()))</b><br/><b>Device: \(platformName())</b></p><hr/><p>\(message)</p>"
    }

    /// Get the current version of the app
    public static func version() -> String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "Unknown"
    }

    /// Get the current build number of the app
    public static func build() -> String {
        return (Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ?? "Unknown"
    }

    /// Get the bundle identifer of the app
    public static func bundleName() -> String {
        return Bundle.main.bundleIdentifier ?? "Unknown"
    }

    /// Get the platform identifier, example "iPhone15,5"
    public static func platform() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)

        let machineString = machine.withUnsafeBufferPointer {
            $0.baseAddress.map { String(cString: $0) }
        }
        return machineString ?? "Unknown"
    }

    /// Get a friendly name of the platform, or the platform identifier if not found.
    public static func platformName() -> String {
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                return "Apple Silicon-based Macintosh"
            }
        }

        let platform = self.platform()

        // https://theapplewiki.com/wiki/Models
        let mapping = [
            // Apple TV
            "AppleTV2,1":  "Apple TV Gen. 2",
            "AppleTV3,1":  "Apple TV Gen. 3",
            "AppleTV3,2":  "Apple TV Gen. 3 (Rev 2)",
            "AppleTV5,3":  "Apple TV Gen. 4",
            "AppleTV6,2":  "Apple TV 4K",
            "AppleTV11,1": "Apple TV 4K Gen. 2",
            "AppleTV14,1": "Apple TV 4K Gen. 3",

            // iPhone
            "iPhone1,1": "iPhone",
            "iPhone1,2": "iPhone 3G",
            "iPhone2,1": "iPhone 3GS",
            "iPhone3,1": "iPhone 4",
            "iPhone3,3": "Verizon iPhone 4",
            "iPhone4,1": "iPhone 4S",
            "iPhone5,1": "iPhone 5 (GSM)",
            "iPhone5,2": "iPhone 5 (GSM+CDMA)",
            "iPhone5,3": "iPhone 5c (GSM)",
            "iPhone5,4": "iPhone 5c (GSM+CDMA)",
            "iPhone6,1": "iPhone 5s (GSM)",
            "iPhone6,2": "iPhone 5s (GSM+CDMA)",
            "iPhone7,1": "iPhone 6 Plus",
            "iPhone7,2": "iPhone 6",
            "iPhone8,1": "iPhone 6s",
            "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE",
            "iPhone9,1": "iPhone 7",
            "iPhone9,3": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone9,4": "iPhone 7 Plus",
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,6": "iPhone XS Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE Gen. 2",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,6": "iPhone SE Gen. 3",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,5": "iPhone 16e",

            // iPod Touch
            "iPod1,1": "iPod Touch Gen. 1",
            "iPod2,1": "iPod Touch Gen. 2",
            "iPod3,1": "iPod Touch Gen. 3",
            "iPod4,1": "iPod Touch Gen. 4",
            "iPod5,1": "iPod Touch Gen. 5",
            "iPod7,1": "iPod Touch Gen. 6",
            "iPod9,1": "iPod Touch Gen. 7",

            // iPad
            "iPad1,1": "iPad",
            "iPad2,1": "iPad 2 (WiFi)",
            "iPad2,2": "iPad 2 (GSM)",
            "iPad2,3": "iPad 2 (CDMA)",
            "iPad2,4": "iPad 2 (WiFi)",
            "iPad3,1": "iPad 3 (WiFi)",
            "iPad3,2": "iPad 3 (GSM+CDMA)",
            "iPad3,3": "iPad 3 (GSM)",
            "iPad3,4": "iPad 4 (WiFi)",
            "iPad3,5": "iPad 4 (GSM)",
            "iPad3,6": "iPad 4 (GSM+CDMA)",
            "iPad6,11": "iPad 5 (WiFi)",
            "iPad6,12": "iPad 5 (Cellular)",
            "iPad7,5": "iPad 6 (WiFi)",
            "iPad7,6": "iPad 6 (Cellular)",
            "iPad7,11": "iPad 7 (WiFi)",
            "iPad7,12": "iPad 7 (Cellular)",
            "iPad11,6": "iPad 8 (WiFi)",
            "iPad11,7": "iPad 8 (Cellular)",
            "iPad12,1": "iPad 9 (WiFi)",
            "iPad12,2": "iPad 9 (Cellular)",
            "iPad13,18": "iPad 10 (WiFi)",
            "iPad13,19": "iPad 10 (Cellular)",
            "iPad15,7": "iPad A16 (WiFi)",
            "iPad15,8": "iPad A16 (Cellular)",

            // iPad Mini
            "iPad2,5": "iPad Mini (WiFi)",
            "iPad2,6": "iPad Mini (GSM)",
            "iPad2,7": "iPad Mini (GSM+CDMA)",
            "iPad4,4": "iPad Mini Gen. 2 (WiFi)",
            "iPad4,5": "iPad Mini Gen. 2 (Cellular)",
            "iPad4,6": "iPad Mini Gen. 2 (Cellular - China)",
            "iPad4,7": "iPad Mini Gen. 3 (WiFi)",
            "iPad4,8": "iPad Mini Gen. 3 (Cellular)",
            "iPad4,9": "iPad Mini Gen. 3 (Cellular - China)",
            "iPad5,1": "iPad Mini Gen. 4 (WiFi)",
            "iPad5,2": "iPad Mini Gen. 4 (Cellular)",
            "iPad11,1": "iPad Mini Gen. 5 (WiFi)",
            "iPad11,2": "iPad Mini Gen. 5 (Cellular)",
            "iPad14,1": "iPad Mini Gen. 6 (WiFi)",
            "iPad14,2": "iPad Mini Gen. 6 (Cellular)",
            "iPad16,1": "iPad Mini A17 Pro (WiFi)",
            "iPad16,2": "iPad Mini A17 Pro (Cellular)",

            // iPad Air
            "iPad4,1": "iPad Air (WiFi)",
            "iPad4,2": "iPad Air (Cellular)",
            "iPad4,3": "iPad Air (Cellular - China)",
            "iPad5,3": "iPad Air Gen. 2 (WiFi)",
            "iPad5,4": "iPad Air Gen. 2 (Cellular)",
            "iPad11,3": "iPad Air Gen. 3 (WiFi)",
            "iPad11,4": "iPad Air Gen. 3 (Cellular)",
            "iPad13,1": "iPad Air Gen. 4 (WiFi)",
            "iPad13,2": "iPad Air Gen. 4 (Cellular)",
            "iPad13,16": "iPad Air Gen. 5 (WiFi)",
            "iPad13,17": "iPad Air Gen. 5 (Cellular)",
            "iPad14,8": "iPad Air (11\" M2 WiFi)",
            "iPad14,9": "iPad Air (11\" M2 Cellular)",
            "iPad14,10": "iPad Air (13\" M2 WiFi)",
            "iPad14,11": "iPad Air (13\" M2 Cellular)",
            "iPad15,3": "iPad Air (11\" M3 WiFi)",
            "iPad15,4": "iPad Air (11\" M3 Cellular)",
            "iPad15,5": "iPad Air (13\" M3 WiFi)",
            "iPad15,6": "iPad Air (13\" M3 Cellular)",

            // iPad Pro
            "iPad6,7": "iPad Pro (12.9\" WiFi)",
            "iPad6,8": "iPad Pro (12.9\" Cellular)",
            "iPad6,3": "iPad Pro (9.7\" WiFi)",
            "iPad6,4": "iPad Pro (9.7\" Cellular)",
            "iPad7,3": "iPad Pro (10.5\" WiFi)",
            "iPad7,4": "iPad Pro (10.5\" Cellular)",
            "iPad8,1": "iPad Pro (11\" WiFi)",
            "iPad8,2": "iPad Pro (11\" WiFi)",
            "iPad8,3": "iPad Pro (11\" Cellular)",
            "iPad8,4": "iPad Pro (11\" Cellular)",
            "iPad8,5": "iPad Pro (12.9\" Gen. 2 WiFi)",
            "iPad8,6": "iPad Pro (12.9\" Gen. 2 WiFi)",
            "iPad8,7": "iPad Pro (12.9\" Gen. 2 Cellular)",
            "iPad8,8": "iPad Pro (12.9\" Gen. 2 Cellular)",
            "iPad8,9": "iPad Pro (11\" Gen. 2 WiFi)",
            "iPad8,10": "iPad Pro (11\" Gen. 2 Cellular)",
            "iPad8,11": "iPad Pro (12.9\" Gen. 4 WiFi)",
            "iPad8,12": "iPad Pro (12.9\" Gen. 4 Cellular)",
            "iPad13,4": "iPad Pro (11\" Gen. 3 WiFi)",
            "iPad13,5": "iPad Pro (11\" Gen. 3 WiFi)",
            "iPad13,6": "iPad Pro (11\" Gen. 3 Cellular)",
            "iPad13,7": "iPad Pro (11\" Gen. 3 Cellular)",
            "iPad13,8": "iPad Pro (12.9\" Gen. 5 WiFi)",
            "iPad13,9": "iPad Pro (12.9\" Gen. 5 WiFi)",
            "iPad13,10": "iPad Pro (12.9\" Gen. 5 Cellular)",
            "iPad13,11": "iPad Pro (12.9\" Gen. 5 Cellular)",
            "iPad14,3": "iPad Pro (11\" Gen. 4 WiFi)",
            "iPad14,4": "iPad Pro (11\" Gen. 4 Cellular)",
            "iPad14,5": "iPad Pro (12.9\" Gen. 6 WiFi)",
            "iPad14,6": "iPad Pro (12.9\" Gen. 6 Cellular)",
            "iPad16,3": "iPad Pro (11\" M4 WiFi)",
            "iPad16,4": "iPad Pro (11\" M4 Cellular)",
            "iPad16,5": "iPad Pro (13\" M4 WiFi)",
            "iPad16,6": "iPad Pro (13\" M4 Cellular)",

            "i386": "Simulator",
            "x86_64": "Simulator",
        ]

        return mapping[platform] ?? platform
    }
}
