namespace Vamposer.InstallerOperations {
    public class RemoveOperation : Object {
        public void execute (Installer installer, string config_path, string source_id) throws Error {
            installer.ensure_subprojects_directory ();

            var config = PackageConfig.load (config_path);
            if (!config.dependencies.has_key (source_id)) {
                throw new IOError.NOT_FOUND ("Dependency not found: %s".printf (source_id));
            }

            var resolved = DependencyResolver.resolve (source_id, config.dependencies.get (source_id));
            config.dependencies.unset (source_id);
            config.save (config_path);

            installer.remove_path_if_exists (Path.build_filename ("subprojects", "%s.wrap".printf (resolved.project_name)));
            installer.remove_path_if_exists (resolved.local_directory);

            var resolved_dependencies = installer.build_resolved_dependencies (config);
            installer.write_vamposer_build (resolved_dependencies);
            installer.log ("[Vamposer] Removed dependency: %s\n", source_id);
        }
    }
}
