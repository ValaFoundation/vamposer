using Gee;
using Vamposer.PackageManagers;

namespace Vamposer {
    public class SystemDependencyInstaller : Object {
        public bool logs_enabled { get; set; default = true; }
        private CommandRunner command_runner;

        public SystemDependencyInstaller () {
            command_runner = new CommandRunner ();
        }

        public void install_missing (HashMap<string, string> missing_dependencies) {
            var package_manager = detect_package_manager ();
            if (package_manager == null) {
                log ("[Vamposer] No supported package manager detected; skipping auto-install attempt\n");
                return;
            }

            log ("[Vamposer] Attempting to auto-install missing system dependencies via %s\n", package_manager.id);

            foreach (var entry in missing_dependencies.entries) {
                var pkg_name = entry.key;
                var version_constraint = entry.value.strip ();
                var candidates = get_system_package_candidates (pkg_name, version_constraint, package_manager.id);
                var installed = false;

                foreach (var candidate in candidates) {
                    if (install_single_system_package (package_manager, candidate)) {
                        installed = true;
                        break;
                    }
                }

                if (!installed) {
                    log ("[Vamposer] Unable to auto-install dependency for pkg-config name: %s\n", pkg_name);
                }
            }
        }

        public string[]? build_install_command (string package_manager, string package_name) {
            var manager = get_manager_by_id (package_manager);
            if (manager == null) {
                return null;
            }

            return manager.build_install_command (package_name);
        }

        public ArrayList<string> get_system_package_candidates (string pkg_config_name, string version_constraint, string package_manager) {
            var candidates = new ArrayList<string> ();
            var manager = get_manager_by_id (package_manager);

            if (manager == null) {
                candidates.add (pkg_config_name);
                return candidates;
            }

            var rpm_requirement = manager.build_pkgconfig_requirement (pkg_config_name, version_constraint);
            if (rpm_requirement != null) {
                candidates.add (rpm_requirement);
            }

            foreach (var alias_name in manager.get_aliases (pkg_config_name)) {
                if (!candidates.contains (alias_name)) {
                    candidates.add (alias_name);
                }
            }

            if (!candidates.contains (pkg_config_name)) {
                candidates.add (pkg_config_name);
            }

            return candidates;
        }

        private bool install_single_system_package (SystemPackageManager package_manager, string package_name) {
            var full_command = package_manager.build_install_command (package_name);

            try {
                command_runner.run (full_command, "install system package");
                log ("[Vamposer] Installed system package: %s\n", package_name);
                return true;
            } catch (Error e) {
                if (command_runner.command_exists ("sudo")) {
                    var sudo_command = new ArrayList<string> ();
                    sudo_command.add ("sudo");
                    sudo_command.add ("-n");
                    foreach (var token in full_command) {
                        sudo_command.add (token);
                    }

                    try {
                        command_runner.run (sudo_command.to_array (), "install system package with sudo");
                        log ("[Vamposer] Installed system package with sudo: %s\n", package_name);
                        return true;
                    } catch (Error sudo_error) {
                        log ("[Vamposer] Failed to install package '%s' (sudo): %s\n", package_name, sudo_error.message);
                        return false;
                    }
                }

                log ("[Vamposer] Failed to install package '%s': %s\n", package_name, e.message);
                return false;
            }
        }

        private SystemPackageManager? detect_package_manager () {
            foreach (var manager in build_supported_managers ()) {
                if (manager.is_available ()) {
                    return manager;
                }
            }

            return null;
        }

        private SystemPackageManager? get_manager_by_id (string id) {
            foreach (var manager in build_supported_managers (true)) {
                if (manager.id == id) {
                    return manager;
                }
            }

            return null;
        }

        private ArrayList<SystemPackageManager> build_supported_managers (bool include_cross_platform = false) {
            var managers = new ArrayList<SystemPackageManager> ();

            // Used by autodetection: include only managers that make sense on the current OS.
            // Used by explicit ID lookup/tests: include all managers for deterministic behavior.
            if (!include_cross_platform) {
#if WINDOWS
                managers.add (new WindowsPackageManager ());
#else
                managers.add (new AptPackageManager ());
                managers.add (new DnfPackageManager ());
                managers.add (new YumPackageManager ());
                managers.add (new PacmanPackageManager ());
                managers.add (new ZypperPackageManager ());
                managers.add (new ApkPackageManager ());
                managers.add (new FlatpakPackageManager ());
#endif
                return managers;
            }

            managers.add (new AptPackageManager ());
            managers.add (new DnfPackageManager ());
            managers.add (new YumPackageManager ());
            managers.add (new PacmanPackageManager ());
            managers.add (new ZypperPackageManager ());
            managers.add (new ApkPackageManager ());
            managers.add (new FlatpakPackageManager ());
            managers.add (new WindowsPackageManager ());
            return managers;
        }

        private void log (string format, ...) {
            if (!logs_enabled) {
                return;
            }

            var args = va_list ();
            stdout.vprintf (format, args);
        }
    }
}
