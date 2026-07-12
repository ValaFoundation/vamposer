namespace Vamposer.PackageManagers {
    public class YumPackageManager : DnfPackageManager {
        public override string id { get { return "yum"; } }

        protected override string[] base_install_args () {
            return new string[] {"yum", "install", "-y"};
        }
    }
}
