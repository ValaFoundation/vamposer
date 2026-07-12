using Gee;

namespace Vamposer.PackageManagers {
    public abstract class BaseSystemPackageManager : Object, SystemPackageManager {
        public abstract string id { get; }

        protected abstract string[] base_install_args ();

        public virtual bool is_available () {
            string? std_out;
            string? std_err;
            int status = 0;

            try {
                Process.spawn_sync (null, new string[] {"which", id}, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
            } catch (SpawnError e) {
                return false;
            }

            return status == 0;
        }

        public string[] build_install_command (string package_name) {
            var args = new ArrayList<string> ();
            foreach (var token in base_install_args ()) {
                args.add (token);
            }
            args.add (package_name);
            return args.to_array ();
        }

        public virtual string? build_pkgconfig_requirement (string pkg_config_name, string version_constraint) {
            return null;
        }

        public virtual ArrayList<string> get_aliases (string pkg_config_name) {
            var aliases = new ArrayList<string> ();

            switch (pkg_config_name) {
                case "glib-2.0":
                case "glib2":
                    add_unique (aliases, map_glib_package_name ());
                    add_unique (aliases, "glib-2.0");
                    add_unique (aliases, "glib2");
                    break;
                case "gtk4":
                    add_unique (aliases, map_gtk4_package_name ());
                    add_unique (aliases, "gtk4");
                    break;
                case "libadwaita-1":
                    add_unique (aliases, map_libadwaita_package_name ());
                    add_unique (aliases, "libadwaita-1");
                    break;
                case "gee-0.8":
                    add_unique (aliases, map_gee_package_name ());
                    add_unique (aliases, "gee-0.8");
                    break;
                default:
                    add_unique (aliases, pkg_config_name);
                    break;
            }

            append_generic_fallback_aliases (aliases, pkg_config_name);

            return aliases;
        }

        protected virtual string map_glib_package_name () {
            return "glib2";
        }

        protected virtual string map_gtk4_package_name () {
            return "gtk4";
        }

        protected virtual string map_libadwaita_package_name () {
            return "libadwaita-1";
        }

        protected virtual string map_gee_package_name () {
            return "gee-0.8";
        }

        private void append_generic_fallback_aliases (ArrayList<string> aliases, string pkg_config_name) {
            add_fallback_for_base_name (aliases, pkg_config_name);

            var without_version_suffix = strip_trailing_version_suffix (pkg_config_name);
            if (without_version_suffix != pkg_config_name) {
                add_fallback_for_base_name (aliases, without_version_suffix);
            }
        }

        private void add_fallback_for_base_name (ArrayList<string> aliases, string base_name) {
            var normalized = base_name.strip ();
            if (normalized == "") {
                return;
            }

            add_unique (aliases, normalized);
            foreach (var suffix in preferred_dev_suffixes ()) {
                add_unique (aliases, "%s%s".printf (normalized, suffix));
            }

            if (!normalized.has_prefix ("lib")) {
                add_unique (aliases, "lib%s".printf (normalized));
                foreach (var suffix in preferred_dev_suffixes ()) {
                    add_unique (aliases, "lib%s%s".printf (normalized, suffix));
                }
            }
        }

        protected virtual string[] preferred_dev_suffixes () {
            return new string[] {"-dev", "-devel"};
        }

        private string strip_trailing_version_suffix (string name) {
            var last_dash = name.last_index_of_char ('-');
            if (last_dash <= 0 || last_dash >= name.length - 1) {
                return name;
            }

            var suffix = name.substring (last_dash + 1);
            if (!is_numeric_dot_suffix (suffix)) {
                return name;
            }

            return name.substring (0, last_dash);
        }

        private bool is_numeric_dot_suffix (string suffix) {
            for (int i = 0; i < suffix.length; i++) {
                var c = suffix[i];
                if (!((c >= '0' && c <= '9') || c == '.')) {
                    return false;
                }
            }

            return suffix != "";
        }

        private void add_unique (ArrayList<string> aliases, string value) {
            if (!aliases.contains (value)) {
                aliases.add (value);
            }
        }
    }
}
