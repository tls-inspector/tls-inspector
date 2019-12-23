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
        let platform = self.platform()

        let mapping = [
            "AppleTV2,1": "Apple TV 2G",
            "AppleTV3,1": "Apple TV 3G",
            "AppleTV3,2": "Apple TV 3G (Rev 2)",
            "AppleTV5,3": "Apple TV 4G",
            "AppleTV6,2": "Apple TV 4K",
            "iPhone1,1": "iPhone 1G",
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
            "iPod1,1": "iPod Touch 1G",
            "iPod2,1": "iPod Touch 2G",
            "iPod3,1": "iPod Touch 3G",
            "iPod4,1": "iPod Touch 4G",
            "iPod5,1": "iPod Touch 5G",
            "iPod7,1": "iPod Touch 6G",
            "iPad1,1": "iPad",
            "iPad2,1": "iPad 2 (WiFi)",
            "iPad2,2": "iPad 2 (GSM)",
            "iPad2,3": "iPad 2 (CDMA)",
            "iPad2,4": "iPad 2 (WiFi)",
            "iPad2,5": "iPad Mini (WiFi)",
            "iPad2,6": "iPad Mini (GSM)",
            "iPad2,7": "iPad Mini (GSM+CDMA)",
            "iPad3,1": "iPad 3 (WiFi)",
            "iPad3,2": "iPad 3 (GSM+CDMA)",
            "iPad3,3": "iPad 3 (GSM)",
            "iPad3,4": "iPad 4 (WiFi)",
            "iPad3,5": "iPad 4 (GSM)",
            "iPad3,6": "iPad 4 (GSM+CDMA)",
            "iPad4,1": "iPad Air (WiFi)",
            "iPad4,2": "iPad Air (Cellular)",
            "iPad4,3": "iPad Air (Cellular - China)",
            "iPad5,3": "iPad Air 2 (WiFi)",
            "iPad5,4": "iPad Air 2 (Cellular)",
            "iPad6,7": "iPad Pro (12.9\" WiFi)",
            "iPad6,8": "iPad Pro (12.9\" Cellular)",
            "iPad6,3": "iPad Pro (9.7\" WiFi)",
            "iPad6,4": "iPad Pro (9.7\" Cellular)",
            "iPad7,3": "iPad Pro (10.5\" WiFi)",
            "iPad7,4": "iPad Pro (10.5\" Cellular)",
            "iPad6,11": "iPad 5 (WiFi)",
            "iPad6,12": "iPad 5 (Cellular)",
            "iPad4,4": "iPad mini 2G (WiFi)",
            "iPad4,5": "iPad mini 2G (Cellular)",
            "iPad4,6": "iPad mini 2G (Cellular - China)",
            "iPad4,7": "iPad mini 3G (WiFi)",
            "iPad4,8": "iPad mini 3G (Cellular)",
            "iPad4,9": "iPad mini 3G (Cellular - China)",
            "iPad5,1": "iPad mini 4G (WiFi)",
            "iPad5,2": "iPad mini 4G (Cellular)",
            "i386": "Simulator",
            "x86_64": "Simulator",
        ]

        return mapping[platform] ?? platform
    }
}
