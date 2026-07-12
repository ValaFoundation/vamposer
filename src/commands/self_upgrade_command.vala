namespace Vamposer.Commands {
    public class SelfUpgradeCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            try {
                var installer = new Installer ();
                installer.self_upgrade (args[0]);
                return 0;
            } catch (Error e) {
                ConsoleStyle.print_error (e.message);
                return 1;
            }
        }
    }
}
