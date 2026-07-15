namespace Vamposer.Commands {
    public class RequireCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            var include_dev = false;
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
                    Logger.error ("Unknown require option: %s".printf (arg));
                    Logger.stderr_newline ();
                    print_usage ();
                    return 1;
                }

                positionals.add (arg);
            }

            if (positionals.size < 1) {
                Logger.error ("'require' expects at least <dependency>");
                Logger.stderr_newline ();
                print_usage ();
                return 1;
            }

            if (positionals.size > 3) {
                Logger.error ("'require' expects <dependency> [revision] [path/to/vamposer.json]");
                Logger.stderr_newline ();
                print_usage ();
                return 1;
            }

            try {
                var dependency = positionals[0];
                var revision = positionals.size >= 2 ? positionals[1] : "*";
                var config_path = positionals.size >= 3 ? positionals[2] : "vamposer.json";

                var installer = new Installer ();
                installer.require_dependency (config_path, dependency, revision, include_dev);
                return 0;
            } catch (Error e) {
                Logger.error (e.message);
                return 1;
            }
        }
    }
}
