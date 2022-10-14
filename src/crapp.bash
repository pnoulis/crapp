#!/bin/bash
set -eu

# Author: pnoul
# Email: pavlos.noulis@gmail.com
# Git: git@github.com:pnoul
# Version: 0.0.1

# Flags
# --------------------------------------------------
declare DEV VERBOSE

# Parameters
# --------------------------------------------------
declare CRAPP_TYPE CRAPP_PATH APP_NAME APP_PATH

# Constants
# --------------------------------------------------
SCRIPTDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
PROJDIR="$(dirname "$SCRIPTDIR")"
readonly SCRIPTDIR
readonly PROJDIR

# Imports
# --------------------------------------------------
source "${PROJDIR}/src/utils.sh"
source "${PROJDIR}/src/cli.sh"

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

# Program Start
# --------------------------------------------------
main() {
    cd "${PROJDIR}" &>/dev/null
    parse_args "$@"
}

# @param {Array<string>} $0..$n - command line arguments
parse_args() {
    declare -g OPTARG=

    while (( $# > 0 )); do
        case "$1" in
            --example-param* | -example-param* | -e*)
                parse_param "$@"
                EXAMPLE_PARAM="${OPTARG-}"
                ;;
            --example-optional* | -example-optional* | -E*)
                OPTIONAL=0 parse_param "$@"
                EXAMPLE_OPTIONAL="${OPTARG:-optional value}"
                ;;
            --dev | -d)
                DEV=1
                readonly DEV
                break
                ;;
            --silent | --quiet | -S)
                exec 1&>/dev/null
                ;;
            --verbose | -v)
                VERBOSE=1
                readonly VERBOSE
                ;;
            --version | -V)
                echo "version"
                ;;
            --help | -help | --h | -h)
                usage
                exit 0
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="$1"
                shift
                for i in $(grep -o '[a-zA-Z]' <<<"$i"); do
                    set -- "-$i" "$@"
                done
                continue
                ;;
            -[a-z]*)
                warn -u "Unknown option $1"
                exit 1
                ;;
            --[a-zA-Z]*)
                warn -u "Unkown option $1"
                exit 1
                ;;
            --) shift; break ;;
            *)
                echo "no match: $1"
                break
                ;;
        esac
        shift
    done
    unset OPTARG
    echo "$@"
}

##
# Support equal and space delimited paramaters
# Support optional arguments
# Example: [param=value | param="value" | param value | param "value" | param]
#
# @param {Array<string>} $1..$n - command line arguments
##
parse_param() {
    local param

    if [[ "$1" =~ .*=.* ]]; then # equal delimited parameter
        param="${1%%=*}"
        OPTARG="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then # space delimited parameter
        echo "space delimited"
        param="$1"
        OPTARG="$2"
        shift
    fi

    if [ ! "${OPTARG-}" ] && [ ! "${OPTIONAL-}" ]; then
        error -u "${param-$1} requires an argument"
        exit 1
    fi
    return 0
}

# @param {string} $1 - error message
staterr() {
    local -a posargs
    local QUIT="" USAGE="" MESSAGE=""
    exec 1>&2
    while [ $# -gt 0 ]; do
        case "$1" in
            -s) # silent
                exec 2>/dev/null
                shift
                ;;
            -q) # quit
                QUIT=1
                shift
                ;;
            -u) # usage
                USAGE=1
                shift
                ;;
            *)
                posargs+=("$1")
                shift
                ;;
        esac
    done
    set -- "${posargs[@]}"
    MESSAGE="$1"
    [ -n "${MESSAGE}" ] && printf "%s\n" "${MESSAGE}"
    [ -n "${USAGE}" ] && printf "%s\n" "Run with --help to see usage."
    [ -n "${QUIT}" ] && exit 1
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

main "$@"
