namespace Vamposer.Commands {
    public class VersionCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length > 2) {
                ConsoleStyle.print_error ("'version' does not accept arguments");
                stderr.printf ("\n");
                print_usage ();
                return 1;
            }

            ConsoleStyle.print_version (APP_VERSION);
            return 0;
        }
    }
}
