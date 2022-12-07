#!/usr/bin/env bash


# Flags
# --------------------------------------------------
declare -g LIST AUTOGEN
LIST=
AUTOGEN=

# Parameters
# --------------------------------------------------
declare -g target preset path_target path_preset
target=
preset=
target_path=
preset_path=

declare -g package_name path_package_prefix path_package \
        package_version package_summary package_description

package_name=
package_prefix=
package_path=
package_version=
package_summary=
package_description=


# Utilities
declare -ga args
args=()

declare -g rootdir srcdir
rootdir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/.. &>/dev/null && pwd)
srcdir=${rootdir}/src


main() {
    cd "${rootdir}" &>/dev/null
    parse_args "$@"

    [ "${LIST-}" ] && {
        for i in $(find_targets); do
            describe_preset "$i"
        done
        exit 0
    }


    package_prefix="${package_prefix:-${args[0]}}"
    package_prefix="$(set +x; realpath "${package_prefix}" 2>/dev/null)"
    package_path="${package_prefix}/${package_name}"

    [ "${AUTOGEN-}" ] && {
        target="what"
        preset="yo"
        package_prefix="${package_prefix:-${HOME}/tmp}"
        package_name="${package_name:-$(./scripts/gname)}"
        package_path="${package_prefix}/${package_name}"
        package_summary="${package_summary:-$(lorem -s 1)}"
        package_version="${package_version:-0.0.1}"
    }

    ask_info
    validate_inputs

    echo $package_prefix
    echo $package_path
    echo $package_name
    echo $package_summary
    echo $package_version

}

parse_args() {
    declare -g SHIFTER
    SHIFTER=$(mktemp)

    while (( $# > 0 )); do
        case "$1" in
            --test)
                target="bash"
                package_prefix="./"
                package_name="some_name"
                package_summary="My application is a wonderfull application"
                package_version="1.0.0"
                ;;
            --target*)
                target="$(parse_param "$@")"
                ;;
            --preset*)
                preset="$(parse_param "$@")"
                ;;
            --path*)
                package_prefix="$(parse_param "$@")"
                ;;
            --name*)
                package_name="$(parse_param "$@")"
                ;;
            --summary*)
                package_summary="$(parse_param "$@")"
                ;;
            --version*)
                package_version="$(parse_param "$@")"
                ;;
            --autogen | -a)
                AUTOGEN=0
                ;;
            --list | --ls | -l)
                LIST=0
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
                args+=("$@")
                break
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                error "Unrecognized argument $1"
                exit 1
                ;;
            *)
                args+=("$1")
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
        error "${param-$1} requires an argument"
        exit 1
    fi
    echo "${arg-}"
    return 0
}

staterr() {
    local -a args=()
    local quit usage message
    exec 1>&2

    while [ $# -gt 0 ]; do
        case "$1" in
            -s) # silent
                exec 2>/dev/nulll
                shift
                ;;
            -q) # quit
                quit=0
                shift
                ;;
            -u) # usage
                usage=0
                shift
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    message="${args[@]}"
    [ -n "${message-}" ] && printf "%s\n" "${message}"
    [ -n "${usage-}" ] && printf "%s\n" "${message}"
    [ -n "${quit-}" ] && exit 1
    return 0
}

fatal() {
    staterr -q "$@"
}

error() {
    staterr -q "$@"
}

warn() {
    staterr "$@"
}

find_targets() {
    ls "${srcdir}" | grep 'target' | cut --delimiter='.' --fields=1
    return 0
}

find_presets() {
    ls "${srcdir}/${1-}.target" | grep 'preset' | cut --delimiter='.' --fields=1
    return 0
}

