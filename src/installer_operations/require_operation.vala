namespace Vamposer.InstallerOperations {
    public class RequireOperation : Object {
        public void execute (Installer installer, string config_path, string source_id, string revision = "*", bool include_dev = false) throws Error {
            installer.ensure_subprojects_directory ();

            var config = installer.load_or_create_config (config_path);
            if (include_dev) {
                config.dev_dependencies.set (source_id, revision);
            } else {
                config.dependencies.set (source_id, revision);
            }
            config.save (config_path);

            var resolved_dependencies = installer.build_resolved_dependencies (config, include_dev);
            installer.write_vamposer_build (resolved_dependencies);
            installer.log ("[Vamposer] Added dependency: %s (%s)\n", source_id, revision);
        }
    }
}
