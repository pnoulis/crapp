#!/usr/bin/env bash

main() {
    local TEMPLATE=base
    local TEMPLATE_FILEPATH=
    local DEFAULT_TARGET_NAME=
    parse_args "$@"
    set -- "${POSARGS[@]}"

    TEMPLATE_FILEPATH=${TEMPLATESDIR}/${TEMPLATE}
    debug template filepath $(quote "$TEMPLATE_FILEPATH")
    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal Missing template $(quote "$TEMPLATE")
    }

    filenames --default-name="$DEFAULT_TARGET_NAME" "$@"
    debug scaffolding app template $(quote $TEMPLATE)

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
            --project-name | --project-name=*)
                export PROJECT_NAME="$(parse_param "$@")" || shift $?
                ;;
            --project-version | --project-version=*)
                export PROJECT_VERSION="$(parse_param "$@")" || shift $?
                ;;
            --project-summary | --project-summary=*)
                export PROJECT_SUMMARY="$(parse_param "$@")" || shift $?
                ;;
            --project-keywords | --project-keywords=*)
                export PROJECT_KEYWORDS="$(parse_param "$@")" || shift $?
                ;;
            --project-author | --project-author=*)
                export PROJECT_AUTHOR="$(parse_param "$@")" || shift $?
                ;;
            --project-author-email | --project-author-email=*)
                export PROJECT_EMAIL="$(parse_param "$@")" || shift $?
                ;;
            --project-repo | --project-repo=*)
                export PROJECT_REPO="$(parse_param "$@")" || shift $?
                ;;
            --project-homepage | --project-homepage=*)
                export PROJECT_EMAIL="$(parse_param "$@")" || shift $?
                ;;
            --project-bugreport | --project-bugreport=*)
                export PROJECT_BUGREPORT="$(parse_param "$@")" || shift $?
                ;;
            --project-docs | --project-docs=*)
                export PROJECT_DOCS="$(parse_param "$@")" || shift $?
                ;;
            -t | --template | --template=*)
                TEMPLATE=$(OPTIONAL=0 parse_param "$@") || shift $?
                ;;
            -D | --dry-run)
                export DRY_RUN=0
                ;;
            --git-init)
                export GIT_INIT=0
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
