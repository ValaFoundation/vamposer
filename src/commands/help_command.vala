namespace Vamposer.Commands {
    public class HelpCommand : Object, CliCommand {
        public int execute (string[] args, UsagePrinter print_usage) {
            print_usage ();
            return 0;
        }
    }
}
