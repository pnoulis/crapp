#!/usr/bin/env bash

usage() {
    cat<<EOF
${0}: Project or file scaffolding generator through templates
EOF
}

trap 'exit 1' 10
set -o errexit
declare -g PROC=$$
PROCDIR=$(pwd)

crapp() {
    local -
    parse_crapp_args "$@"
    set -- "${POSARGS[@]}"
    [ ! $TMPKEEP ] && rm -rdf ${CRAPPTEMPDIR}/[.a-zA-Z_]*
    debug TEMPLATESROOTDIR $(quote $TEMPLATESROOTDIR)
    debug TEMPDIR $(quote $TEMPDIR)
    debug CRAPPTEMPDIR $(quote $CRAPPTEMPDIR)
    debug CRAPP $(quote $CRAPP)
    export TEMPLATESDIR=${TEMPLATESROOTDIR}/${subargs[0]}
    if [[ $LIST_TEMPLATES == 1 ]]; then
        for i in "${subs[@]}"; do
            echo "$i"
        done
        exit 0
    elif [[ $LIST_TEMPLATES == 2 ]]; then
        if (( ! ${#subargs[@]} )); then
            fatal Failed to specify template to -ll
        fi
        find $TEMPLATESDIR -mindepth 1 -printf "%f\n"
        exit 0
    fi
    debug call: $(quote ${TEMPLATESDIR}/${subargs[0]}.sh ${subargs[@]:1})
    if [ ! -e ${TEMPLATESDIR}/${subargs[0]}.sh ]; then
        fatal Missing template script $(quote "${TEMPLATESDIR}/${subargs[0]}.sh")
    fi
    mkdir -p $CRAPPTEMPDIR
    source ${TEMPLATESDIR}/${subargs[0]}.sh "${subargs[@]:1}"
    [ $DEBUG ] && {
        echo '------------------------------'
        find $TARGET_DIRNAME -mindepth 1
        echo '------------------------------'
    }
    echo ${subargs[0]} $TARGET_PATH
}

parse_crapp_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        crapp-subcommands "$@" || break
        case "${1:-}" in
            --tmpkeep)
                TMPKEEP=0
                ;;
            -l | --list)
                ((LIST_TEMPLATES += 1))
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

include(common)
include(config)
include(filenames)
include(subcommands)
crapp "$@"
