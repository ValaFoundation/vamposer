namespace Vamposer.Commands {
    public class RemoveCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            var remove_dev = false;
            var positionals = new Gee.ArrayList<string> ();

            for (var i = 2; i < args.length; i++) {
                var arg = args[i];
                if (arg == "--help" || arg == "-h") {
                    print_usage ();
                    return 0;
                }

                if (arg == "--dev") {
                    remove_dev = true;
                    continue;
                }

                if (arg.has_prefix ("-")) {
                    ConsoleStyle.print_error ("Unknown remove option: %s".printf (arg));
                    stderr.printf ("\n");
                    print_usage ();
                    return 1;
                }

                positionals.add (arg);
            }

            if (positionals.size < 1) {
                ConsoleStyle.print_error ("'remove' expects <dependency>");
                stderr.printf ("\n");
                print_usage ();
                return 1;
            }

            if (positionals.size > 2) {
                ConsoleStyle.print_error ("'remove' expects <dependency> [path/to/vamposer.json]");
                stderr.printf ("\n");
                print_usage ();
                return 1;
            }

            try {
                var dependency = positionals[0];
                var config_path = positionals.size >= 2 ? positionals[1] : "vamposer.json";

                var installer = new Installer ();
                installer.remove_dependency (config_path, dependency, remove_dev);
                return 0;
            } catch (Error e) {
                ConsoleStyle.print_error (e.message);
                return 1;
            }
        }
    }
}
