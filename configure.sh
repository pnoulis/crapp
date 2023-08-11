#!/usr/bin/env bash

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"
    # Current location
    local PKGDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
    local PKGDIR="$(realpath --relative-to="." "$PKGDIR_ABS")"
    local BINDIR=
    local DATADIR=
    local TEMPDIR=

    if [ $DEV ]; then
        BINDIR=${PKGDIR_ABS}/bin
        DATADIR=${PKGDIR_ABS}
        TEMPDIR=${PKGDIR_ABS}/tmp
        LIBSDIR=${PKGDIR_ABS}/src
    else
        BINDIR='~/bin'
        DATADIR='~/bin/crapp'
        LIBSDIR='~/bin/crapp'
        TEMPDIR='/tmp'
    fi

    m4 -D __PKGDIR_ABS__="$PKGDIR_ABS" \
       -D __PKGDIR__="$PKGDIR" \
       -D __BINDIR__="$BINDIR" \
       -D __DATADIR__="$DATADIR" \
       -D __TEMPDIR__="$TEMPDIR" \
       ${PKGDIR}/lib/macros.m4 \
       ${PKGDIR}/Makefile.in
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --dev)
                DEV=0
                ;;
            -d | --debug)
                export DEBUG=0
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="${1:-}"
                shift
                local rest="$@"
                set --
                for i in $(echo "$i" | grep -o '[a-zA-Z]'); do
                    set -- "$@" "-$i"
                done
                set -- $@ $rest
                continue
                ;;
            --)
                shift
                POSARGS+=("$@")
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                fatal "Unrecognized argument ${1:-}"
                ;;
            *)
                POSARGS+=("${1:-}")
                ;;
        esac
        shift
    done
}

parse_param() {
    local param arg
    local -i toshift=0

    if (($# == 0)); then
        return $toshift
    elif [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        ((toshift++))
    fi

    if [[ -z "${arg-}" && ! "${OPTIONAL-}" ]]; then
        fatal "${param:-$1} requires an argument"
    fi

    echo "${arg:-}"
    return $toshift
}

fatal() {
    echo "$@" >&2
    kill -10 $$
    exit 1
}

debug() {
    [ ! $DEBUG ] && return
    echo debug: "$@" >&2
}


main "$@"
