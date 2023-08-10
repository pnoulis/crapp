#!/usr/bin/env bash

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
BASH_TEMPLATES="${TEMPLATESDIR}/bash"
TEMPLATE=base
TEMPLATE_FILEPATH=

main() {
    debug crapp-bash args: "$@"
    parse_args "$@"
    set -- "${POSARGS[@]}"
    debug crapp-bash posargs: "${POSARGS[@]}"

    [ $LIST_TEMPLATES ] && {
        find $BASH_TEMPLATES -mindepth 1 -printf "%f\n"
        exit 0
    }

    TEMPLATE_FILEPATH="${BASH_TEMPLATES}/${TEMPLATE}"
    debug template filepath $TEMPLATE_FILEPATH

    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal "Missing template '${TEMPLATE}'"
    }

    local DEFAULT_TARGET_NAME=bash
    IFS=' ' read -a resolve < <(${DATADIR}/filenames.sh \
                                          --default-name="$DEFAULT_TARGET_NAME" \
                                          "$@")
    local TARGET_DIRNAME="${resolve[0]}"
    local TARGET_BASENAME="${resolve[1]}".sh
    local TARGET_PATH="${resolve[2]}"
    debug target dirname: $TARGET_DIRNAME
    debug target basename: $TARGET_BASENAME
    debug target path: $TARGET_PATH
    [ ! "${TARGET_PATH:-}" ] && exit 1

    if [ -x $TEMPLATE_FILEPATH ]; then
        source ${TEMPLATE_FILEPATH}
        ${TEMPLATE##*/}
    elif [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
    elif [ $APPEND ]; then
        cat $TEMPLATE_FILEPATH >> $TEMPDIR/${TARGET_BASENAME}
    else
        cp $TEMPLATE_FILEPATH $TEMPDIR/${TARGET_BASENAME}
    fi
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            -t | --template | --template=*)
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

main "$@"
