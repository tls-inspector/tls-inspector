"""
TLS Inspector
Copyright (C) Ian Spence and other TLS Inspector Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""


# Two-letter ISO code for language
languages = [
    "en",
    "es",
    "de",
    "nl",
    "pl",
    "fr",
]

# Language name (in English) - Must be a single word with no symbols
languageNameMap = {
    "en": "English",
    "es": "Spanish",
    "de": "German",
    "nl": "Dutch",
    "pl": "Polish",
    "fr": "French",
}



import re
import os
import sys
import subprocess

validate = False
for arg in sys.argv:
    if arg == "--validate":
        validate = True

licnese_header = """% Copyright Ian Spence and TLS Inspector Authors
% Licensed under CC BY-SA 4.0 Attribution-ShareAlike 4.0 International"""

def check_license(r):
    header_lines = licnese_header.split("\n")

    l = 0
    for expected_line in header_lines:
        actual_line = r.readline().rstrip()

        if actual_line != expected_line:
            print("Expected line: '%s'\nActual line: '%s'" % (expected_line, actual_line))
            return -1

        l += 1

    return l

def normalizeKey(key):
    normalizedKey = re.sub(r"[^A-Za-z0-9]", "", key.lower())
    if key[0] >= '0' and key[0] <= '9':
        normalizedKey = "n" + key
    
    return normalizedKey.replace(' ', '')

def read_strings(lang):
    strings_path = "Strings/" + lang + ".strings"
    entries = []
    keys = {}

    with open(strings_path, 'r') as r:
        line_n = 0
        last_comment = []
        while True:
            if line_n == 0:
                skipped = check_license(r)
                if skipped == -1:
                    print("error: Invalid or missing license header in %s" % (lang+".strings"))
                    os.exit(1)
                line_n += skipped
                continue

            line_n += 1
            line = r.readline()
            if not line:
                break

            if line[0] == "#":
                last_comment.append(line[1:].rstrip().lstrip())
                continue

            parts = line.split('\t')
            if len(parts) != 2:
                print("error: Invalid string entry in %s:%d" % (lang+".strings", line_n))
                os.exit(1)

            key = parts[0].rstrip()
            value = parts[1].rstrip()

            if keys.get(normalizeKey(key)) is not None:
                print("error: Invalid entry in %s:%d - duplicate entry key" % (lang+".strings", line_n))
                os.exit(1)
            keys[normalizeKey(key)] = True

            if "{" in value and "{" not in key:
                print("error: Invalid entry in %s:%d - value contains a parameter but key does not" % (lang+".strings", line_n))
                os.exit(1)

            entries.append({
                "key": parts[0].rstrip(),
                "value": parts[1].rstrip(),
                "comments": last_comment,
            })
            last_comment = []

    return sorted(entries, key=lambda x: x["key"])

def process_strings(lang):
    strings_path = "Strings/" + lang + ".strings"
    atomic_path = strings_path + ".atomic"
    lang_entries = read_strings(lang)
    en_entries = read_strings("en")

    en_keys = {}
    lang_keys = {}
    for i, entry in enumerate(en_entries):
        en_keys[entry["key"]] = i
    for i, entry in enumerate(lang_entries):
        lang_keys[entry["key"]] = i

    # Remove old entries
    i = len(lang_entries) - 1
    while i >= 0:
        entry = lang_entries[i]
        key = entry["key"]
        if key in en_keys:
            i = i - 1
            continue

        lang_entries.pop(i)
        del lang_keys[key]
        i = i - 1

    # Add missing entries
    i = 0
    while i < len(en_entries):
        entry = en_entries[i]
        key = entry["key"]
        if key in lang_keys:
            i = i + 1
            continue

        new_entry = {
            "key": key,
            "value": entry["value"],
            "comments": ["TODO"],
        }
        if len(entry["comments"]) > 0:
            new_entry["comments"].extend(entry["comments"])

        i = i + 1
        lang_entries.append(new_entry)
        lang_keys[key] = i
    
    lang_entries = sorted(lang_entries, key=lambda x: x["key"])

    # Write new lang file
    with open(atomic_path, 'w') as w:
        w.write(licnese_header + "\n")
        for entry in lang_entries:
            key = entry['key']
            value = entry['value']
            comments = entry['comments']

            for comment in comments:
                w.write("# " + comment + "\n")
            w.write(key + "\t" + value + "\n")

    try:
        os.remove(strings_path)
    except Exception as e:
        pass

    os.rename(atomic_path, strings_path)

def pct_complete(lang):
    strings = read_strings(lang)

    complete = len(strings)

    for entry in strings:
        if len(entry["comments"]) > 0 and entry["comments"][0] == "TODO":
            complete = complete - 1

    return int((complete / len(strings)) * 100)

def getArgs(key):
    return re.findall(r"\{[A-Za-z0-9\-_]+\}", key)

def functionDef(key):
    args = getArgs(key)
    if args is not None:
        argsStr = []
        for arg in args:
            argsStr.append(arg[1:-1].lower() + ": String")
        return "public static func " + normalizeKey(key) + "(" + ", ".join(argsStr) + ") -> String"
    else:
        return "public static func " + normalizeKey(key) + "() -> String"

def write_localization_file(name):
    with open(name+'.new', 'w') as file:
        header = """// TLS Inspector
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

