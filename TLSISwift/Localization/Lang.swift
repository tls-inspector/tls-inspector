import Foundation

private var LOCALIZATION_DICTIONARY: [String: String]?

class Localization {
    public static func load() {
        let preferredLang = Locale.preferredLanguages[0]
        var lang: String = "en"
        for supportedLanguage in ["en"] {
            if preferredLang.hasPrefix(supportedLanguage) {
                lang = supportedLanguage
            }
        }

        guard let path = Bundle.main.path(forResource: lang, ofType: "plist") else {
            print("No language plist found for language '\(lang)'")
            return
        }

        guard let dict = NSDictionary(contentsOfFile: path) as? [String : String] else {
            print("Unable to load language dictionary at path '\(path)'")
            return
        }

        LOCALIZATION_DICTIONARY = dict
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
        print("Unrecognized localization key " + key)
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
        print("Unrecognized localization key " + key)
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
