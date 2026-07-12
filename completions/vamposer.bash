_vamposer_completions() {
    local cur prev words cword
    _init_completion || return

    local commands="help init install version self-upgrade require remove update completion"

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return
    fi

    local cmd="${words[1]}"
    case "$cmd" in
        install|require|remove|update)
            COMPREPLY=( $(compgen -W "--dev --help" -- "$cur") )
            ;;
        completion)
            COMPREPLY=( $(compgen -W "install --help" -- "$cur") )
            ;;
        init|version|self-upgrade|help)
            COMPREPLY=( $(compgen -W "--help" -- "$cur") )
            ;;
    esac
}

complete -F _vamposer_completions vamposer