// DO NOT EDIT THIS FILE DIRECTLY!
// This file is generated automatically using the lang.py script located in
// the same directory as this file

import Foundation

public enum SupportedLanguages: String, Sendable, Hashable, Identifiable, CaseIterable, Codable {
"""
        file.write(header)

        for language in languages:
            file.write("    case " + languageNameMap[language] + " = \"" + language + "\"\n")


        header = """
    public var id: Self {
        return self
    }

    public var percentTranslated: Int {
        switch self {
"""
        file.write(header)

        for language in languages:
            file.write("        case ." + languageNameMap[language] + ": return " + str(pct_complete(language)) + "\n")


        header = """        }
    }
}

@MainActor
public var currentLanguage: SupportedLanguages = .English

@MainActor
public func updateCurrentLanguageToDeviceLocale() {
    for lang in Locale.preferredLanguages {
"""
        file.write(header)

        for language in languages:
            file.write("        if lang.hasPrefix(\"" + language + "-\") {\n")
            file.write("            currentLanguage = ." + languageNameMap[language] + "\n")
            file.write("            return\n")
            file.write("        }\n")

        header = """    }

    currentLanguage = .English
}

@MainActor
public final class Localize {
"""
        file.write(header)

        for entry in dictionary:
            file.write("    // key: " + entry["key"] + "\n")
            file.write("    " + functionDef(entry["key"]) + " {\n")

            file.write("        switch currentLanguage {\n")

            for language in languages:
                file.write("        case ." + languageNameMap[language] + ":\n")

                args = getArgs(entry["key"])
                val = entry["values"].get(language)
                if val == None:
                    val = entry["values"]["en"]

                val = val.replace("\"", "\\\"")
                if args is not None:
                    i = 0
                    for arg in args:
                        val = val.replace("{" + str(i) + "}", "\\(" + arg[1:-1] + ")")
                        i = i + 1

                file.write("            return \"" + val + "\"\n")

            file.write("        }\n")
            file.write("    }\n")
        file.write("}\n")
    os.rename(name+'.new', name)

# Entrypoint
for lang in languages:
    process_strings(lang)

dictionary = []
en_entries = read_strings("en")
langs = {}
for lang in languages:
    if lang == "en":
        continue
    langs[lang] = read_strings(lang)


for en_entry in en_entries:
    entry = {
        "key": en_entry["key"],
        "values": {
            "en": en_entry["value"]
        }
    }
    for lang in languages:
        if lang == "en":
            continue
        for le in langs[lang]:
            if le["key"] == en_entry["key"]:
                entry["values"][lang] = le["value"]
    dictionary.append(entry)

write_localization_file('Localization.swift')

if not validate:
    sys.exit()

is_valid = True
for entry in en_entries:
    q = "Localize." + normalizeKey(entry["key"])
    r = subprocess.run(["git", "--no-pager", "grep", q, "../../../"], capture_output=True)

    if len(r.stdout) == 0:
        print("::error ::Unused localization key: " + entry["key"])
        is_valid = False

if not is_valid:
    sys.exit(1)
