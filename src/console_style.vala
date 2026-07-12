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

            if (message.contains ("Done.") || message.contains ("Upgraded executable") || message.contains ("Installed system package")) {
                return colorize (styled, "32");
            }

            return styled;
        }

        public static void print_error (string message) {
            var line = "[Vamposer] Error: %s".printf (message);
            stderr.printf ("%s\n", colorize (colorize_prefix (line), "31"));
        }
    }
}
