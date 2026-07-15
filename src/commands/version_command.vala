namespace Vamposer.Commands {
    public class VersionCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length > 2) {
                Logger.error ("'version' does not accept arguments");
                Logger.stderr_newline ();
                print_usage ();
                return 1;
            }

            Logger.version (APP_VERSION);
            return 0;
        }
    }
}
