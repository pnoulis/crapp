#!/usr/bin/env bash

main() {
    local -
    local TEMPLATE=base
    local TEMPLATE_FILEPATH=
    local DEFAULT_TARGET_NAME=
    parse_args "$@"
    set -- "${POSARGS[@]}"

    TEMPLATE_FILEPATH=${TEMPLATESDIR}/${TEMPLATE}
    debug template filepath $(quote $TEMPLATE_FILEPATH)
    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal Missing template $(quote "$TEMPLATE")
    }
    [ $DRY_RUN ] && {
        cat $TEMPLATE_FILEPATH
        exit 0
    }
    filenames --default-name="$DEFAULT_TARGET_NAME" "$@"
    debug scaffolding dirs template $(quote $TEMPLATE)

    if [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
    elif [ -x $TEMPLATE_FILEPATH ]; then
        ${TEMPLATE_FILEPATH}
    else
        fatal $(quote "$TEMPLATE_FILEPATH") is not an executable file
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
            -D | --dry-run)
                export DRY_RUN=0
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
