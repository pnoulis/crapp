#!/usr/bin/env bash

# Exit script on error
set -o errexit

export FILENAME=
export FILEROOTDIR="${2:-$PROCDIR}"
export FILEPATH=
DEFAULT_NAME=

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"
    FILENAME="$1"
    FILEROOTDIR="${2:-$PROCDIR}"

    # expand $FILEROOTDIR in case it is '.'. At the same time make sure through the
    # -e flag that the file root directory does exist.
    FILEROOTDIR="$(realpath -e "$FILEROOTDIR")"
    FILENAME="${FILENAME:-$DEFAULT_NAME}"
    FILENAME="${FILENAME:-$($GENERATE_RANDOM_NAME)}"
    FILEPATH="${FILEROOTDIR}/${FILENAME}"
    debug file path "${FILEPATH}"
    export FILENAMES_PARSED=0
}


parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --default-name | --default-name=*)
                DEFAULT_NAME=$(parse_param "$@") || shift $?
                ;;
            -D | --dry-run)
                export DRY_RUN=0
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


