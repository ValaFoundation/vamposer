namespace Vamposer.InstallerOperations {
    public class InstallOperation : Object {
        public void execute (Installer installer, string config_path) throws Error {
            installer.run_install (config_path, null, false);
        }
    }
}
