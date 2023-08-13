quote() {
    echo \'"$@"\'
}
export -f quote
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
