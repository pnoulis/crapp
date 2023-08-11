#!/usr/bin/env bash

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"

    local TARGET_BASENAME=
    local TARGET_DIRNAME=
    local TARGET_PATH=

    if (( $# == 2)); then
        TARGET_BASENAME="$1"
        TARGET_DIRNAME="$2"
    elif (( $# == 1)); then
        TARGET_DIRNAME="$1"
    fi

    TARGET_BASENAME="${TARGET_BASENAME:-$DEFAULT_NAME}"

    PROCDIR="${PROCDIR:-$(pwd)}"
    TARGET_DIRNAME="${TARGET_DIRNAME:-$PROCDIR}"
    TARGET_DIRNAME="$(realpath "$TARGET_DIRNAME")"
    if [ ! -d "${TARGET_DIRNAME:-}" ]; then
        # If the basename does not exist, create it.
        # Assume that the user intended for the basename
        # to be the name of his application if a name has
        # not been provided already
        mkdir -p $TARGET_DIRNAME
        if [ ! "${TARGET_BASENAME:-}" ]; then
            TARGET_BASENAME="${TARGET_DIRNAME##*/}"
            TARGET_PATH="${TARGET_DIRNAME}"
        else
            TARGET_PATH="${TARGET_DIRNAME}/${TARGET_BASENAME}"
        fi
    else
        TARGET_BASENAME="${TARGET_BASENAME:-$(gname)}"
        TARGET_PATH="${TARGET_DIRNAME}/${TARGET_BASENAME}"
    fi
    echo "$TARGET_DIRNAME" "$TARGET_BASENAME" "$TARGET_PATH"
}


parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --default-name | --default-name=*)
                DEFAULT_NAME=$(OPTIONAL=0 parse_param "$@") || shift $?
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
                shift $#
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

main "$@"
