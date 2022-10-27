#!/usr/bin/env bash

set -eu

# Flags
# --------------------------------------------------
declare -g FLAG
FLAG=

# Parameters
# --------------------------------------------------
declare -g PARAM
PARAM=

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
}

# @param {Array<string>} $0..$n - command line arguments
parse_args() {
    declare -g SHIFTER
    SHIFTER=$(mktemp)

    while (( $# > 0 )); do
        case "$1" in
            --param* | -param* | -p*)
                PARAM="$(parse_param "$@")"
                ;;
            --flag | -flag | -f)
                FLAG=0
                ;;
            --help | -help | --h | -h)
                usage
                exit 1
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

# Program start
# --------------------------------------------------
main "$@"
