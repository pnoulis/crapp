subcommands() {
    case "$1" in
        js)
            shift
            case "$1" in
                file)
                    shift
                    "${DATADIR}/js/file.sh" "$@"
                    ;;
                app)
                    shift
                    "${DATADIR}/js/app.sh" "$@"
                    ;;
                node)
                    shift
                    "${DATADIR}/node/node.sh" "$@"
                    ;;
                *)
                    fatal "Unknown js subcommand ${1}"
                    ;;
            esac
            ;;
        web)
            shift
            case "$1" in
                file)
                    shift
                    ;;
                app)
                    shift
                    ;;
                *)
                    fatal 'Unknown web subcommand ${1}'
                    ;;
            esac
            ;;
        git)
            shift
            ${DATADIR}/git/git.sh "$@"
            ;;
        dirs)
            shift
            ${SUBCOMMANDSDIR}/dirs/dirs.sh "$@"
            ;;
        html)
            shift
            ${DATADIR}/html/html.sh "$@"
            ;;
        bash)
            shift
            ${DATADIR}/bash/bash.sh "$@"
            ;;
        filename)
            shift
            DEBUG=0 ${DATADIR}/filenames.sh "$@"
            ;;
        makefile)
            shift
            ${DATADIR}/makefile/makefile.sh "$@"
            ;;
        readme)
            shift
            ${DATADIR}/readme/readme.sh "$@"
            ;;
        dotenv)
            shift
            ${DATADIR}/dotenv/dotenv.sh "$@"
            ;;
        editorconfig)
            shift
            ${DATADIR}/editorconfig/editorconfig.sh "$@"
            ;;
        pkg)
            shift
            ${DATADIR}/pkg/pkg.sh "$@"
            ;;
        app)
            shift
            ${DATADIR}/app/app.sh "$@"
            ;;
        *)
            fatal "No defined templates for language '$1'"
            ;;
    esac
}

