namespace Vamposer.Commands {
    public class CompletionCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length >= 3 && (args[2] == "--help" || args[2] == "-h")) {
                print_usage ();
                return 0;
            }

            var action = args.length >= 3 ? args[2] : "install";
            if (action != "install") {
                Logger.error ("Unknown completion action: %s".printf (action));
                Logger.stderr_newline ();
                print_usage ();
                return 1;
            }

            try {
                var result = CompletionInstaller.install_for_current_user (true);
                switch (result) {
                case CompletionInstallResult.INSTALLED:
                    Logger.success ("Shell completion installed or updated for current user. Restart shell or source your rc file.");
                    return 0;
                case CompletionInstallResult.ALREADY_INSTALLED:
                    Logger.info ("Shell completion is already installed and up to date for current user.");
                    return 0;
                case CompletionInstallResult.SKIPPED_UNSUPPORTED_PLATFORM:
                    Logger.error ("Completion auto-install is currently supported on Linux only");
                    return 1;
                case CompletionInstallResult.SKIPPED_UNSUPPORTED_SHELL:
                    Logger.error ("Unsupported shell for completion auto-install. Use bash or zsh.");
                    return 1;
                case CompletionInstallResult.SKIPPED_DISABLED:
                    Logger.warning ("Completion auto-install is disabled by VAMPOSER_NO_AUTO_COMPLETION=1");
                    return 0;
                default:
                    Logger.error ("Unknown completion installer result");
                    return 1;
                }
            } catch (Error e) {
                Logger.error (e.message);
                return 1;
            }
        }
    }
}
