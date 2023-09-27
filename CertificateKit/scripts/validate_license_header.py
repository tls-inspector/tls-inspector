from pathlib import Path
import os
import re
import subprocess
import sys

with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), "LICENSE_TEMPLATE.txt"), "r") as f:
    licenseTemplate = f.read()

def get_file_year(filepath):
    date = subprocess.run(['git', '--no-pager', 'log', '--diff-filter=A', '--follow', '-1', '--format=%ai', '--', filepath], stdout=subprocess.PIPE).stdout.decode('utf-8')
    return date.split('-')[0]

root = Path(sys.argv[1])
files = list(root.glob('**/*.m')) + list(root.glob('**/*.h'))

all_files_ok = True

for fileObject in files:
    file = str(fileObject)
    if '.xcframework' in file or 'build/' in file:
        continue

    parts = file.split('/')
    fileName = parts[len(parts)-1]

    template = licenseTemplate
    template = template.replace("#NAME#", fileName)
    template = template.replace("(", "\(")
    template = template.replace(")", "\)")
    template = template.replace("+", "\+")
    template = template.replace("#YEAR#", "[0-9]+")

    with open(file, "r") as f:
        file_contents = f.read()

    if re.search(template, file_contents) is None:
        all_files_ok = False
        print(file)

if not all_files_ok:
    sys.exit(1)
