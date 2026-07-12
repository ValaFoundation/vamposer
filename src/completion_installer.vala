namespace Vamposer {
    public enum CompletionInstallResult {
        INSTALLED,
        ALREADY_INSTALLED,
        SKIPPED_UNSUPPORTED_PLATFORM,
        SKIPPED_UNSUPPORTED_SHELL,
        SKIPPED_DISABLED,
    }

    public class CompletionInstaller : Object {
        private const string MARKER_VERSION = "v1";

        public static CompletionInstallResult auto_install_if_needed () {
    #if WINDOWS
            return CompletionInstallResult.SKIPPED_UNSUPPORTED_PLATFORM;
    #else
            if (Environment.get_variable ("VAMPOSER_NO_AUTO_COMPLETION") == "1") {
                return CompletionInstallResult.SKIPPED_DISABLED;
            }

            try {
                var marker_path = get_marker_path ();
                if (FileUtils.test (marker_path, FileTest.EXISTS)) {
                    return CompletionInstallResult.ALREADY_INSTALLED;
                }

                var result = install_for_current_user (false);
                if (result == CompletionInstallResult.INSTALLED || result == CompletionInstallResult.ALREADY_INSTALLED) {
                    write_marker (marker_path);
                }

                return result;
            } catch (Error e) {
                // Auto-install is best-effort and must not block normal CLI usage.
                return CompletionInstallResult.SKIPPED_UNSUPPORTED_SHELL;
            }
    #endif
        }

        public static CompletionInstallResult install_for_current_user (bool force) throws Error {
    #if WINDOWS
            return CompletionInstallResult.SKIPPED_UNSUPPORTED_PLATFORM;
    #else
            var shell = detect_shell_name ();
            if (shell == "") {
                return CompletionInstallResult.SKIPPED_UNSUPPORTED_SHELL;
            }

            var home = Environment.get_home_dir ();
            if (home == null || home.strip () == "") {
                throw new IOError.FAILED ("Unable to determine HOME directory");
            }

            if (shell == "bash") {
                install_bash_completion (home);
            } else if (shell == "zsh") {
                install_zsh_completion (home);
            } else {
                return CompletionInstallResult.SKIPPED_UNSUPPORTED_SHELL;
            }

            if (!force) {
                write_marker (get_marker_path ());
            }

            return CompletionInstallResult.INSTALLED;
    #endif
        }

        private static string detect_shell_name () {
            var shell_path = Environment.get_variable ("SHELL");
            if (shell_path == null || shell_path.strip () == "") {
                return "";
            }

            return Path.get_basename (shell_path).strip ().down ();
        }

        private static string get_marker_path () throws Error {
            var home = Environment.get_home_dir ();
            if (home == null || home.strip () == "") {
                throw new IOError.FAILED ("Unable to determine HOME directory");
            }

            var marker_dir = Path.build_filename (home, ".local", "state", "vamposer");
            DirUtils.create_with_parents (marker_dir, 0755);
            return Path.build_filename (marker_dir, "completion-installed-%s".printf (MARKER_VERSION));
        }

        private static void write_marker (string marker_path) throws Error {
            FileUtils.set_contents (marker_path, "ok\n");
        }

        private static void install_bash_completion (string home) throws Error {
            var completion_dir = Path.build_filename (home, ".local", "share", "bash-completion", "completions");
            DirUtils.create_with_parents (completion_dir, 0755);

            var completion_path = Path.build_filename (completion_dir, "vamposer");
            FileUtils.set_contents (completion_path, get_bash_completion_script ());

            var bashrc_path = Path.build_filename (home, ".bashrc");
            append_block_if_missing (
                bashrc_path,
                "# >>> vamposer completion >>>",
                "# <<< vamposer completion <<<",
                "# >>> vamposer completion >>>\n"
                + "if [ -f \"$HOME/.local/share/bash-completion/completions/vamposer\" ]; then\n"
                + "  source \"$HOME/.local/share/bash-completion/completions/vamposer\"\n"
                + "fi\n"
                + "# <<< vamposer completion <<<\n"
            );
        }

        private static void install_zsh_completion (string home) throws Error {
            var completion_dir = Path.build_filename (home, ".local", "share", "zsh", "site-functions");
            DirUtils.create_with_parents (completion_dir, 0755);

            var completion_path = Path.build_filename (completion_dir, "_vamposer");
            FileUtils.set_contents (completion_path, get_zsh_completion_script ());

            var zshrc_path = Path.build_filename (home, ".zshrc");
            append_block_if_missing (
                zshrc_path,
                "# >>> vamposer completion >>>",
                "# <<< vamposer completion <<<",
                "# >>> vamposer completion >>>\n"
                + "fpath=(\"$HOME/.local/share/zsh/site-functions\" $fpath)\n"
                + "autoload -Uz compinit\n"
                + "compinit -u\n"
                + "# <<< vamposer completion <<<\n"
            );
        }

        private static void append_block_if_missing (string file_path, string marker_start, string marker_end, string block) throws Error {
            string contents = "";
            if (FileUtils.test (file_path, FileTest.EXISTS)) {
                FileUtils.get_contents (file_path, out contents);
                var marker_start_index = contents.index_of (marker_start);
                var marker_end_index = contents.index_of (marker_end);
                if (marker_start_index >= 0 && marker_end_index >= marker_start_index) {
                    var block_end_index = marker_end_index + marker_end.length;
                    if (block_end_index < contents.length && contents.substring (block_end_index, 1) == "\n") {
                        block_end_index++;
                    }

                    var before = contents.substring (0, marker_start_index);
                    var after = block_end_index < contents.length ? contents.substring (block_end_index) : "";

                    var updated = before;
                    if (updated != "" && !updated.has_suffix ("\n")) {
                        updated += "\n";
                    }
                    updated += block;
                    if (after != "" && !updated.has_suffix ("\n")) {
                        updated += "\n";
                    }
                    updated += after;

                    if (updated != contents) {
                        FileUtils.set_contents (file_path, updated);
                    }
                    return;
                }
            }

            var updated = contents;
            if (updated != "" && !updated.has_suffix ("\n")) {
                updated += "\n";
            }
            updated += block;
            FileUtils.set_contents (file_path, updated);
        }

        private static string get_bash_completion_script () {
            return """
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
""";
        }

        private static string get_zsh_completion_script () {
                        return """#compdef vamposer

_vamposer() {
  local -a commands
    local -a global_opts
  commands=(
    'help:show help'
    'init:initialize config'
    'install:install dependencies'
    'version:show version'
    'self-upgrade:upgrade vamposer binary'
    'require:add dependency'
    'remove:remove dependency'
    'update:update dependencies'
    'completion:manage shell completion'
  )
    global_opts=(
        '--help:show help'
        '-h:show help'
    )

  if (( CURRENT == 2 )); then
    _describe 'command' commands
        _describe 'option' global_opts
    return
  fi

  case ${words[2]} in
    install|require|remove|update)
            _arguments '--dev[include development dependencies]' '--help[show help]' '-h[show help]'
      ;;
    completion)
            _arguments '1:action:(install)' '--help[show help]' '-h[show help]'
      ;;
        init|version|help)
            _arguments '--help[show help]' '-h[show help]'
            ;;
        self-upgrade)
            _arguments '*:path:_files'
      ;;
    *)
      ;;
  esac
}

_vamposer "$@"
""";
        }
    }
}
