namespace Vamposer.InstallerOperations {
    public class InitOperation : Object {
        public void execute (Installer installer, string config_path) throws Error {
            installer.ensure_subprojects_directory ();

            if (FileUtils.test (config_path, FileTest.EXISTS)) {
                throw new IOError.EXISTS ("Config file already exists: %s".printf (config_path));
            }

            var config = PackageConfig.create_empty ();
            config.save (config_path);
            installer.log ("[Vamposer] Initialized config: %s\n", config_path);
        }
    }
}
