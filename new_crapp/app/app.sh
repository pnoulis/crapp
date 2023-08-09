#!/usr/bin/env bash


trap 'exit 1' 10
PROC=$$
# Exit script on error
set -o errexit

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
export DOTENV_TEMPLATES="${TEMPLATESDIR}/dotenv"
export TEMPLATE=test
export TEMPLATE_FILEPATH=

main() {
    parse_args "$@"
    set -- "${POSARGS[@]}"
    local LOC_FILENAME="${1:-$DEFAULT_NAME}"

    [ ! "$FILENAMES_PARSED" ] && {
        source ${DATADIR}/filenames.sh "$@" 
    }

    # need a directory tree
    ${DATADIR}/dirs/dirs.sh --template base
    # need a PACKAGE file
    ${DATADIR}/pkg/pkg.sh
    # need a README file
    ${DATADIR}/readme/readme.sh --template base
    # need an .editorconfig file
    ${DATADIR}/editorconfig/editorconfig.sh --template base
    # need dotenv
    ${DATADIR}/dotenv/dotenv.sh --template base
    # need a .projectile file
    pushd ${TEMPDIR} >/dev/null
    touch .projectile
    popd >/dev/null
    # need a .gitignore file
    ${DATADIR}/git/git.sh --template gitignore/base .gitignore
    # need a .gitattributes file
    ${DATADIR}/git/git.sh --template gitattributes/base .gitattributes
    # need a Makefile
    ${DATADIR}/makefile/makefile.sh --template base
    # Initialize git but do not commit
    pushd ${TEMPDIR} >/dev/null
    git init
    git add .
    git config --local init.defaultBranch master
    git commit -m 'Initial commit'
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
            -d | --debug)
                export DEBUG=0
                ;;
            -D | --dry-run)
                export DRY_RUN=0
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
