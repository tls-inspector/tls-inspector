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

import UIKit
import TLSKit
import DNSKit
import TLSUI
import Localization

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        TLSKit.log = LogWriter.shared
        DNSKit.log = DNSKitLoggerBridge.shared

        if UserOptions().useSystemLanguage {
            var didSet = false
            // Try to find the preferredn language
            for lang in Locale.preferredLanguages {
                if lang.hasPrefix("en-") {
                    currentLanguage = .English
                    didSet = true
                } else if lang.hasPrefix("es-") {
                    currentLanguage = .Spanish
                    didSet = true
                } else if lang.hasPrefix("de-") {
                    currentLanguage = .German
                    didSet = true
                } else if lang.hasPrefix("pl-") {
                    currentLanguage = .Polish
                    didSet = true
                }
            }

            if !didSet {
                currentLanguage = .English
            }
        } else {
            currentLanguage = UserOptions().languageOverride
        }

        LogWriter.shared.write(.Debug, message: "[\(#fileID):\(#line)] App loaded")

        NSSetUncaughtExceptionHandler { exc in
            LogWriter.shared.write(.Error, message: "[\(#fileID):\(#line)] Uncaught exception: \(exc.name) \(exc.reason ?? "no reason") \(exc.callStackSymbols.joined(separator: "\\n"))")
            LogWriter.shared.close()
        }

        return true
    }
}
