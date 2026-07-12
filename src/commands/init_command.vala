namespace Vamposer.Commands {
    public class InitCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            if (args.length >= 3 && (args[2] == "--help" || args[2] == "-h")) {
                print_usage ();
                return 0;
            }

            try {
                var config_path = args.length >= 3 ? args[2] : "vamposer.json";
                var installer = new Installer ();
                installer.init_config (config_path);
                return 0;
            } catch (Error e) {
                ConsoleStyle.print_error (e.message);
                return 1;
            }
        }
    }
}
