import UIKit

extension UIDevice {
    public func platform() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    public func platformName() -> String {
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                return "M1 macOS"
            }
        }
        
        let platform = self.platform()

        // https://www.theiphonewiki.com/wiki/Models
        let mapping = [
            // Apple TV
            "AppleTV2,1": "Apple TV Gen. 2",
            "AppleTV3,1": "Apple TV Gen. 3",
            "AppleTV3,2": "Apple TV Gen. 3 (Rev 2)",
            "AppleTV5,3": "Apple TV Gen. 4",
            "AppleTV6,2": "Apple TV 4K",

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

            // iPad Air
            "iPad4,1": "iPad Air (WiFi)",
            "iPad4,2": "iPad Air (Cellular)",
            "iPad4,3": "iPad Air (Cellular - China)",
            "iPad5,3": "iPad Air 2 (WiFi)",
            "iPad5,4": "iPad Air 2 (Cellular)",
            "iPad11,3": "iPad Air 3 (WiFi)",
            "iPad11,4": "iPad Air 3 (Cellular)",
            "iPad13,1": "iPad Air 4 (WiFi)",
            "iPad13,2": "iPad Air 4 (Cellular)",

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

            "i386": "Simulator",
            "x86_64": "Simulator",
        ]

        return mapping[platform] ?? platform
    }
}
