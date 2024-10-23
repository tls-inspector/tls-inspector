// TLS Inspector
// Copyright (C) 2024 Ian Spence
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

@MainActor
public func Localize(_ key: String) -> String {
    if LOCALIZATION_DICTIONARY == nil {
        Localization.load()
        if LOCALIZATION_DICTIONARY == nil {
            return key
        }
    }

    guard let translated = LOCALIZATION_DICTIONARY?[key] else {
        print("Unrecognized localization key: '\(key)'")
        return key
    }

    return translated
}

@MainActor
public func Localize(_ key: String, args: [String]) -> String {
    if LOCALIZATION_DICTIONARY == nil {
        Localization.load()
        if LOCALIZATION_DICTIONARY == nil {
            return key
        }
    }

    guard var translated = LOCALIZATION_DICTIONARY?[key] else {
        print("Unrecognized localization key: '\(key)'")
        return key
    }

    let count = args.count
    var i = 0
    while i < count {
        let val = args[i]
        let stringKey = String.init(format: "{%u}", i)
        translated = translated.replacingOccurrences(of: stringKey, with: val)
        i += 1
    }

    return translated
}

@MainActor private var LOCALIZATION_DICTIONARY: [String: String]?

public enum SupportedLanguages: String, CaseIterable, Codable {
    case English = "en"
    case Spanish = "es"

    var name: String {
        return String(describing: self)
    }
}

@MainActor
public final class Localization {
    public static func load() {
        // Always load english, overwrite the keys with translated values if they exist
        LOCALIZATION_DICTIONARY = loadStringDictionaryForLanguage(.English)

        if Locale.preferredLanguages.count <= 0 {
            // This really shouldn't happen but it could crash the app otherwise
            print("Preferred language is empty")
            return
        }

        // We're not terribly concerned with the locale-specifics of languages (at the moment)
        // so just focus on the language and trim off the locale (I.E. we don't have specific english files for
        // Canadian english v.s. British English, we just have english.
        //
        // Also Colour is spelt with a U. Deal with it.
        var preferredLang: SupportedLanguages = .English
        if let systemLang = SupportedLanguages(rawValue: Locale.preferredLanguages[0].components(separatedBy: "-")[0]) {
            preferredLang = systemLang
        } else {
            print("Unsupported system language '\(preferredLang)', defaulting to english")
        }

        if let userLang = UserOptions.appLanguage {
            preferredLang = userLang
        }

        if preferredLang == .English {
            // Nothing else to do since the english strings are always loaded
            return
        }

        if let dict = loadStringDictionaryForLanguage(preferredLang) {
            // Merge the dictionary with the language
            // so that missing keys always default to the english keys
            LOCALIZATION_DICTIONARY?.merge(dict, uniquingKeysWith: { (_, new) -> String in new })
        }
    }

    private static func loadStringDictionaryForLanguage(_ name: SupportedLanguages) -> [String: String]? {
        guard let path = Bundle.main.path(forResource: name.rawValue, ofType: "plist") else {
            print("No language plist found for language '\(name.rawValue)'")
            return nil
        }

        guard let dict = NSDictionary(contentsOfFile: path) as? [String : String] else {
            print("Unable to load language dictionary at path '\(name.rawValue)'")
            return nil
        }

        return dict
    }
}
