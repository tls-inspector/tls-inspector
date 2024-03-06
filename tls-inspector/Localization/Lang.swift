import Foundation

private var LOCALIZATION_DICTIONARY: [String: String]?

public enum SupportedLanguages: String, CaseIterable {
    case English = "en"
    case German = "de"
    case Spanish = "es"
    case Dutch = "nl"
}

class Localization {
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

func lang(key: String) -> String {
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

func lang(key: String, args: [String]) -> String {
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
