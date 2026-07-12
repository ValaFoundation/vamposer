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
                    ConsoleStyle.print_error ("Unknown install option: %s".printf (arg));
                    stderr.printf ("\n");
                    print_usage ();
                    return 1;
                }

                if (config_path_set) {
                    ConsoleStyle.print_error ("install expects at most one config path");
                    stderr.printf ("\n");
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
                ConsoleStyle.print_error (e.message);
                return 1;
            }
        }
    }
}
