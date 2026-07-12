namespace Vamposer.PackageManagers {
    public class WindowsPackageManager : BaseSystemPackageManager {
        public override string id { get { return "winget"; } }

        protected override string[] base_install_args () {
            return new string[] {
                "winget",
                "install",
                "--silent",
                "--accept-source-agreements",
                "--accept-package-agreements",
            };
        }

        public override bool is_available () {
            string? std_out;
            string? std_err;
            int status = 0;

            try {
#if WINDOWS
                Process.spawn_sync (null, new string[] {"cmd", "/c", "where", "winget"}, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
#else
                Process.spawn_sync (null, new string[] {"which", "winget"}, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
#endif
            } catch (SpawnError e) {
                return false;
            }

            return status == 0;
        }
    }
}
