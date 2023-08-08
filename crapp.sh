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
export TEMPLATEDIR="${DATADIR}/templates"
export GENERATE_RANDOM_NAME=~/bin/gname
export TEMPDIR=$(mktemp --directory --suffix=.crapp --tmpdir=/tmp)

main() {
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

fatal() {
    echo "$@" >&2
    kill -10 $PROC
    exit 1
}

main "$@"
