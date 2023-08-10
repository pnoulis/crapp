#!/usr/bin/env bash

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
MAKEFILE_TEMPLATES="${TEMPLATESDIR}/makefiles"
TEMPLATE=base
TEMPLATE_FILEPATH=

main() {
    debug crapp-makefile args: "$@"
    parse_args "$@"
    set -- "${POSARGS[@]}"
    debug crapp-makefile posargs: "${POSARGS[@]}"

    [ $LIST_TEMPLATES ] && {
        find $MAKEFILE_TEMPLATES -mindepth 1 -printf "%f\n"
        exit 0
    }

    local DEFAULT_TARGET_NAME=Makefile
    local LOC_FILENAME="${1:-$DEFAULT_TARGET_NAME}"

    TEMPLATE_FILEPATH="${MAKEFILE_TEMPLATES}/${TEMPLATE}"
    debug template filepath $TEMPLATE_FILEPATH

    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal "Missing template '${TEMPLATE}'"
    }

    [ ! "$TARGET_NAMES_PARSED" ] && {
        source ${DATADIR}/filenames.sh --default-name=$DEFAULT_TARGET_NAME "$@"
    }

    if [ -x $TEMPLATE_FILEPATH ]; then
        source ${TEMPLATE_FILEPATH}
        ${TEMPLATE##*/}
    elif [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
        exit 0
    elif [ $APPEND ]; then
        cat $TEMPLATE_FILEPATH >> $TEMPDIR/${LOC_FILENAME:-$TARGET_FILENAME}
    else
        cp $TEMPLATE_FILEPATH $TEMPDIR/${LOC_FILENAME:-$TARGET_FILENAME}
    fi
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -a | --append)
                APPEND=0
                ;;
            -t | --template)
                TEMPLATE=$(OPTIONAL=0 parse_param "$@") || shift $?
                ;;
            -l | --list)
                LIST_TEMPLATES=0
                ;;
            -D | --dry-run)
                export DRY_RUN=0
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

main "$@"
