#!/usr/bin/env bash

# e: exit on error
# u: treat unset variables and parameters as errors
# a: export variables in child processes
set -eu

# Flags
# --------------------------------------------------
declare -g LIST DEBUG DEV
LIST=
DEBUG=
DEV=


# Parameters
# --------------------------------------------------
declare -g crapp_tag crapp_target crapp_path \
        app_name app_path
crapp_tag=
crapp_target=
crapp_path=
app_name=
app_path=


# Constants
# --------------------------------------------------
declare -ga ARGS
declare -g SCRIPTDIR PROJDIR
ARGS=()
SCRIPTDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
PROJDIR="$(dirname "$SCRIPTDIR")"
TAGSDIR="${PROJDIR}/src/tags"
readonly SCRIPTDIR
readonly PROJDIR

# Usage
# --------------------------------------------------
usage() {
    cat >&2 <<EOF
Crapp produces application software directory templates.

Crapp's intended goal is to ease the software development process
by producing a directory tree formatted with tools that hopefully
will standardize and drive a simple development process.

Usage: crapp [options] <path>
Arguments:
    path    The 'basename' of the path is stripped off to
            produce the name of the target application.
            The 'dirname' of the path is the installation prefix.
            If the --app-name parameter has been provided with a
            name then the path including the basename is interpreted
            to mean the installation prefix.

Options:
    -h, --help                  Show this message
    -l, --list, -ls             List available tags or their targets
    -t, --crapp-target=TYPE       A string of the form '[tag:]target'
If the tag is ommited then the _target_ is interpreted as the requested
tag. Both tag or target shall be promted for if they are missing or not
recognized.

     -n, --app-name=NAME        Name of app host directory
     -f, --app-path=PATH        Prefix path of app
In case the <PATH> argument has been ommited --app-path replaces it.

    -d --debug                  Display debugging information
    --version                   Show version.

Report bugs to: git@github.com:pnoul/app/issues
Home page: git@github.com:pnoul#readme
EOF
}

# Utils
# --------------------------------------------------
main() {
    cd "${PROJDIR}" &>/dev/null
    parse_args "$@"

    if [ "${LIST-}" ]; then
        for i in $(find_crapp_targets); do
            describe_target "$i"
        done
        exit 0
    fi

    [ "${DEV-}" ] && {
        crapp_tag='bash'
        crapp_target='simple'
        crapp_path="${PROJDIR}/src/tags/bash/targets/simple"
        app_name="crapp_dev"
        app_path=~/tmp
    }
    parse_path
    askInfo

    [ "${DEBUG-}" ] && debug

    {
        echo --------------------------------------------------
        set -a
        cd $crapp_path

        # out of tree build
        BUILDIR=$(mktemp -dp /tmp "XXXX.${crapp_target}.crapp")
        SRCDIR="${crapp_path}"
        APPNAME="${app_name}"
        PREFIX="${app_path}"
        make && make install
        rm -drf $BUILDIR
    }
}

# @param {Array<string>} $0..$n - command line arguments
parse_args() {
    declare -g SHIFTER
    SHIFTER=$(mktemp)

    while (( $# > 0 )); do
        case "$1" in
            --list | --ls | -l)
                LIST=0
            ;;
            --create-target*)
                echo "create-target"
                ;;
            --crapp-target* | -t*)
                crapp_tag="$(parse_param "$@")"
                crapp_target="${crapp_tag##*:}"
                crapp_tag="${crapp_tag%%:*}"
                # Means the param argument was of the form
                # "some_name" and not "tag:some_name" which
                # The whole argument then is interpreted to mean the crapp_tag
                # and as thus the crapp_target is voided
                [ "${crapp_tag}" == "${crapp_target}" ] && crapp_target=
                ;;
            --app-name* | -n*)
                app_name="$(parse_param "$@")"
                ;;
            --app-path* | -f*)
                app_path="$(parse_param "$@")"
                ;;
            --help | -help | --h | -h)
                usage
                exit 1
                ;;
            --debug | -d)
                DEBUG=0
                ;;
            --dev | -D)
                DEV=0
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="$1"
                shift
                for i in $(echo "$i" | grep -o '[a-zA-Z]'); do
                    set -- "-$i" "$@"
                done
                continue
                ;;
            --)
                shift
                ARGS+=("$@")
                break
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                error "Unrecognized argument $1"
                exit 1
                ;;
            *)
                ARGS+=("$1")
                ;;
        esac
        shift $(( $(cat $SHIFTER) + 1 ))
        echo 0 >$SHIFTER
    done

    rm $SHIFTER && unset SHIFTER
    return 0
}


# @param {Array<string>} $1..$n - command line arguments
parse_param() {
    local param arg

    if [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        echo 1 >$SHIFTER
    fi

    if [ ! "${arg-}" ] && [ ! "${OPTIONAL-}" ]; then
        echo "${param-$1} requires an argument"
        exit 1
    fi
    echo "${arg-}"
    return 0
}


# @params { string } $n - options
# @param {string} $n - error message
staterr() {
    local -a args
    local quit usage message
    args=()
    exec 1>&2

    while [ $# -gt 0 ]; do
        case "$1" in
            -s) # silent
                exec 2>/dev/null
                shift
                ;;
            -q) # quit
                QUIT=0
                readonly QUIT
                shift
                ;;
            -u) # usage
                USAGE=0
                readonly USAGE
                shift
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    message="${args[@]}"
    [ -n "${message-}" ] && printf %s\\n "${message}"
    [ -n "${USAGE-}" ] && printf %s\\n 'Run with --help to see usage.'
    [ -n "${QUIT-}" ] && exit 1
    return 0
}

