#!/usr/bin/env bash

main() {
    local TEMPLATE=base
    local TEMPLATE_FILEPATH=
    local DEFAULT_TARGET_NAME=PACKAGE
    debug crapp-pkg args: "$@"
    parse_args "$@"
    set -- "${POSARGS[@]}"

    TEMPLATE_FILEPATH=${TEMPLATESDIR}/${TEMPLATE}
    debug template filepath $(quote "$TEMPLATE_FILEPATH")
    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal Missing template $(quote "$TEMPLATE")
    }

    filenames --default-name="$DEFAULT_TARGET_NAME" "$@"
    debug scaffolding pkg template $(quote $TEMPLATE)

    pushd $TARGET_DIRNAME >/dev/null
    if [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
    elif [ -x $TEMPLATE_FILEPATH ]; then
        ${TEMPLATE_FILEPATH}
    elif [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
    elif [ $APPEND ]; then
        cat $TEMPLATE_FILEPATH >> $TARGET_BASENAME
    else
        cp $TEMPLATE_FILEPATH >> $TARGET_BASENAME
    fi
    popd >/dev/null
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --pkg-name | --pkg-name=*)
                export PKG_NAME="$(parse_param "$@")" || shift $?
                ;;
            --pkg-version | --pkg-version=*)
                export PKG_VERSION="$(parse_param "$@")" || shift $?
                ;;
            --pkg-summary | --pkg-summary=*)
                export PKG_SUMMARY="$(parse_param "$@")" || shift $?
                ;;
            --pkg-keywords | --pkg-keywords=*)
                export PKG_KEYWORDS="$(parse_param "$@")" || shift $?
                ;;
            --pkg-author | --pkg-author=*)
                export PKG_AUTHOR="$(parse_param "$@")" || shift $?
                ;;
            --pkg-author-email | --pkg-author-email=*)
                export PKG_EMAIL="$(parse_param "$@")" || shift $?
                ;;
            --pkg-repo | --pkg-repo=*)
                export PKG_REPO="$(parse_param "$@")" || shift $?
                ;;
            --pkg-homepage | --pkg-homepage=*)
                export PKG_EMAIL="$(parse_param "$@")" || shift $?
                ;;
            --pkg-bugreport | --pkg-bugreport=*)
                export PKG_BUGREPORT="$(parse_param "$@")" || shift $?
                ;;
            --pkg-docs | --pkg-docs=*)
                export PKG_DOCS="$(parse_param "$@")" || shift $?
                ;;
            -t | --template)
                TEMPLATE=$(OPTIONAL=0 parse_param "$@") || shift $?
                ;;
            -a | --append)
                APPEND=0
                ;;
            -D | --dry-run)
                 DRY_RUN=0
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
