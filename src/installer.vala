using Gee;

namespace Vamposer {
    public class ResolvedDependency : Object {
        public string source_id { get; construct; }
        public string revision { get; construct; }
        public string repository_url { get; construct; }
        public string project_name { get; construct; }
        public string local_directory { get; construct; }

        public ResolvedDependency (string source_id, string revision, string repository_url, string project_name, string local_directory) {
            Object (
                source_id: source_id,
                revision: revision,
                repository_url: repository_url,
                project_name: project_name,
                local_directory: local_directory
            );
        }
    }

    public class Installer : Object {
        public static bool logs_enabled { get; set; default = true; }

        public void init_config (string config_path) throws Error {
            ensure_subprojects_directory ();

            if (FileUtils.test (config_path, FileTest.EXISTS)) {
                throw new IOError.EXISTS ("Config file already exists: %s".printf (config_path));
            }

            var config = PackageConfig.create_empty ();
            config.save (config_path);
            log ("[Vamposer] Initialized config: %s\n", config_path);
        }

        public void install (string config_path) throws Error {
            run_install (config_path, null, false);
        }

        public void require_dependency (string config_path, string source_id, string revision = "*") throws Error {
            ensure_subprojects_directory ();

            var config = load_or_create_config (config_path);
            config.dependencies.set (source_id, revision);
            config.save (config_path);

            var resolved_dependencies = build_resolved_dependencies (config);
            write_vamposer_build (resolved_dependencies);
            log ("[Vamposer] Added dependency: %s (%s)\n", source_id, revision);
        }

        public void remove_dependency (string config_path, string source_id) throws Error {
            ensure_subprojects_directory ();

            var config = PackageConfig.load (config_path);
            if (!config.dependencies.has_key (source_id)) {
                throw new IOError.NOT_FOUND ("Dependency not found: %s".printf (source_id));
            }

            var resolved = DependencyResolver.resolve (source_id, config.dependencies.get (source_id));
            config.dependencies.unset (source_id);
            config.save (config_path);

            remove_path_if_exists (Path.build_filename ("subprojects", "%s.wrap".printf (resolved.project_name)));
            remove_path_if_exists (resolved.local_directory);

            var resolved_dependencies = build_resolved_dependencies (config);
            write_vamposer_build (resolved_dependencies);
            log ("[Vamposer] Removed dependency: %s\n", source_id);
        }

        public void update (string config_path, string? source_id = null) throws Error {
            run_install (config_path, source_id, true);
        }

        private void run_install (string config_path, string? only_source_id, bool force_reclone) throws Error {
            log ("[Vamposer] Loading config %s\n", config_path);
            var config = PackageConfig.load (config_path);

            ensure_subprojects_directory ();
            check_system_dependencies (config.system_dependencies);

            if (only_source_id != null && !config.dependencies.has_key (only_source_id)) {
                throw new IOError.NOT_FOUND ("Dependency not found: %s".printf (only_source_id));
            }

            var resolved_dependencies = new ArrayList<ResolvedDependency> ();
            foreach (var entry in config.dependencies.entries) {
                var resolved = DependencyResolver.resolve (entry.key, entry.value);
                var should_force = force_reclone && (only_source_id == null || only_source_id == entry.key);
                sync_dependency (resolved, should_force);
                write_wrap_file (resolved);
                resolved_dependencies.add (resolved);
            }

            write_vamposer_build (resolved_dependencies);
            log ("[Vamposer] Done. Git dependencies: %u\n", resolved_dependencies.size);
        }

        private PackageConfig load_or_create_config (string config_path) throws Error {
            if (FileUtils.test (config_path, FileTest.EXISTS)) {
                return PackageConfig.load (config_path);
            }

            var config = PackageConfig.create_empty ();
            config.save (config_path);
            return config;
        }

        private ArrayList<ResolvedDependency> build_resolved_dependencies (PackageConfig config) {
            var resolved_dependencies = new ArrayList<ResolvedDependency> ();
            foreach (var entry in config.dependencies.entries) {
                resolved_dependencies.add (DependencyResolver.resolve (entry.key, entry.value));
            }

            return resolved_dependencies;
        }

        private void ensure_subprojects_directory () throws Error {
            DirUtils.create_with_parents ("subprojects", 0755);
        }

