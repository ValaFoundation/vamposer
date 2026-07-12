namespace Vamposer.PackageManagers {
    public class DnfPackageManager : BaseSystemPackageManager {
        public override string id { get { return "dnf"; } }

        protected override string[] base_install_args () {
            return new string[] {"dnf", "install", "-y"};
        }

        public override string? build_pkgconfig_requirement (string pkg_config_name, string version_constraint) {
            if (version_constraint == "" || version_constraint == "*") {
                return "pkgconfig(%s)".printf (pkg_config_name);
            }

            return "pkgconfig(%s) %s".printf (pkg_config_name, version_constraint);
        }

        protected override string map_glib_package_name () {
            return "glib2-devel";
        }

        protected override string map_gtk4_package_name () {
            return "gtk4-devel";
        }

        protected override string map_libadwaita_package_name () {
            return "libadwaita-devel";
        }

        protected override string map_gee_package_name () {
            return "libgee-devel";
        }

        protected override string[] preferred_dev_suffixes () {
            return new string[] {"-devel", "-dev"};
        }
    }
}
