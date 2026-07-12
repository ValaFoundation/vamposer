namespace Vamposer.Commands {
    public class InstallCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            var include_dev = false;
            var config_path = "vamposer.json";
            var config_path_set = false;

            for (var i = 2; i < args.length; i++) {
                var arg = args[i];
                if (arg == "--help" || arg == "-h") {
                    print_usage ();
                    return 0;
                }

                if (arg == "--dev") {
                    include_dev = true;
                    continue;
                }

                if (arg.has_prefix ("-")) {
                    stderr.printf ("[Vamposer] Error: Unknown install option: %s\n\n", arg);
                    print_usage ();
                    return 1;
                }

                if (config_path_set) {
                    stderr.printf ("[Vamposer] Error: install expects at most one config path\n\n");
                    print_usage ();
                    return 1;
                }

                config_path = arg;
                config_path_set = true;
            }

            try {
                var installer = new Installer ();
                installer.install (config_path, include_dev);
                return 0;
            } catch (Error e) {
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        }
    }
}
