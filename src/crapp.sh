# -*- mode: Shell-script -*-
#!/bin/bash

# Flags
# --------------------------------------------------
declare -g DEV

# Parameters
# --------------------------------------------------
declare -g crapp_type crapp_path app_name app_path

# Constants
# --------------------------------------------------
declare -gr SCRIPTDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
declare -gr PROJDIR="$(dirname "$SCRIPTDIR")"

# Imports
# --------------------------------------------------
source "${PROJDIR}/src/utils.sh"
source "${PROJDIR}/src/cli.sh"

# Program Start
# --------------------------------------------------
main() {
    cd $PROJDIR &>/dev/null
    parse_clargs "$@"
}

dev() {
    printf "%s\n" "dev"
}

if [ -n "$DEV" ]; then
    dev "$@";
else
    main "$@";
fi
# declare -g crapp_type, \
#         crapp_path, \
#         app_name, \
#         app_path

# posargs=()

# dev () {
#     askCrappType
# }
# main () {
#     while [ $# -gt 0 ]; do
#         case "$1" in
#             --crapp-type | -t )
#                 _APP_LANG="$2"
#                 shift
#                 shift
#                 ;;
#             --app-name )
#                 _APP_NAME="$2"
#                 shift
#                 shift
#                 ;;
#             -* | --* )
#                 stateError -u "Unknown option $1"
#                 ;;
#             * )
#                 posargs+=("$1")
#                 shift
#                 ;;
#         esac
#     done
#     set -- "${posargs[@]}"
#     parseTargetPath "$1"
#     askInfo
# }

# stateError () {
#     local usage=
#     local message=
#     local quit=1
#     while getopts ":uQ" o; do
#         case $o in
#             u ) #usage
#                 usage=1
#                 ;;
#             Q ) # do not exit
#                 quit=
#                 ;;
#             * )
#                 "stateError: Unrecognized option"
#                 exit 1
#         esac
#     done
#     shift $((OPTIND -1))
#     message="$1"
#     if [ -n "${message}" ]; then printf "%s\n" "$message"; fi >&2
#     if [ -n "${usage}" ]; then usage; fi
#     if [ -n "${quit}" ]; then exit 1; fi
#     return 0
# }

# # params
# # { string } [REQUIRED] $1, app path
# parseTargetPath () {
#     if [ -z "$1" ]; then stateError "Missing installation path"; fi
#     app_path="$(realpath "$1")"

#     if [ -n "$app_name" ]; then
#         if [ ! -d "${app_path}" ]; then stateError "'${app_path}': dirname does not exist!"; fi
#         app_path="${app_path%/}/${app_name}"
#     else
#         if [ -d "$app_path" ]; then stateError "'${app_path}': already exists!"; fi
#         if [ ! -d "${app_path%/*}" ]; then stateError "'${app_path}': dirname does not exist!"; fi
#     fi

#     app_name="$(basename "$app_path")"
#     echo path: ${app_path} appname: ${app_name}
# }

# askInfo () {
#     askAppName "$_APP_NAME"
#     askCrappType "$_APP_LANG"
# }

# # params
# # { string } [Optional] $1, app name
# askAppName () {
#     while true; do
#         if [ -n "$1" ]; then
#             app_name="$1"
#             shift
#         else
#             read -r -p 'App name: ' app_name
#         fi
#         case "$app_name" in
#             [^a-zA-Z]* | *[^a-zA-Z0-9_-]* )
#                 stateError -Q "Illegal app name: $app_name"
#                 ;;
#             *)
#                 _APP_NAME="$app_name";
#                 break
#                 ;;
#         esac
#     done
# }

# # params
# # { string } [Optional] $1, app language
# askCrappType () {
#     local -a available_targets
#     declare -g crapp_type

#     read available_targets <<<$(findCrappTargets)
#     if [ -n "$1" ]; then
#         local i
#         for i in "${available_targets[@]}"; do
#             [[ "$1" == "$i" ]] && crapp_type="$i"
#         done
#         [ -z $crapp_type ] && stateError "Unrecognized app type: $1"
#     else
#         PS3="Select app type to create: "
#         select crapp_type in "${available_targets[@]}"
#         do
#             [ -n "$crapp_type" ] && break;
#         done
#     fi
#     exit 0;
# }

# findCrappTargets () {
#     find "${projdir}/src" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"
# }


# dev "$@"
# # main "$@"
