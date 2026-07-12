namespace Vamposer {
    public class ConsoleStyle : Object {
        private static bool? colors_enabled_cache = null;

        private static bool colors_enabled () {
            if (colors_enabled_cache != null) {
                return colors_enabled_cache;
            }

            var no_color = Environment.get_variable ("NO_COLOR");
            if (no_color != null) {
                colors_enabled_cache = false;
                return false;
            }

            var color_force = Environment.get_variable ("CLICOLOR_FORCE");
            if (color_force != null && color_force != "0") {
                colors_enabled_cache = true;
                return true;
            }

            var color_pref = Environment.get_variable ("CLICOLOR");
            if (color_pref == "0") {
                colors_enabled_cache = false;
                return false;
            }

            var term = Environment.get_variable ("TERM");
            if (term == null || term == "" || term == "dumb") {
                colors_enabled_cache = false;
                return false;
            }

            colors_enabled_cache = true;
            return true;
        }

        private static string colorize (string text, string code) {
            if (!colors_enabled ()) {
                return text;
            }

            var body = text;
            var trailing_newlines = "";

            while (body.has_suffix ("\n")) {
                body = body.substring (0, body.length - 1);
                trailing_newlines += "\n";
            }

            if (body == "") {
                return text;
            }

            return "\x1b[%sm%s\x1b[0m%s".printf (code, body, trailing_newlines);
        }

        private static string colorize_prefix (string message) {
            if (!colors_enabled ()) {
                return message;
            }

            return message.replace ("[Vamposer]", colorize ("[Vamposer]", "1;36"));
        }

        public static string style_log_line (string message) {
            var styled = colorize_prefix (message);

            if (message.contains ("Warning:")) {
                return colorize (styled, "33");
            }

            if (message.contains ("Error:") || message.contains ("Failed")) {
                return colorize (styled, "31");
            }

            if (message.contains ("Done.")
                || message.contains ("Upgraded executable")
                || message.contains ("Upgrade scheduled")
                || message.contains ("Installed system package")
                || message.contains ("Added dependency")
                || message.contains ("Removed dependency")) {
                return colorize (styled, "32");
            }

            if (message.contains ("Loading config")
                || message.contains ("Checking system dependencies")
                || message.contains ("Attempting to auto-install")
                || message.contains ("Downloaded")
                || message.contains ("Generated file")
                || message.contains ("Generated wrap file")) {
                return colorize (styled, "36");
            }

            return styled;
        }

        public static string style_usage_title (string text) {
            return colorize (text, "1;36");
        }

        public static string style_usage_section (string text) {
            return colorize (text, "1;33");
        }

        public static string style_usage_entry (string text) {
            if (!colors_enabled ()) {
                return text;
            }

            var indent_len = 0;
            while (indent_len < text.length && text[ indent_len ] == ' ') {
                indent_len++;
            }

            var indent = text.substring (0, indent_len);
            var content = text.substring (indent_len);
            if (content.has_prefix ("vamposer")) {
                var command = "vamposer";
                var tail = content.substring (command.length);
                return "%s%s%s".printf (indent, colorize (command, "1;36"), colorize (tail, "32"));
            }

            return "%s%s".printf (indent, colorize (content, "32"));
        }

        public static void print_success (string message) {
            var line = "[Vamposer] %s".printf (message);
            stdout.printf ("%s\n", colorize (colorize_prefix (line), "32"));
        }

        public static void print_info (string message) {
            var line = "[Vamposer] %s".printf (message);
            stdout.printf ("%s\n", colorize (colorize_prefix (line), "36"));
        }

        public static void print_warning (string message) {
            var line = "[Vamposer] Warning: %s".printf (message);
            stdout.printf ("%s\n", colorize (colorize_prefix (line), "33"));
        }

        public static void print_version (string version) {
            var title = colorize ("Vamposer", "1;36");
            var value = colorize (version, "1;32");
            stdout.printf ("%s %s\n", title, value);
        }

        public static void print_error (string message) {
            var line = "[Vamposer] Error: %s".printf (message);
            stderr.printf ("%s\n", colorize (colorize_prefix (line), "31"));
        }
    }
}
