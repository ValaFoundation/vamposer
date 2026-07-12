namespace Vamposer.InstallerOperations {
    public class UpdateOperation : Object {
        public void execute (Installer installer, string config_path, string? source_id = null) throws Error {
            installer.run_install (config_path, source_id, true);
        }
    }
}
