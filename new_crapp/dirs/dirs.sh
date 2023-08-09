#!/usr/bin/env bash

# Exit script on error
set -o errexit

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
DIRS_TEMPLATES="${TEMPLATESDIR}/dirs"
TEMPLATE=menu
TEMPLATE_FILEPATH=

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"

    [ $LIST_TEMPLATES ] && {
        tree -L 1 $DIRS_TEMPLATES
        exit 0
    }

    TEMPLATE_FILEPATH="${DIRS_TEMPLATES}/${TEMPLATE}"
    debug template filepath $TEMPLATE_FILEPATH

    [ $DRY_RUN ] && {
        cat "$TEMPLATE_FILEPATH"
        exit 0
    }

    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal "Missing template '${TEMPLATE}'"
    }

    [ ! "$FILENAMES_PARSED" ] && {
        source ${DATADIR}/filenames.sh "$@"
    }

    [ ! -d "$TEMPDIR" ] && {
        fatal "Temporary directory '$TEMPDIR' missing"
    }

    if [ -x $TEMPLATE_FILEPATH ]; then
        source ${TEMPLATE_FILEPATH}
        ${TEMPLATE}
    else
        cp $TEMPLATE_FILEPATH $TEMPDIR
    fi
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --gitkeep)
                GITKEEP=0
                ;;
            -t | --template | --template=*)
                TEMPLATE=$(parse_param "$@") || shift $?
                ;;
            -l | --list)
                LIST_TEMPLATES=0
                ;;
            -d | --dry-run)
                DRY_RUN=0
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
