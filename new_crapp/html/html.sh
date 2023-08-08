#!/usr/bin/env bash

trap 'exit 1' 10
PROC=$$
# Exit script on error
set -o errexit

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
HTML_TEMPLATES="${TEMPLATEDIR}/html"
TEMPLATE=menu
TEMPLATE_FILEPATH=

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"

    [ $LIST_TEMPLATES ] && {
        tree -L 1 $HTML_TEMPLATES
        exit 0
    }

    TEMPLATE_FILEPATH="${HTML_TEMPLATES}/${TEMPLATE}".html
    debug template filepath $TEMPLATE_FILEPATH

    [ ! -f "${TEMPLATE_FILEPATH}" ] && {
        fatal "Missing template '${TEMPLATE}'"
    }

    [ $PRINT ] && {
        cat "$TEMPLATE_FILEPATH"
        exit 0
    }

    [ ! "$FILENAMES_PARSED" ] && {
        DEBUG=0 source ${DATADIR}/filenames.sh "$@"
    }
    cat "$TEMPLATE_FILEPATH" > ${TEMPDIR}/${FILENAME}.html
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -d | --debug)
                DEBUG=0
                ;;
            -l | --list)
                LIST_TEMPLATES=0
                ;;
            -t | --template)
                TEMPLATE=$(parse_param "$@") || shift $?
                ;;
            -p | --print)
                PRINT=0
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
                set -- "$@" $rest
                echo "$@"
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
    kill -10 $PROC
    exit 1
}

debug() {
    [ ! $DEBUG ] && return
    echo debug: "$@" >&2
}

main "$@"
