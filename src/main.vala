namespace Vamposer {
    private void print_usage () {
        stdout.printf ("Vamposer - dependency manager for Vala/Meson\n\n");
        stdout.printf ("Usage:\n");
        stdout.printf ("  vamposer help\n");
        stdout.printf ("  vamposer --help\n");
        stdout.printf ("  vamposer init [path/to/vamposer.json]\n");
        stdout.printf ("  vamposer install [path/to/vamposer.json]\n");
        stdout.printf ("  vamposer self-upgrade\n");
        stdout.printf ("  vamposer require <dependency> [revision] [path/to/vamposer.json]\n");
        stdout.printf ("  vamposer remove <dependency> [path/to/vamposer.json]\n");
        stdout.printf ("  vamposer update [dependency] [path/to/vamposer.json]\n");
    }

    public int main (string[] args) {
        if (args.length < 2) {
            print_usage ();
            return 0;
        }

        switch (args[1]) {
        case "help":
        case "--help":
        case "-h":
            print_usage ();
            return 0;
        case "init":
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
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        case "install":
            if (args.length >= 3 && (args[2] == "--help" || args[2] == "-h")) {
                print_usage ();
                return 0;
            }

            var config_path = args.length >= 3 ? args[2] : "vamposer.json";
            try {
                var installer = new Installer ();
                installer.install (config_path);
                return 0;
            } catch (Error e) {
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        case "self-upgrade":
            try {
                var installer = new Installer ();
                installer.self_upgrade (args[0]);
                return 0;
            } catch (Error e) {
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        case "require":
            if (args.length < 3) {
                stderr.printf ("[Vamposer] Error: 'require' expects at least <dependency>\n\n");
                print_usage ();
                return 1;
            }

            try {
                var dependency = args[2];
                var revision = args.length >= 4 ? args[3] : "*";
                var config_path = args.length >= 5 ? args[4] : "vamposer.json";

                var installer = new Installer ();
                installer.require_dependency (config_path, dependency, revision);
                return 0;
            } catch (Error e) {
                stderr.printf ("[Vamposer] Error: %s\n", e.message);
                return 1;
            }
        case "remove":
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
        case "update":
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
        default:
            stderr.printf ("[Vamposer] Unknown command: %s\n\n", args[1]);
            print_usage ();
            return 1;
        }
    }
}
