namespace Vamposer.PackageManagers {
    public class AptPackageManager : BaseSystemPackageManager {
        public override string id { get { return "apt-get"; } }

        protected override string[] base_install_args () {
            return new string[] {"apt-get", "install", "-y"};
        }

        protected override string map_glib_package_name () {
            return "libglib2.0-dev";
        }

        protected override string map_gtk4_package_name () {
            return "libgtk-4-dev";
        }

        protected override string map_libadwaita_package_name () {
            return "libadwaita-1-dev";
        }

        protected override string map_gee_package_name () {
            return "libgee-0.8-dev";
        }
    }
}
