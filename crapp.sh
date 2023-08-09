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
# Exit script on error
set -o errexit
declare -g PROC=$$


# Current location
SRCDIR_ABS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
export PROCDIR="$(pwd)"
cd "$SRCDIR_ABS"
SRCDIR='.'
export DATADIR="${SRCDIR}/new_crapp"
export TEMPLATESDIR="${DATADIR}/templates"
export GENERATE_RANDOM_NAME=~/bin/gname
# export TEMPDIR=$(mktemp --directory --suffix=.crapp --tmpdir=/tmp)
export TEMPDIR=${SRCDIR}/tmp

main() {
    rm -rdf ${TEMPDIR}/* 2>/dev/null
    subcommands "$@"
    tree -a $TEMPDIR
}

subcommands() {
    case "$1" in
        js)
            shift
            case "$1" in
                file)
                    shift
                    "${DATADIR}/js/file.sh" "$@"
                    ;;
                app)
                    shift
                    "${DATADIR}/js/app.sh" "$@"
                    ;;
                node)
                    shift
                    "${DATADIR}/node/node.sh" "$@"
                    ;;
                *)
                    fatal "Unknown js subcommand ${1}"
                    ;;
            esac
            ;;
        web)
            shift
            case "$1" in
                file)
                    shift
                    ;;
                app)
                    shift
                    ;;
                *)
                    fatal 'Unknown web subcommand ${1}'
                    ;;
            esac
            ;;
        git)
            shift
            ${DATADIR}/git/git.sh "$@"
            ;;
        dirs)
            shift
            ${DATADIR}/dirs/dirs.sh "$@"
            ;;
        html)
            shift
            ${DATADIR}/html/html.sh "$@"
            ;;
        bash)
            shift
            ${DATADIR}/bash/bash.sh "$@"
            ;;
        filename)
            shift
            DEBUG=0 ${DATADIR}/filenames.sh "$@"
            ;;
        make)
            shift
            ${DATADIR}/make/make.sh "$@"
            ;;
        *)
            fatal "No defined templates for language '$1'"
            ;;
    esac
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
    kill -10 $PROC
    exit 1
}
export -f fatal

debug() {
    [ ! $DEBUG ] && return
    echo debug: "$@" >&2
}
export -f debug


main "$@"
