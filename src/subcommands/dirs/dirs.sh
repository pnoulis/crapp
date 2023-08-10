#!/usr/bin/env bash

# Current location
DIRS_TEMPLATES="${TEMPLATESDIR}/dirs"
TEMPLATE=base
TEMPLATE_FILEPATH=

main() {
    debug crapp-dirs args: "$@"
    parse_args "$@"
    set -- "${POSARGS[@]}"
    debug crapp-dirs posargs: "${POSARGS[@]}"

    [ $LIST_TEMPLATES ] && {
        find $DIRS_TEMPLATES -mindepth 1 -printf "%f\n"
        exit 0
    }

    TEMPLATE_FILEPATH="${DIRS_TEMPLATES}/${TEMPLATE}"
    debug template filepath $TEMPLATE_FILEPATH

    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal "Missing template '${TEMPLATE}'"
    }

    local DEFAULT_TARGET_NAME=
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
    else
        fatal ${TEMPLATE} is not an executable file
    fi

}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --gitkeep)
                export GITKEEP=0
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
