/*
TLSKit
Copyright (C) Ian Spence and other TLSKit Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
import fs from 'fs/promises';

var harper;
var linter;

async function lint(key, value) {
    let v = value.replaceAll('\\n', '\n');
    if (!v.endsWith('.')) {
        v = v + '.';
    }

    const lints = await linter.lint(v);
    if (lints.length === 0) {
        return false;
    }

    console.log(key, ':', value);

    for (const lint of lints) {
        console.log(' [' + lint.span().start + ':' + lint.span().end + ']', lint.message());

        if (lint.suggestion_count() !== 0) {
            for (const sug of lint.suggestions()) {
                console.log(
                    ' ',
                    sug.kind() === 1 ? 'Remove' : 'Replace with',
                    sug.get_replacement_text(),
                );
            }
        }

        console.log('');
    }

    return true;
}

async function main() {
    harper = await import('harper.js');
    linter = new harper.LocalLinter({
        binary: harper.binary,
        dialect: harper.Dialect.Canadian,
    });
    linter.importWords([
        'Ciphersuite',
        'CRL',
        'Libre',
        'OCSP',
        'OpenSSL',
        'Shodan',
        'WiFi',
    ]);

    let passed = true;

    const stringsData = await fs.readFile(process.argv[2], { encoding: 'utf-8' });
    const lines = stringsData.split('\n');
    for (const line of lines) {
        if (line.startsWith('%') || line.startsWith('#') || line === '') {
            continue;
        }

        const parts = line.split('\t');
        const key = parts[0];
        const value = parts[1];
        const has_issue = await lint(key, value);

        if (has_issue) {
            passed = false;
        }
    }

    return passed;
}

if (await main()) {
    process.exit();
} else {
    process.exit(1);
}