        private void check_system_dependencies (HashMap<string, string> system_dependencies) throws Error {
            if (system_dependencies.size == 0) {
                log ("[Vamposer] system_dependencies is empty, skipping checks\n");
                return;
            }

            log ("[Vamposer] Checking system dependencies\n");
            var missing = new ArrayList<string> ();

            foreach (var entry in system_dependencies.entries) {
                var pkg_name = entry.key;
                var version_constraint = entry.value.strip ();
                var query = build_pkg_config_query (pkg_name, version_constraint);
                if (!check_pkg_config_exists (query)) {
                    missing.add (query);
                }
            }

            if (missing.size > 0) {
                var joined_builder = new StringBuilder ();
                foreach (var item in missing) {
                    if (joined_builder.len > 0) {
                        joined_builder.append ("\n");
                    }
                    joined_builder.append (item);
                }

                throw new IOError.FAILED (
                    "Missing required system dependencies:\n%s\nInstall the corresponding -dev/-devel packages for your distribution.".printf (joined_builder.str)
                );
            }

            log ("[Vamposer] System dependencies are satisfied\n");
        }

        private string build_pkg_config_query (string pkg_name, string version_constraint) {
            if (version_constraint == "" || version_constraint == "*") {
                return pkg_name;
            }
            return "%s %s".printf (pkg_name, version_constraint);
        }

