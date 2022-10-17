#!/usr/bin/env bash

set -eu

# Flags
# --------------------------------------------------
declare -g LIST DEBUG
LIST=
DEBUG=


# Parameters
# --------------------------------------------------
declare -g crapp_tag crapp_type crapp_path \
        app_name app_path
crapp_tag=
crapp_type=
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
readonly SCRIPTDIR
readonly PROJDIR

# Usage
# --------------------------------------------------
usage() {
    cat >&2 <<EOF
Program summary.
Program description...

Usage: crapp [options] <path>

Arguments:
    path    The 'basename' of the path is stripped off to
            produce the name of the target application.
            The 'dirname' of the path is the installation prefix.

Options:
    -h --help        Show this screen.
    -d --dev         Run dev() not main(). Used for development purposes.
    -v --verbose     Print as much information as possible.
    -S --silent      Disable all output.
    --version        Show version.

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
         find_crapp_targets "${crapp_tag}"
    fi

    if [ "${DEBUG-}" ]; then
        debug
    fi

    askInfo
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
            --crapp-type* | -t*)
                crapp_type="$(parse_param "$@")"
                crapp_tag="${crapp_type%%:*}"
                crapp_type="${crapp_type##*:}"

                # Means the param argument was of the form
                # "some_name" and not "tag:some_name"
                [ "${crapp_tag}" == "${crapp_type}" ] && crapp_tag=
                ;;
            --app-name* | -n*)
                app_name="$(parse_param "$@")"
                ;;
            --app-path* | -p*)
                app_path="$(parse_param "$@")"
                ;;
            --help | -help | --h | -h)
                usage
                exit 1
                ;;
            --debug | -d)
                DEBUG=0
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
    echo "crapp_tag: ${crapp_tag}"
    echo "crapp_type: ${crapp_type}"
    echo "crapp_path: ${crapp_path}"
    echo "app_name: ${app_name}"
    echo "app_path: ${app_path}"
}

# @param {string} $1 [optional], tag
find_crapp_targets() {
    if [ -z "${1-}" ]; then
        find "${PROJDIR}/src" -mindepth 1 -maxdepth 1 \
             -type d -printf "%f\n"
    else
        find "${PROJDIR}/src" -mindepth 1 \
             -ipath "*${1:-*}/targets/*" \
             -type d -printf "%f\n"
    fi
}

askInfo() {
    askAppName "${app_name-}"
    askCrappTag "${crapp_tag-}"
    askCrappType "${crapp_type-}"
}
askAppName() {
    echo 'ask app name'
    while :; do
        if [ -n "${1-}" ]; then
            shift
        else
            read -r -p 'App name: ' app_name
        fi
        case "${app_name-}" in
            [^a-zA-Z]* | *[^a-zA-Z0-9_-]* )
                error "Illegal app name: $app_name"
                ;;
            *) break ;;
        esac
    done
}
askCrappTag() {
    # local -a tags
    local tag
    # tags=()
    tag=
    local i

    read tinga <<<$(find_crapp_targets)
    echo "${tinga[@]}"
    # if [ -n "${1-}" ]; then
    #     for i in "${tags[@]}"; do
    #         [[ "${1-}" == "$i" ]] && tag="$1"
    #     done
    #     [ -z "${tag-}" ] && error "Unrecognized crapp tag: $1"
    # fi
}
askCrappType() {
    echo 'ask crapp type'
}

# Program start
# --------------------------------------------------
main "$@"
