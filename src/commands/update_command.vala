namespace Vamposer.Commands {
    public class UpdateCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            try {
                var include_dev = false;
                string? dependency = null;
                var config_path = "vamposer.json";
                var positionals = new Gee.ArrayList<string> ();

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
                        Logger.error ("Unknown update option: %s".printf (arg));
                        Logger.stderr_newline ();
                        print_usage ();
                        return 1;
                    }

                    positionals.add (arg);
                }

                if (positionals.size > 2) {
                    Logger.error ("'update' expects [dependency] [path/to/vamposer.json]");
                    Logger.stderr_newline ();
                    print_usage ();
                    return 1;
                }

                if (positionals.size >= 1) {
                    dependency = positionals[0];
                }
                if (positionals.size >= 2) {
                    config_path = positionals[1];
                }

                var installer = new Installer ();
                installer.update (config_path, dependency, include_dev);
                return 0;
            } catch (Error e) {
                Logger.error (e.message);
                return 1;
            }
        }
    }
}
