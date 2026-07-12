using Gee;
using Vamposer.Commands;

namespace Vamposer {
    private void print_usage () {
        stdout.printf ("%s\n\n", ConsoleStyle.style_usage_title ("Vamposer - dependency manager for Vala/Meson"));
        stdout.printf ("%s\n\n", ConsoleStyle.style_usage_section ("Version: %s".printf (APP_VERSION)));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_section ("Usage:"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer help"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer --help"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer init [path/to/vamposer.json]"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer install [--dev] [path/to/vamposer.json]"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer version"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer completion [install]"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer self-upgrade"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer require [--dev] <dependency> [revision] [path/to/vamposer.json]"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer remove [--dev] <dependency> [path/to/vamposer.json]"));
        stdout.printf ("%s\n", ConsoleStyle.style_usage_entry ("  vamposer update [--dev] [dependency] [path/to/vamposer.json]"));
    }

    public int main (string[] args) {
        var help_command = new HelpCommand ();
        var commands = new HashMap<string, CliCommand> ();
        commands.set ("completion", new CompletionCommand ());
        commands.set ("init", new InitCommand ());
        commands.set ("install", new InstallCommand ());
        commands.set ("version", new VersionCommand ());
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

        CompletionInstaller.auto_install_if_needed ();

        if (commands.has_key (command_name)) {
            return commands.get (command_name).execute (args, print_usage);
        }

        ConsoleStyle.print_error ("Unknown command: %s".printf (args[1]));
        stderr.printf ("\n");
        help_command.execute (args, print_usage);
        return 1;
    }
}