        private bool check_pkg_config_exists (string query) throws Error {
            string? std_out;
            string? std_err;
            int status = 0;
            var argv = new string[] {"pkg-config", "--exists", query};

            try {
                Process.spawn_sync (null, argv, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
            } catch (SpawnError e) {
                throw new IOError.FAILED ("Unable to execute pkg-config: %s".printf (e.message));
            }

            return Process.if_exited (status) && Process.exit_status (status) == 0;
        }

        private void sync_dependency (ResolvedDependency dependency, bool force_reclone) throws Error {
            var directory_exists = FileUtils.test (dependency.local_directory, FileTest.IS_DIR);
            if (directory_exists && force_reclone) {
                remove_path_if_exists (dependency.local_directory);
                directory_exists = false;
            }

            if (directory_exists) {
                log ("[Vamposer] Skipping clone, directory already exists: %s\n", dependency.local_directory);
                return;
            }

            var cleaned_revision = dependency.revision.strip ();
            if (cleaned_revision != "" && cleaned_revision != "*") {
                var argv = new string[] {
                    "git",
                    "clone",
                    "--depth",
                    "1",
                    "--branch",
                    cleaned_revision,
                    dependency.repository_url,
                    dependency.local_directory,
                };

                run_command (argv, "git clone for %s".printf (dependency.source_id));
            } else {
                var argv = new string[] {
                    "git",
                    "clone",
                    "--depth",
                    "1",
                    dependency.repository_url,
                    dependency.local_directory,
                };

                run_command (argv, "git clone for %s".printf (dependency.source_id));
            }

            log ("[Vamposer] Downloaded %s -> %s\n", dependency.source_id, dependency.local_directory);
        }

        private void remove_path_if_exists (string path) throws Error {
            if (!FileUtils.test (path, FileTest.EXISTS)) {
                return;
            }

            if (FileUtils.test (path, FileTest.IS_DIR)) {
                run_command (new string[] {"rm", "-rf", path}, "remove directory");
            } else {
                FileUtils.remove (path);
            }
        }

        private void run_command (string[] argv, string label) throws Error {
            string? std_out;
            string? std_err;
            int status = 0;

            try {
                Process.spawn_sync (null, argv, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
            } catch (SpawnError e) {
                throw new IOError.FAILED ("Unable to execute command '%s': %s".printf (label, e.message));
            }

            if (!Process.if_exited (status) || Process.exit_status (status) != 0) {
                var err = std_err != null ? std_err.strip () : "";
                if (err == "") {
                    err = "command returned a non-zero exit code";
                }
                throw new IOError.FAILED ("%s failed: %s".printf (label, err));
            }
        }

        private void write_wrap_file (ResolvedDependency dependency) throws Error {
            var wrap_path = Path.build_filename ("subprojects", "%s.wrap".printf (dependency.project_name));

            if (has_wrap_for_directory (dependency.project_name, wrap_path)) {
                log (
                    "[Vamposer] Skipping wrap generation for %s, an existing wrap already targets directory '%s'\n",
                    dependency.project_name,
                    dependency.project_name
                );
                return;
            }

            var dep_symbol = "%s_dep".printf (sanitize_symbol (dependency.project_name));
            var wrap_contents = """
[wrap-file]
directory = %s

[provide]
%s = %s
""".printf (dependency.project_name, dependency.project_name, dep_symbol);

            FileUtils.set_contents (wrap_path, wrap_contents);
            log ("[Vamposer] Generated wrap file: %s\n", wrap_path);
        }

        private bool has_wrap_for_directory (string directory_name, string current_wrap_path) {
            Dir? subprojects_dir = null;
            try {
                subprojects_dir = Dir.open ("subprojects");
            } catch (FileError e) {
                return false;
            }

            string? entry_name;
            while ((entry_name = subprojects_dir.read_name ()) != null) {
                if (!entry_name.has_suffix (".wrap")) {
                    continue;
                }

                var candidate_path = Path.build_filename ("subprojects", entry_name);
                if (candidate_path == current_wrap_path) {
                    continue;
                }

                string contents;
                try {
                    FileUtils.get_contents (candidate_path, out contents);
                } catch (FileError e) {
                    continue;
                }

                foreach (var line in contents.split ("\n")) {
                    var trimmed = line.strip ();
                    if (trimmed.has_prefix ("directory")) {
                        var parts = trimmed.split ("=");
                        if (parts.length >= 2 && parts[1].strip () == directory_name) {
                            return true;
                        }
                    }
                }
            }

            return false;
        }

        private void write_vamposer_build (ArrayList<ResolvedDependency> dependencies) throws Error {
            var builder = new StringBuilder ();
            builder.append ("# THIS FILE IS AUTO-GENERATED BY VAMPOSER. DO NOT EDIT.\n");
            builder.append ("vamposer_deps = [\n");

            foreach (var dependency in dependencies) {
                var dep_symbol = "%s_dep".printf (sanitize_symbol (dependency.project_name));
                builder.append ("  dependency('%s', fallback: ['%s', '%s']),\n".printf (
                    dependency.project_name,
                    dependency.project_name,
                    dep_symbol
                ));
            }

            builder.append ("]\n");

            var root_helper_path = "vamposer.build";
            FileUtils.set_contents (root_helper_path, builder.str);
            log ("[Vamposer] Generated file: %s\n", root_helper_path);

            var helper_path = Path.build_filename ("subprojects", "vamposer.build");
            FileUtils.set_contents (helper_path, builder.str);
            log ("[Vamposer] Generated file: %s\n", helper_path);

            var root_vamposer_dir = "vamposer";
            DirUtils.create_with_parents (root_vamposer_dir, 0755);

            var root_meson_path = Path.build_filename (root_vamposer_dir, "meson.build");
            var root_meson_builder = new StringBuilder ();
            root_meson_builder.append ("# This file is generated by Vamposer.\n");
            root_meson_builder.append ("# It exposes `vamposer_deps` for `subdir('vamposer')`.\n");
            root_meson_builder.append (builder.str);
            FileUtils.set_contents (root_meson_path, root_meson_builder.str);
            log ("[Vamposer] Generated file: %s\n", root_meson_path);

            var vamposer_subdir = Path.build_filename ("subprojects", "vamposer");
            DirUtils.create_with_parents (vamposer_subdir, 0755);

            var meson_path = Path.build_filename (vamposer_subdir, "meson.build");
            var meson_builder = new StringBuilder ();
            meson_builder.append ("# This file is generated by Vamposer.\n");
            meson_builder.append ("# It exposes `vamposer_deps` for `subdir('subprojects/vamposer')`.\n");
            meson_builder.append (builder.str);
            FileUtils.set_contents (meson_path, meson_builder.str);
            log ("[Vamposer] Generated file: %s\n", meson_path);
        }

        private void log (string format, ...) {
            if (!logs_enabled) {
                return;
            }

            var args = va_list ();
            stdout.vprintf (format, args);
        }

        private string sanitize_symbol (string name) {
            return name.replace ("-", "_").replace (".", "_");
        }
    }
}
