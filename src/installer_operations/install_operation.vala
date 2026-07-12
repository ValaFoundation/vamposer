namespace Vamposer.InstallerOperations {
    public class InstallOperation : Object {
        public void execute (Installer installer, string config_path, bool include_dev = false) throws Error {
            installer.run_install (config_path, null, false, include_dev);
        }
    }
}
