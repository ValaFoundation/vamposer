namespace Vamposer.InstallerOperations {
    public class RequireOperation : Object {
        public void execute (Installer installer, string config_path, string source_id, string revision = "*") throws Error {
            installer.ensure_subprojects_directory ();

            var config = installer.load_or_create_config (config_path);
            config.dependencies.set (source_id, revision);
            config.save (config_path);

            var resolved_dependencies = installer.build_resolved_dependencies (config);
            installer.write_vamposer_build (resolved_dependencies);
            installer.log ("[Vamposer] Added dependency: %s (%s)\n", source_id, revision);
        }
    }
}
