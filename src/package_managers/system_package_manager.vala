using Gee;

namespace Vamposer.PackageManagers {
    public interface SystemPackageManager : Object {
        public abstract string id { get; }
        public virtual bool is_supported_on_current_platform () {
            return true;
        }
        public abstract bool is_available ();
        public abstract string[] build_install_command (string package_name);
        public abstract ArrayList<string> get_aliases (string pkg_config_name);

        public virtual string? build_pkgconfig_requirement (string pkg_config_name, string version_constraint) {
            return null;
        }
    }
}
