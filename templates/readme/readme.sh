#!/usr/bin/env bash

main() {
    local TEMPLATE=base
    local TEMPLATE_FILEPATH=
    local DEFAULT_TARGET_NAME=README.md
    parse_args "$@"
    set -- "${POSARGS[@]}"

    TEMPLATE_FILEPATH=${TEMPLATESDIR}/${TEMPLATE}
    debug template filepath $(quote "$TEMPLATE_FILEPATH")
    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal Missing template $(quote "$TEMPLATE")
    }

    filenames --default-name="$DEFAULT_TARGET_NAME" "$@"
    debug scaffolding readme template $(quote $TEMPLATE)

    pushd $TARGET_DIRNAME >/dev/null
    if [ -x $TEMPLATE_FILEPATH ]; then
        ${TEMPLATE_FILEPATH}
    elif [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
    elif [ $APPEND ]; then
        cat $TEMPLATE_FILEPATH >> $TARGET_BASENAME
    else
        cp $TEMPLATE_FILEPATH $TARGET_BASENAME
    fi
    popd >/dev/null
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
