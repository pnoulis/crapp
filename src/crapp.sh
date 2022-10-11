#!/bin/bash
# Options
# --------------------------------------------------
declare -g _APP_NAME=
declare -g _APP_LANG=

scriptdir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
projdir="$(dirname "$scriptdir")"
posargs=()

main () {
    cd "$projdir"
    while [ $# -gt 0 ]; do
        case "$1" in
            --app-lang | -l )
                _APP_LANG="$2"
                shift
                shift
                ;;
            --app-name )
                _APP_NAME="$2"
                shift
                shift
                ;;
            -* | --* )
                stateError -u "Unknown option $1"
                ;;
            *)
                posargs+=("$1")
                shift
                ;;
        esac
    done
    set -- "${posargs[@]}"
    parsePath "$1"
    askInfo
}

stateError () {
    local usage=
    local message=
    local quit=1
    while getopts ":uQ" o; do
        case $o in
            u ) #usage
                usage=1
                ;;
            Q ) # do not exit
                quit=
                ;;
            * )
                "stateError: Unrecognized option"
                exit 1
        esac
    done
    shift $((OPTIND -1))
    message="$1"
    if [ -n "${message}" ]; then printf "%s\n" "$0: $message"; fi >&2
    if [ -n "${usage}" ]; then usage; fi
    if [ -n "${quit}" ]; then exit 1; fi
    return 0
}

# params
# { string } [REQUIRED] $1, app path
parsePath () {
    if [ -z "$1" ]; then stateError "Missing installation path"; fi
    local _APP_PATH="$(realpath "$1")"

    if [ -n "$_APP_NAME" ]; then
        if [ ! -d "${_APP_PATH}" ]; then stateError "'${_APP_PATH}': dirname oes not exist!"; fi
        _APP_PATH="${_APP_PATH%/}/${_APP_NAME}"
    else
        if [ -d "$_APP_PATH" ]; then stateError "'${_APP_PATH}': already exists!"; fi
        if [ ! -d "${_APP_PATH%/*}" ]; then stateError "'${_APP_PATH}': dirname does not exist!"; fi
    fi

    _APP_NAME="$(basename "$_APP_PATH")"
    echo path: ${_APP_PATH} appname: ${_APP_NAME}
}
askInfo () {
    askAppName "$_APP_NAME"
    askAppLang "$_APP_LANG"
}

# params
# { string } [Optional] $1, app name
askAppName () {
    local answer=
    local illegal=
    while true; do
        if [ -n "$1" ]; then
            answer="$1"
            shift
        else
            read -r -p 'App name: ' answer
        fi
        case "$answer" in
            [^a-zA-Z]* | *[^a-zA-Z0-9_-]* )
                stateError -Q "Unaccepted app name: ${answer}"
                ;;
            *)
                _APP_NAME="$answer";
                break
                ;;
        esac
    done
}

# params
# { string } [Optional] $1, app language
askAppLang () {
    local answer=
    while true; do
        if [[ -n "$1" ]]; then
            answer="$1"
            shift
        else
            read -r -p 'App language: ' answer
        fi
        case "$answer" in
            node )
                _APP_LANG="node"
                break
                ;;
            react )
                _APP_LANG="react"
                break
                ;;
            delphi )
                _APP_LANG="delphi"
                break
                ;;
            * )
                stateError -Q "Unsupported application language: ${answer}"
                ;;
        esac
    done
}

main "$@"
