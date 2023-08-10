#!/usr/bin/env bash

export TARGET_BASENAME=
export TARGET_DIRNAME="${2:-$PROCDIR}"
export TARGET_PATH=
export TARGET_NAMES_PARSED=0
DEFAULT_NAME=

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"
    TARGET_BASENAME="$1"
    TARGET_DIRNAME="${2:-$PROCDIR}"

    # expand $TARGET_DIRNAME in case it is '.'. At the same time make sure through the
    # -e flag that the file root directory does exist.
    TARGET_DIRNAME="$(realpath -e "$TARGET_DIRNAME")"
    TARGET_BASENAME="${TARGET_BASENAME:-$DEFAULT_NAME}"
    TARGET_BASENAME="${TARGET_BASENAME:-$($GENERATE_RANDOM_NAME)}"
    TARGET_PATH="${TARGET_DIRNAME}/${TARGET_BASENAME}"
    debug target path "${TARGET_PATH}"
}


parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --default-name | --default-name=*)
                DEFAULT_NAME=$(parse_param "$@") || shift $?
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

main "$@"