# @param {string} $1 target
# @param [string] $2 preset, if not preset provided then all presets are described
describe_preset() {
    PURPLE='\033[0;35m'
    BLUE='\033[0;34m'
    RED='\033[0;31m'
    NC='\033[0m'

    ls "${srcdir}/${1}.target" | grep "${2:-.*}\.preset" | cut --delimiter='.' --fields=1 | \
        while read preset; do
            printf "# -------------------- ${PURPLE}%s${NC}:${RED}%s${NC} -------------------- #\n" \
                   "${1}" "${preset}"
            cat "${srcdir}/${1}.target/${preset}.preset/description" | while read -r description; do
                printf "\t${BLUE}%s${NC}\n" "${description}"
            done
        done

    return 0
}

# @param {string...} $1, create a menu
create_menu() {
    local i
    cat <<EOF
# ------------------- Presets ------------------------- #
n@ -> describe preset
@ -> describe all presets
m -> show menu

EOF
    for ((i=2; i <= $#; i++)); do
        printf "%s) %s\n" $((i - 1)) "${!i}"
    done
}


display_inputs() {
    clear
    [[ -n "${package_name-}" ]] && printf "Application name: %s\n" "${package_name}"
    [[ -n "${target-}" ]] && printf "Target: %s\n" "${target-}"
    [[ -n "${preset-}" ]] && printf "Preset: %s\n" "${preset-}"
}

ask_info() {
    ask_package_name
    ask_target
    ask_preset
    # ask_package_prefix
    # ask_package_summary
    # ask_package_version
}

ask_target() {
    local -a targets=($(find_targets))
    local selected

    if [ -n "${target-}" ]; then
        for i in "${targets[@]}"; do
            [ "${target-}" == "${i}" ] && selected="${target}"
        done
        [ -z "${selected-}" ] && warn "Unrecognized target: ${target-}"
        target="${selected-}"
    fi

    if [ -z "${target-}" ]; then
        printf "Application target: \n"
        PS3='Select target: '
        select target in "${targets[@]}"; do
            [ -n "${target-}" ] && break
        done
    fi
    display_inputs
}

ask_preset() {
    local -a presets=('one-based' $(find_presets "${target}"))
    local selected


    if [ -n "${preset-}" ]; then
        for i in "${presets[@]}"; do
            [ "${preset-}" == "${i}" ] && selected="${i}"
        done
        [ -z "${preset-}" ] && warn "Unrecognized preset: ${target}:${preset-}"
        preset="${selected-}"
    fi

    if [ -z "${preset-}" ]; then
        create_menu "${presets[@]}"
        while read -rp 'Select preset: ' selected; do
            if [[ "${selected}" =~ ^[0-9]+$ ]]; then
                preset="${presets[selected]-}"
                if [ -n "${preset-}" ]; then
                    preset_path="${target_path}/${preset}.preset"
                    break
                else
                    create_menu "${presets[@]}"
                fi
            elif [[ "${selected}" =~ ^[0-9]+@$ ]]; then
                echo "describe preset"
                selected="${selected%%@*}"
                selected="${presets[selected]-}"
                describe_preset "${target}" "${selected}"
            elif [[ "${preset}" =~ ^@$ ]]; then
                create_menu "${targets[@]}"
            else
                create_menu "${targets[@]}"
            fi
        done
    fi
}


ask_package_name() {
    while :; do
        [ -z "${package_name-}" ] && read -rp 'Application name: ' package_name
        case "${package_name-}" in
            [^a-zA-Z]* | *[^a-zA-Z0-9_-]*)
                warn "Illegal application name: ${package_name}"
                package_name=""
                ;;
            *) break ;;
        esac
    done
    display_inputs
}


validate_inputs() {
    if [[ -z "${package_prefix}" || -z "${package_name}" || -z "${package_path}"
        || -z "${package_summary}" || -z "${package_version}" || -z "${target}"
        || -z "${preset}" ]]; then
        error "Missing required inputs"
        exit 1
    fi

    if [ ! -d "${package_prefix}" ]; then
        error "Missing path: '${package_prefix}'"
    elif [ -d "${package_path}" ]; then
        error "Duplicate app name: '${package_path}"
    fi
}

# Program start
# --------------------------------------------------
main "$@"


