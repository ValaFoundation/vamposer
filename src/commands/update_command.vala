namespace Vamposer.Commands {
    public class UpdateCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            try {
                string? dependency = null;
                var config_path = "vamposer.json";

                if (args.length >= 3) {
                    dependency = args[2];
                }
                if (args.length >= 4) {
                    config_path = args[3];
                }

                var installer = new Installer ();
                installer.update (config_path, dependency);
                return 0;
            } catch (Error e) {
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        }
    }
}
