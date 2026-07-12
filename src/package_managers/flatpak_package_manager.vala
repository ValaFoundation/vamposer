namespace Vamposer.PackageManagers {
    public class FlatpakPackageManager : BaseSystemPackageManager {
        public override string id { get { return "flatpak"; } }

        protected override string[] base_install_args () {
            return new string[] {"flatpak", "install", "-y", "flathub"};
        }
    }
}
