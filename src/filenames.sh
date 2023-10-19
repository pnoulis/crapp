parse_filename_args() {
    declare -ga POSARGS=()
    while (($# > 0)); do
        case "${1:-}" in
            --default-name | --default-name=*)
                DEFAULT_NAME=$(OPTIONAL=0 parse_param "$@") || shift $?
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
                shift $#
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

export -f parse_filename_args

filenames() {
    debug filenames arguments $(quote "$@")
    local -
    parse_filename_args "$@"
    set -- "${POSARGS[@]}"

    export TARGET_BASENAME=
    export TARGET_DIRNAME=
    export TARGET_PATH=

    if [ "${DEFAULT_NAME:-}" ]; then
        TARGET_BASENAME=$DEFAULT_NAME
    else
        TARGET_BASENAME=$1
    fi
    TARGET_DIRNAME="${2:-.}"
    
    PROCDIR="${PROCDIR:-$(pwd)}"
    ifdef(`__DEBUG__`, `TARGET_DIRNAME=${CRAPPTEMPDIR}`)
    TARGET_DIRNAME="${TARGET_DIRNAME:-$PROCDIR}"
    TARGET_DIRNAME="$(realpath "$TARGET_DIRNAME")"
    if [ ! -d "${TARGET_DIRNAME:-}" ]; then
        # If the basename in TARGET_DIRNAME does not exist, create it.
        # Assume that the user intended for the basename
        # to be the name of his application if a name has
        # not been provided already
        if [ ! "${TARGET_BASENAME:-}" ]; then
            TARGET_BASENAME="${TARGET_DIRNAME##*/}"
            TARGET_PATH="${TARGET_DIRNAME}"
        else
            TARGET_PATH="${TARGET_DIRNAME}/${TARGET_BASENAME}"
        fi
    else
        TARGET_BASENAME="${TARGET_BASENAME:-$(gname)}"
        TARGET_PATH="${TARGET_DIRNAME}/${TARGET_BASENAME}"
    fi

    debug TARGET_BASENAME $TARGET_BASENAME
    debug TARGET_DIRNAME $TARGET_DIRNAME
    debug TARGET_PATH $TARGET_PATH
    mkdir -p $TARGET_DIRNAME
    debug push dir $(quote $TARGET_DIRNAME)
}
export -f filenames
