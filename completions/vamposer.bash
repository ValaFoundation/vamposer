_vamposer_completions() {
    local cur prev words cword
    _init_completion || return

    local commands="help init install version self-upgrade require remove update completion"

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands --help -h" -- "$cur") )
        return
    fi

    local cmd="${words[1]}"
    case "$cmd" in
        --help|-h)
            COMPREPLY=()
            ;;
        install|require|remove|update)
            COMPREPLY=( $(compgen -W "--dev --help -h" -- "$cur") )
            ;;
        completion)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=( $(compgen -W "install --help -h" -- "$cur") )
            else
                COMPREPLY=( $(compgen -W "--help -h" -- "$cur") )
            fi
            ;;
        init|version|help)
            COMPREPLY=( $(compgen -W "--help -h" -- "$cur") )
            ;;
        self-upgrade)
            COMPREPLY=()
            ;;
    esac
}

complete -F _vamposer_completions vamposer
