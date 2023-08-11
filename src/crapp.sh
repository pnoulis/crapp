#!/usr/bin/env bash

usage() {
    cat <<EOF
${0} is a software application scaffolding program.

     It may be used to generate a single file, files or whole application
     templates.
EOF
}

# ------------------------------ PROGRAM START ------------------------------ #
trap 'exit 1' 10
declare -g PROC=$$

# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
export PROCDIR=$(pwd)
LIBDIR=~/projects/pp/crapp
SRCDIR='.'
cd $LIBDIR

# Global variables intended to be used by all sourced programs and subshells
export DATADIR="${LIBDIR}/src"
export TEMPLATESDIR="${DATADIR}/templates"
export SUBCOMMANDSDIR=${DATADIR}/subcommands
export GENERATE_RANDOM_NAME=~/bin/gname
# export TEMPDIR=$(mktemp --directory --suffix=.crapp --tmpdir=/tmp)
export TEMPDIR=${SRCDIR}/tmp

main() {
    source ${DATADIR}/new_subs.sh
    parse_args "$@"
    set -- "${POSARGS[@]}"
}

parse_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        crapp-subcommands "$@" || break
        case "${1:-}" in
            -l | --list)
                LIST_TEMPLATES=0
                ;;
            -D | --dry-run)
                DRY_RUN=0
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

parse_param() {
    local param arg
    local -i toshift=0

    if (($# == 0)); then
        return $toshift
    elif [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        ((toshift++))
    fi

    if [[ -z "${arg-}" && ! "${OPTIONAL-}" ]]; then
        fatal "${param:-$1} requires an argument"
    fi

    echo "${arg:-}"
    return $toshift
}
export -f parse_param

fatal() {
    echo "$@" >&2
    kill -10 $$
    exit 1
}
export -f fatal

debug() {
    [ ! $DEBUG ] && return
    echo debug: "$@" >&2
}
export -f debug



main "$@"
