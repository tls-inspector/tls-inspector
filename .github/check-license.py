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
from pathlib import Path
from datetime import datetime
import subprocess
import sys

scopes = [
    {
        "dir": "tls-inspector",
        "project": "TLS Inspector",
        "license": "GNU General Public License"
    },
    {
        "dir": ".github",
        "project": "TLS Inspector",
        "license": "GNU General Public License"
    },
    {
        "dir": "tlskit",
        "project": "TLSKit",
        "license": "GNU Lesser General Public License"
    },
    {
        "dir": "crashpad",
        "project": "Crashpad",
        "license": "GNU Lesser General Public License"
    }
]

license_header_template = """%s
Copyright (C) Ian Spence and other %s Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the %s as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%s for more details.

You should have received a copy of the %s
along with this program.  If not, see <https://www.gnu.org/licenses/>."""

def check_file_header(project, license, filepath, offset, prefixes):
    contents = ""
    with open(filepath, "r") as file:
        contents = file.read()

    lines = contents.split("\n")

    header = license_header_template % (project, project, license, license, license)
    header_lines = header.split('\n')

    if len(lines) + offset < len(header_lines):
        print(str(filepath) + ": Missing license header")
        return False

    i = 0
    while i < len(header_lines)-1:
        any_match = False
        for prefix in prefixes:
            if lines[i + offset] == prefix + header_lines[i]:
                any_match = True
                break
        if not any_match:
            print(str(filepath) + ":" + str(i) + ": Got '" + lines[i + offset] + "' Expected '" + prefix + header_lines[i] + "'")
            return False
        i = i + 1

    return True

all_passed = True

def is_excluded(filepath):
    excluded_paths = [
        "tlskit/.build",
        "tlskit/Package.swift",
        "crashpad/.build",
        "crashpad/Package.swift",
    ]

    for p in excluded_paths:
        if p in filepath:
            return True
    return False

for scope in scopes:
    swift_files = list(Path(scope["dir"]).rglob("*.[Ss][Ww][Ii][Ff][Tt]"))
    go_files = list(Path(scope["dir"]).rglob("*.[Gg][Oo]"))
    py_files = list(Path(scope["dir"]).rglob("*.[Pp][Yy]"))

    for filepath in swift_files:
        if is_excluded(str(filepath)):
            continue

        if not check_file_header(scope["project"], scope["license"], filepath, 0, ["// ", "//"]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

    for filepath in go_files:
        if is_excluded(str(filepath)):
            continue

        if not check_file_header(scope["project"], scope["license"], filepath, 1, [""]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

    for filepath in py_files:
        if is_excluded(str(filepath)):
            continue

        if not check_file_header(scope["project"], scope["license"], filepath, 1, [""]):
            print(str(filepath) + ": Invalid license header", file=sys.stderr)
            all_passed = False

if not all_passed:
    exit(1)
