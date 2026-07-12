namespace Vamposer.Commands {
    public class CompletionCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length >= 3 && (args[2] == "--help" || args[2] == "-h")) {
                print_usage ();
                return 0;
            }

            var action = args.length >= 3 ? args[2] : "install";
            if (action != "install") {
                ConsoleStyle.print_error ("Unknown completion action: %s".printf (action));
                stderr.printf ("\n");
                print_usage ();
                return 1;
            }

            try {
                var result = CompletionInstaller.install_for_current_user (true);
                switch (result) {
                case CompletionInstallResult.INSTALLED:
                case CompletionInstallResult.ALREADY_INSTALLED:
                    stdout.printf ("[Vamposer] Shell completion installed for current user. Restart shell or source your rc file.\n");
                    return 0;
                case CompletionInstallResult.SKIPPED_UNSUPPORTED_PLATFORM:
                    ConsoleStyle.print_error ("Completion auto-install is currently supported on Linux only");
                    return 1;
                case CompletionInstallResult.SKIPPED_UNSUPPORTED_SHELL:
                    ConsoleStyle.print_error ("Unsupported shell for completion auto-install. Use bash or zsh.");
                    return 1;
                case CompletionInstallResult.SKIPPED_DISABLED:
                    return 0;
                default:
                    ConsoleStyle.print_error ("Unknown completion installer result");
                    return 1;
                }
            } catch (Error e) {
                ConsoleStyle.print_error (e.message);
                return 1;
            }
        }
    }
}
