#!/usr/bin/env bash

# Exit script on error
set -o errexit

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
MAKEFILE_TEMPLATES="${TEMPLATESDIR}/makefiles"
TEMPLATE=menu
TEMPLATE_FILEPATH=

main() {
    local DEFAULT_NAME='Makefile'
    parse_args "$@"
    set -- "${POSARGS[@]}"
    local LOC_FILENAME="${1:-$DEFAULT_NAME}"

    [ $LIST_TEMPLATES ] && {
        tree -L 1 $MAKEFILE_TEMPLATES
        exit 0
    }

    TEMPLATE_FILEPATH="${MAKEFILE_TEMPLATES}/${TEMPLATE}"
    debug template filepath $TEMPLATE_FILEPATH

    [ ! -f "${TEMPLATE_FILEPATH}" ] && {
        source ${DATADIR}/filenames.sh --default-name=$DEFAULT_NAME "$@"
    }

    [ ! "$FILENAMES_PARSED" ] && {
        DEBUG=0 source ${DATADIR}/filenames.sh "$@"
    }

    [ ! -d "$TEMPDIR" ] && {
        fatal "Temporary directory '$TEMPDIR' missing"
    }

    if [ -x $TEMPLATE_FILEPATH ]; then
        source ${TEMPLATE_FILEPATH}
        ${TEMPLATE##*/}
    else
        [ $DRY_RUN ] && {
            cat "$TEMPLATE_FILEPATH"
            exit 0
        }
        if [ $APPEND ]; then
            cat $TEMPLATE_FILEPATH >> $TEMPDIR/${LOC_FILENAME:-$FILENAME}
        else
            cp $TEMPLATE_FILEPATH $TEMPDIR/${LOC_FILENAME:-$FILENAME}
        fi
    fi
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -t | --template)
                TEMPLATE=$(parse_param "$@") || shift $?
                ;;
            -l | --list)
                LIST_TEMPLATES=0
                ;;
            -d | --debug)
                export DEBUG=0
                ;;
            -D | --dry-run)
                export DRY_RUN=0
                ;;
            -a | --append)
                APPEND=0
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
