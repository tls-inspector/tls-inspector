import os

def cleanup(v):
    r = v.replace("&", "&amp;")
    r = r.replace("\"", "&quot;")
    r = r.replace("'", "&apos;")
    r = r.replace("\\n", "\n")
    return r

def generate_plist(lang):
    strings_path = "TLS Inspector/Localization/Strings/" + lang + ".strings"
    plist_path = "TLS Inspector/Localization/Strings/" + lang + ".plist"
    plist_atomic_path = "TLS Inspector/Localization/Strings/" + lang + ".plist_atomic"

    pairs = {}

    with open(strings_path, 'r') as r:
        line_n = 0
        while True:
            line_n += 1
            line = r.readline()
            if not line:
                break

            if line[0] == "#":
                continue

            parts = line.split('\t')
            if len(parts) != 2:
                print("error: Invalid string entry in %s:%d" % (lang+".strings", line_n))
                os.exit(1)

            key = cleanup(parts[0].rstrip())
            value = cleanup(parts[1].rstrip())
            pairs[key] = value

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
        for key, value in pairs.items():
            line = """\t<key>%s</key>\n\t<string>%s</string>\n""" % (key, value)
            w.write(line)
        w.write(plist_footer)

    try:
        os.remove(plist_path)
    except Exception as e:
        pass

    os.rename(plist_atomic_path, plist_path)
    print("Generated %s" % plist_path)


for lang in ['en', 'de']:
    generate_plist(lang)
