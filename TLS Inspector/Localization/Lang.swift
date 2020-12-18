import Foundation

private var LOCALIZATION_DICTIONARY: [String: String]?

class Localization {
    public static func load() {
        // Always load english, overwrite the keys with translated values if they exist
        LOCALIZATION_DICTIONARY = loadStringDictionary(name: "en")

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
        let preferredLang = Locale.preferredLanguages[0].components(separatedBy: "-")[0]
        if preferredLang == "en" {
            // Nothing else to do
            return
        }

        // Map of supported language - these need to match the filename of the plist
        let supportedLanguages = [
            "en": 1,
            "de": 1
        ]
        if supportedLanguages[preferredLang] == nil {
            print("Unsupported system language '\(preferredLang)'")
            return
        }

        if let dict = loadStringDictionary(name: preferredLang) {
            // Merge the dictionary with the language
            // so that missing keys always default to the english keys
            LOCALIZATION_DICTIONARY?.merge(dict, uniquingKeysWith: { (_, new) -> String in new })
        }
    }

    private static func loadStringDictionary(name: String) -> [String: String]? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {
            print("No language plist found for language '\(name)'")
            return nil
        }

        guard let dict = NSDictionary(contentsOfFile: path) as? [String : String] else {
            print("Unable to load language dictionary at path '\(name)'")
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
