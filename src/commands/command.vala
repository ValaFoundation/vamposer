namespace Vamposer.Commands {
    public delegate void UsagePrinter ();

    public interface CliCommand : Object {
        public abstract int execute (string[] args, UsagePrinter print_usage);
    }
}
