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
    local DEFAULT_NAME='PACKAGE'
    parse_args "$@"
    set -- "${POSARGS[@]}"
    local LOC_FILENAME="${1:-$DEFAULT_NAME}"

    [ ! "$FILENAMES_PARSED" ] && {
        source ${DATADIR}/filenames.sh --default-name=$DEFAULT_NAME "$@" 
    }

  
    PKG_NAME=${PKG_NAME:-$($GENERATE_RANDOM_NAME)}
    PKG_VERSION=${PKG_VERSION:-0.0.1}
    PKG_AUTHOR=${PKG_AUTHOR:-$(git config --get user.name)}
    PKG_AUTHOR_EMAIL=$(git config --get user.email)
    PKG_AUTHOR_REPO=${PKG_AUTHOR_REPO:-https://github.com/$PKG_AUTHOR}
    PKG_REPO=${PKG_REPO:-$PKG_AUTHOR_REPO}

    pkg=$(
        cat <<EOF
PKG_NAME=${PKG_NAME}
PKG_AUTHOR=${PKG_AUTHOR}
PKG_AUTHOR_EMAIL=${PKG_AUTHOR_EMAIL}
PKG_SUMMARY=${PKG_SUMMARY:-summary}
PKG_DESCRIPTION=${PKG_DESCRIPTION:-description}
PKG_KEYWORDS=${PKG_KEYWORDS:-keywords}
PKG_VERSION=${PKG_VERSION}
PKG_DISTNAME=${PKG_NAME}-v${PKG_VERSION}
PKG_REPO=${PKG_REPO}/${PKG_NAME}.git
PKG_HOMEPAGE=${PKG_HOMEPAGE:-${PKG_REPO}/${PKG_NAME}/#readme}
PKG_BUGREPORT=${PKG_BUGREPORT:-${PKG_REPO}/${PKG_NAME}/issues}
PKG_DOCS=${PKG_DOCS:-${PKG_REPO}/${PKG_NAME}/#readme}
EOF
       )

    [ $DRY_RUN ] && {
        for i in "$pkg"; do
            echo "$i"
        done
        exit 0
    }

    for i in "$pkg"; do
        echo "$i" >> ${TEMPDIR}/${LOC_FILENAME:-$FILENAME}
    done
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --pkg-name | --pkg-name=*)
                PKG_NAME="$(parse_param "$@")" || shift $?
                ;;
            --pkg-version | --pkg-version=*)
                PKG_VERSION="$(parse_param "$@")" || shift $?
                ;;
            --pkg-summary | --pkg-summary=*)
                PKG_SUMMARY="$(parse_param "$@")" || shift $?
                ;;
            --pkg-keywords | --pkg-keywords=*)
                PKG_KEYWORDS="$(parse_param "$@")" || shift $?
                ;;
            --pkg-author | --pkg-author=*)
                PKG_AUTHOR="$(parse_param "$@")" || shift $?
                ;;
            --pkg-author-email | --pkg-author-email=*)
                PKG_EMAIL="$(parse_param "$@")" || shift $?
                ;;
            --pkg-repo | --pkg-repo=*)
                PKG_REPO="$(parse_param "$@")" || shift $?
                ;;
            --pkg-homepage | --pkg-homepage=*)
                PKG_EMAIL="$(parse_param "$@")" || shift $?
                ;;
            --pkg-bugreport | --pkg-bugreport=*)
                PKG_BUGREPORT="$(parse_param "$@")" || shift $?
                ;;
            --pkg-docs | --pkg-docs=*)
                PKG_DOCS="$(parse_param "$@")" || shift $?
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
