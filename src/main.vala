using Gee;
using Vamposer.Commands;

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
        var help_command = new HelpCommand ();
        var commands = new HashMap<string, CliCommand> ();
        commands.set ("init", new InitCommand ());
        commands.set ("install", new InstallCommand ());
        commands.set ("self-upgrade", new SelfUpgradeCommand ());
        commands.set ("require", new RequireCommand ());
        commands.set ("remove", new RemoveCommand ());
        commands.set ("update", new UpdateCommand ());

        if (args.length < 2) {
            return help_command.execute (args, print_usage);
        }

        var command_name = args[1];
        if (command_name == "help" || command_name == "--help" || command_name == "-h") {
            return help_command.execute (args, print_usage);
        }

        if (commands.has_key (command_name)) {
            return commands.get (command_name).execute (args, print_usage);
        }

        stderr.printf ("[Vamposer] Unknown command: %s\n\n", args[1]);
        help_command.execute (args, print_usage);
        return 1;
    }
}
