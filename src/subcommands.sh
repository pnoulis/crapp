declare -a subargs=()
declare -a subs=(
    # languages
    js
    bash
    # tools
    makefile
    readme
    editorconfig
    git
    dotenv
    # others
    pkg
    dirs
    # high level integrating templates
    app
    web-node
)

crapp-subcommands() {
    # If the argument is a subcommand then assume the rest of the list is
    # intended for the subcommand not the current file.
    for sub in ${subs[@]}; do
        if [[ $sub == "${1:-}" ]]; then
            # The first element "$1" of the arguments list "$@" is the path to
            # this file originating from the callers working directory. Which
            # is why the slice operating starts at index 1 and not 0.
            subargs=("${@:1}")
            debug subcommand arguments $(quote "${subargs[@]}")
            return 1
        fi
    done
}
