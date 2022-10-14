#!/bin/bash

set -eu

declare -g PARAM OPT FLAG DEBUG
declare -ga ARGS
ARGS=()
PARAM=
OPT=
FLAG=
DEBUG=

main() {
    parse_args "$@"
    # echo "\$PARAM: ${PARAM}"
    # echo "\$OPT: ${OPT}"
    # echo "\$FLAG: ${FLAG}"
    # echo "\$ARGS: ${ARGS[@]:-}"
}

parse_args() {
    declare -g SHIFTER
    SHIFTER=$(mktemp)

    while (( $# > 0 )); do
        case "$1" in

            # Parameter
            # Double dash parameter
            # Single dash parameters
            # Short parameters
            # equal delimited parameters
            # space delitimed parameters
            --param* | -param* | -p*)
                PARAM="$(parse_param "$@")"
                ;;

            # Optional paramater arguments
            # Optional is displayed as a separate parameter
            # from --param to showcase it. Not because it is a requirement
            --optional* | -optional* | -P*)
                OPT="$(OPTIONAL=0 parse_param "$@")"
                OPT="${OPT:-default}"
                ;;

            # Flags
            # Double dash flags
            # Single dash flags
            # Short flags
            --flag | -flag | -f)
                FLAG=0
                ;;

            # Debug
            --debug | -d)
                DEBUG=0
                ;;

            # Short option combinations
            -[a-zA-Z][a-zA-Z]*)
                local i="$1"
                shift
                for i in "$(echo "$1" | grep -o '[a-zA-Z]')"; do
                    set -- "-$i" "$@"
                done
                continue
                ;;

            # Stop option parsing with --
            --)
                shift
                ARGS+=("$@")
                break
                ;;

            # Capture unrecognized options
            # Custom Error handling
            -[a-zA-Z]* | --[a-zA-Z]*)
                echo "error"
                exit 1
                ;;

            # Positional arguments
            # Option after arguments
            *)
                ARGS+=("$1")
                ;;
        esac

        # Each pass through the switch statement pops one argument off of the
        # array. That element might not be the one that was last admitted in the
        # case loop
        shift $(( $(cat $SHIFTER) + 1 ))
        echo 0 >$SHIFTER
    done

    rm $SHIFTER && unset SHIFTER
    return 0
}

parse_param() {
    local param arg

    # Equal delimited parameter
    if [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
        # Space delimited parameter
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        echo 1 >$SHIFTER
    fi

    # Optional parameter arguments
    if [ ! "${arg-}" ] && [ ! "${OPTIONAL-}" ]; then
        echo "${param-$1} requires an argument"
        exit 1
    fi
    echo "${arg-}"
    return 0
}

main "$@"
