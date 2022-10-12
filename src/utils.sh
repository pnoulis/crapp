# -*- mode: Shell-script -*-
#!/bin/bash

usage() {
    echo <<EOF
some usage
EOF
}

# State Error
#
# Description
# Staterr is used to terminate the program and may optionally be provided
# with a message to print.
# The name staterr which phonetically reminds us deliberately of
# 'stutter' is indicative of the function's malleable behavior. When the function
# is provided with a message it prints it and therefore no stuttering ever
# occurs. Contrary, when a message is not provided the function stutters but
# may still be used to terminate the program.
# All hail the victorious staterrs.
#
# Params
# [ string ] $1, message
staterr() {
    local -a posargs
    local USAGE QUIT MESSAGE
    exec 1>&2
    while [ $# -gt 0 ]; do
        case "$1" in
            --silent | -s) echo "silent"; exec 2>/dev/null; shift;;
            --usage | -u) USAGE=1; shift;;
            --quit | -q) QUIT=1; shift;;
            -* | --*) printf "%s\n" "Unknown Option: $1"; exit 1;;
            *) posargs+=("$1"); shift;;
        esac
    done
    set -- "${posargs[@]}"
    MESSAGE="$1"
    [ -n "$MESSAGE" ] && printf "%s\n" "$MESSAGE"
    [ -n "$USAGE" ] && usage
    [ -n "$QUIT" ] && exit 1
}
