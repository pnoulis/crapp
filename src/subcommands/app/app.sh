#!/usr/bin/env bash

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
APP_TEMPLATES="${TEMPLATESDIR}/app"
TEMPLATE=base
TEMPLATE_FILEPATH=

main() {
    debug crapp-app args: "$@"
    parse_args "$@"
    set -- "${POSARGS[@]}"
    debug crapp-app posargs: "${POSARGS[@]}"

    [ $LIST_TEMPLATES ] && {
        find $APP_TEMPLATES -mindepth 1 -printf "%f\n"
        exit 0
    }

    TEMPLATE_FILEPATH="${APP_TEMPLATES}/${TEMPLATE}"
    debug template filepath $TEMPLATE_FILEPATH

    [ ! -e "${TEMPLATE_FILEPATH}" ] && {
        fatal "Missing template '${TEMPLATE}'"
    }

    local DEFAULT_TARGET_NAME=yolantza
    IFS=' ' read -a resolve < <(${DATADIR}/filenames.sh \
                                          --default-name="$DEFAULT_TARGET_NAME" \
                                          "$@")
    local TARGET_DIRNAME="${resolve[0]}"
    local TARGET_BASENAME="${resolve[1]}"
    local TARGET_PATH="${resolve[2]}"
    debug target dirname: $TARGET_DIRNAME
    debug target basename: $TARGET_BASENAME
    debug target path: $TARGET_PATH
    [ ! "${TARGET_PATH:-}" ] && exit 1

    if [ -x $TEMPLATE_FILEPATH ]; then
        source ${TEMPLATE_FILEPATH}
        pushd $TEMPDIR >/dev/null
        ${TEMPLATE##*/}
        popd >/dev/null
    elif [ $DRY_RUN ]; then
        cat $TEMPLATE_FILEPATH
    elif [ $APPEND ]; then
        cat $TEMPLATE_FILEPATH >> $TEMPDIR/${TARGET_BASENAME}
    else
        cp $TEMPLATE_FILEPATH $TEMPDIR/${TARGET_BASENAME}
    fi

    tree $TEMPDIR
    # mv $TEMPDIR/* $TARGET_PATH

    # # need a directory tree
    # ${DATADIR}/dirs/dirs.sh --template base
    # # need a PACKAGE file
    # ${DATADIR}/pkg/pkg.sh
    # # need a README file
    # ${DATADIR}/readme/readme.sh --template base
    # # need an .editorconfig file
    # ${DATADIR}/editorconfig/editorconfig.sh --template base
    # # need dotenv
    # ${DATADIR}/dotenv/dotenv.sh --template base
    # # need a .projectile file
    # pushd ${TEMPDIR} >/dev/null
    # touch .projectile
    # popd >/dev/null
    # # need a .gitignore file
    # ${DATADIR}/git/git.sh --template gitignore/base .gitignore
    # # need a .gitattributes file
    # ${DATADIR}/git/git.sh --template gitattributes/base .gitattributes
    # # need a Makefile
    # ${DATADIR}/makefile/makefile.sh --template base
    # # Initialize git but do not commit
    # pushd ${TEMPDIR} >/dev/null
    # git init
    # git add .
    # git config --local init.defaultBranch master
    # git commit -m 'Initial commit'
    # popd >/dev/null
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
