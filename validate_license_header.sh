#!/bin/bash

ADD_HEADERS=0

usage() { echo "Usage: $0 [-a]" 1>&2; exit 1; }

while getopts "a" o; do
    case "${o}" in
        a)
            ADD_HEADERS=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

EXIT_CODE=0

function addHeader {
    FILE=$1
    NAME=$(basename ${FILE})
    YEAR=$(git --no-pager log -1 --format="%ai" -- ${FILE} | cut -d '-' -f1)

    HEADER="//
//  ${NAME}
//
//  LGPLv3
//
//  Copyright (c) ${YEAR} Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>.
"

    mv ${FILE} ${FILE}.tmp
    echo "${HEADER}" > ${FILE}
    cat ${FILE}.tmp >> ${FILE}
    rm ${FILE}.tmp
}

function checkLicenseHeader {
    FILE=$1
    NAME=$(basename $FILE)

HEADERPATTERN="//
//  ${NAME}
//
//  LGPLv3
//
//  Copyright (c) \d{4} Ian Spence
//  https://tlsinspector.com/github.html
//
//  This library is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this library.  If not, see <https://www.gnu.org/licenses/>."

    grep "${HEADERPATTERN}" $FILE > /dev/null
    FOUND=$?

    if [ $FOUND != 0 ]; then
        EXIT_CODE=1
        echo "${FILE}"
        if [ $ADD_HEADERS = 1 ]; then
            addHeader ${FILE}
        fi
    fi
}

for FILE in CertificateKit/**/*.m; do
    checkLicenseHeader $FILE
done

for FILE in CertificateKit/**/*.h; do
    checkLicenseHeader $FILE
done

exit $EXIT_CODE
