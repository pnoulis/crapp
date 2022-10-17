#!/usr/bin/env bash

scriptdir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
srcdir="${scriptdir}"
projdir="$(dirname "${srcdir}")"


cd $projdir


# @param {string} $1 [Optional], tag
list_targets() {
    findCrappTargets "${1-}"
}

# @param {string} $1 [optional], tag
findCrappTargets () {
    if [ -z "$1" ]; then
        find "${projdir}/src" -mindepth 1 -maxdepth 1 \
             -type d -printf "%f\n"
    else
        find "${projdir}/src" -mindepth 1 \
             -ipath "*${1:-*}/targets/*" \
             -type d -printf "%f\n"
    fi
}


list_targets
