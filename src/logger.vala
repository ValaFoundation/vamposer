namespace Vamposer {
    public class Logger : Object {
        public static void log (string format, ...) {
            var args = va_list ();
            var line = format.vprintf (args);
            log_line (line);
        }

        public static string style_log_line (string line) {
            return ConsoleStyle.style_log_line (line);
        }

        public static void log_line (string line) {
            stdout.printf ("%s", style_log_line (line));
        }

        public static void success (string message) {
            ConsoleStyle.print_success (message);
        }

        public static void info (string message) {
            ConsoleStyle.print_info (message);
        }

        public static void warning (string message) {
            ConsoleStyle.print_warning (message);
        }

        public static void error (string message) {
            ConsoleStyle.print_error (message);
        }

        public static void version (string version) {
            ConsoleStyle.print_version (version);
        }

        public static void stdout_line (string message) {
            stdout.printf ("%s\n", message);
        }

        public static void stderr_line (string message) {
            stderr.printf ("%s\n", message);
        }

        public static void stderr_newline () {
            stderr.printf ("\n");
        }
    }
}
