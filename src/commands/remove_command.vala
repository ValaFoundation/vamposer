namespace Vamposer.Commands {
    public class RemoveCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length < 3) {
                stderr.printf ("[Vamposer] Error: 'remove' expects <dependency>\n\n");
                print_usage ();
                return 1;
            }

            try {
                var dependency = args[2];
                var config_path = args.length >= 4 ? args[3] : "vamposer.json";

                var installer = new Installer ();
                installer.remove_dependency (config_path, dependency);
                return 0;
            } catch (Error e) {
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        }
    }
}