# @param {string} $1 - error message
fatal() {
    staterr -q "$@"
}

# @param {string} $1 - error message
error() {
    staterr -q "$@"
}

# @param {string} $1 - error message
warn() {
    staterr "$@"
}

debug() {
    echo "--------------------------------------------------"
    echo "crapp_tag: ${crapp_tag}"
    echo "crapp_target: ${crapp_target}"
    echo "crapp_path: ${crapp_path}"
    echo "app_name: ${app_name}"
    echo "app_path: ${app_path}"
    echo "--------------------------------------------------"
}

# @param {string} $1 [optional], tag
find_crapp_targets() {
    # 1st level dir nodes at {projdir}/src represent the available languages
    # for which targets exist
    if [ -z "${1-}" ]; then
        find "${TAGSDIR}" -mindepth 1 -maxdepth 1 \
             -type d -printf "%f\n"
    else
        find "${TAGSDIR}/$1/targets" -mindepth 1 -type d -printf "%f\n"
    fi
}

askInfo() {
    ask_app_name
    ask_crapp_tag
    ask_crapp_target
}

ask_app_name() {
    while :; do
        [ -z "${app_name-}" ] && read -rp 'App name: ' app_name
        case "${app_name-}" in
            [^a-zA-Z]* | *[^a-zA-Z0-9_-]* )
                error "Illegal app name: $app_name"
                ;;
            *) break ;;
        esac
    done
}

ask_crapp_tag() {
    local tags=($(find_crapp_targets))
    local tag
    local i

    if [ -n "${crapp_tag-}" ]; then
        for i in "${tags[@]}"; do
            [ "${crapp_tag}" == "${i}" ] && tag="${i}"
        done
        [ -z "${tag-}" ] && warn "Unrecognized tag: ${crapp_tag-}"
    fi
    crapp_tag="${tag-}"

    if [ -z "${crapp_tag-}" ]; then
        echo "--------------------------------------------------"
        PS3='Select tag: '
        select crapp_tag in "${tags[@]}"; do
            [ -n "${crapp_tag}" ] && break
        done
    fi
}

ask_crapp_target() {
    local -a targets=('one-based' $(find_crapp_targets "${crapp_tag}"))
    local target
    local i
    if [ -n "${crapp_target-}" ]; then
        for i in "${targets[@]}"; do
            [ "${crapp_target-}" == "${i}" ] && target="${i}"
        done
        [ -z "${target-}" ] && warn "Unrecognized target: ${crapp_tag}:${crapp_target-}"
    fi
    crapp_target="${target-}"

    if [ -z "${target-}" ]; then
        create_menu "${targets[@]}"
        while read -rp 'Select target: ' target; do
            if [[ "${target}" =~ ^[0-9]+$ ]]; then
                crapp_target="${targets[target]-}"
                if [ -n "${crapp_target-}" ]; then
                    crapp_path="${TAGSDIR}/${crapp_tag}/targets/${crapp_target}"
                    break
                else
                    create_menu "${targets[@]}"
                fi
            elif [[ "${target}" =~ ^[0-9]+@$ ]]; then
                crapp_target="${target%%@*}"
                crapp_target="${targets[crapp_target]-}"
                if [ -n "${crapp_target-}" ]; then
                    describe_target "${crapp_tag}" "${crapp_target}"
                else
                    create_menu "${targets[@]}"
                fi
            elif [[ "${target}" =~ ^@$ ]]; then
                describe_target "${crapp_tag}"
            else
                create_menu "${targets[@]}"
            fi
        done
    fi
}

# @param {string...} $1, create a menu
create_menu() {
    local i
    cat <<EOF
# -------------------------------------------------- #
n@ -> describe target
@ -> describe all targets
m -> show menu

EOF
    for ((i=2; i <= $#; i++)); do
        printf "%s) %s\n" $((i - 1)) "${!i}"
    done
}

# @param {string} $1, crapp_tag
# @param {string} [Optional] $2, crapp_target
# no target then describe them all
describe_target() {
    PURPLE='\033[0;35m'
    BLUE='\033[0;34m'
    RED='\033[0;31m'
    NC='\033[0m'

    find "${TAGSDIR}/${1}/targets" \
         -mindepth 1 \
         -maxdepth 1 \
         -name "${2:-*}" \
         -type d | while read -r target; do
        printf "\n# -------------------- ${PURPLE}%s${NC}:${RED}%s${NC} -------------------- #\n" \
               "${1:-tag}" \
               "${target##*/}"
        cat "${target}/description" | while read -r description; do
            printf "\t${BLUE}%s${NC}\n" "${description}"
        done
    done
}

parse_path() {
    app_path="${ARGS[0]:-$app_path}"
    local isDir="$(set +x; realpath "${app_path}" 2>/dev/null)"
    if [ -z "${app_name}" ]; then
        app_name="${isDir##*/}"
        isDir="${isDir%/*}"
    fi
    if [ ! -d "${isDir}" ]; then
        error "Missing root path: '${app_path}'"
    elif [ -d "${isDir}/${app_name}" ]; then
        error "App directory already exists: '${isDir}/${app_name}'"
    else
        app_path="${isDir}/${app_name}"
    fi
}

# Program start
# --------------------------------------------------
main "$@"
