import os
import subprocess

strings_path = "TLS Inspector/Localization/Strings/en.plist"
atomic_path = "TLS Inspector/Localization/Strings/._en.plist"

subprocess.call(["plutil", "-convert", "binary1", strings_path])
subprocess.call(["plutil", "-convert", "xml1", strings_path])

line_num = 0
with open(strings_path, 'r') as r:
    with open(atomic_path, 'w') as w:
        line = r.readline()
        while line:
            # Ignore the first 4 lines of the file (the schema declaration)
            if line_num <= 4:
                w.write(line)
            else:
                line = line.replace("'", "&apos;")
                line = line.replace('"', "&quot;")
                w.write(line)
            line_num += 1
            line = r.readline()

os.remove(strings_path)
os.rename(atomic_path, strings_path)
