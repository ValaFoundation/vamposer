namespace Vamposer.Commands {
    public class VersionCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length > 2) {
                stderr.printf ("[Vamposer] Error: 'version' does not accept arguments\n\n");
                print_usage ();
                return 1;
            }

            stdout.printf ("Vamposer %s\n", APP_VERSION);
            return 0;
        }
    }
}
