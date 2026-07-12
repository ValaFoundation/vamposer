namespace Vamposer.PackageManagers {
    public class ZypperPackageManager : DnfPackageManager {
        public override string id { get { return "zypper"; } }

        protected override string[] base_install_args () {
            return new string[] {"zypper", "--non-interactive", "install"};
        }

        protected override string map_gee_package_name () {
            return "libgee-0_8-devel";
        }
    }
}
