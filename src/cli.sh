# -*- mode: Shell-script -*-
#!/bin/bash

parse_clargs() {
    local -a posargs=()
    while [ $# -gt 0 ]; do
        case "$1" in
            --dev | -d) DEV=1; shift;;
            --crapp-type | -t)
                crapp_type="$2"
                shift; shift;;
            --app-name | -n)
                app_name="$2"
                shift; shift;;
            -* | --*) staterr -q "Unknown option $1";;
            *) posargs+=("$1"); shift;;
        esac
    done
    set -- "${posargs[@]}"
}

# # params
# # { string } [Mandatory] $1, path to installation directory.
# parse_app_path() {
#     [ -z "$1" ] && stateError 'Missing installation path'
# }

# ask_crapp_type() {
#     echo "ask"
# }

# ask_app_name() {
#     echo "ask"
# }
