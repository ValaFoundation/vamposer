namespace Vamposer.PackageManagers {
    public class PacmanPackageManager : BaseSystemPackageManager {
        public override string id { get { return "pacman"; } }

        protected override string[] base_install_args () {
            return new string[] {"pacman", "-S", "--needed", "--noconfirm"};
        }

        protected override string map_glib_package_name () {
            return "glib2";
        }

        protected override string map_gtk4_package_name () {
            return "gtk4";
        }

        protected override string map_libadwaita_package_name () {
            return "libadwaita";
        }

        protected override string map_gee_package_name () {
            return "libgee";
        }
    }
}
