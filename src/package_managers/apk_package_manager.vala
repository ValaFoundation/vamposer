namespace Vamposer.PackageManagers {
    public class ApkPackageManager : BaseSystemPackageManager {
        public override string id { get { return "apk"; } }

        protected override string[] base_install_args () {
            return new string[] {"apk", "add"};
        }

        protected override string map_glib_package_name () {
            return "glib-dev";
        }

        protected override string map_gtk4_package_name () {
            return "gtk4-dev";
        }

        protected override string map_libadwaita_package_name () {
            return "libadwaita-dev";
        }

        protected override string map_gee_package_name () {
            return "libgee-dev";
        }
    }
}
