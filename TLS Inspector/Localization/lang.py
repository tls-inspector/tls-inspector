import os

def cleanup(v):
    r = v.replace("&", "&amp;")
    r = r.replace("\"", "&quot;")
    r = r.replace("'", "&apos;")
    r = r.replace("\\n", "\n")
    return r

def read_strings(lang):
    strings_path = "Strings/" + lang + ".strings"
    entries = []

    with open(strings_path, 'r') as r:
        line_n = 0
        last_comment = []
        while True:
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


def generate_plist(lang):
    plist_path = "Strings/" + lang + ".plist"
    plist_atomic_path = plist_path + ".atomic"

    entries = read_strings(lang)

    plist_head = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
"""

    plist_footer = """</dict>
</plist>
"""

    try:
        os.remove(plist_atomic_path)
    except Exception as e:
        pass

    with open(plist_atomic_path, 'w') as w:
        w.write(plist_head)
        for entry in entries:
            key = cleanup(entry["key"])
            value = cleanup(entry["value"])
            line = """\t<key>%s</key>\n\t<string>%s</string>\n""" % (key, value)
            w.write(line)
        w.write(plist_footer)

    try:
        os.remove(plist_path)
    except Exception as e:
        pass

    os.rename(plist_atomic_path, plist_path)
    print("Generated %s" % plist_path)


for lang in ['en', 'de', 'es', 'nl']:
    process_strings(lang)
    generate_plist(lang)

