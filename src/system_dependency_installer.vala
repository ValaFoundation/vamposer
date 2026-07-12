using Gee;
using Vamposer.PackageManagers;

namespace Vamposer {
    public class SystemDependencyInstaller : Object {
        public bool logs_enabled { get; set; default = true; }

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

            string? std_out;
            string? std_err;
            int status = 0;
            var attempted_with_sudo = false;

            try {
                Process.spawn_sync (null, full_command, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
            } catch (SpawnError e) {
                log ("[Vamposer] Auto-install attempt failed to start: %s\n", e.message);
                return false;
            }

            if (status != 0 && command_exists ("sudo")) {
                attempted_with_sudo = true;
                var sudo_command = new ArrayList<string> ();
                sudo_command.add ("sudo");
                sudo_command.add ("-n");
                foreach (var token in full_command) {
                    sudo_command.add (token);
                }

                try {
                    Process.spawn_sync (null, sudo_command.to_array (), null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
                } catch (SpawnError e) {
                    log ("[Vamposer] Auto-install with sudo failed to start: %s\n", e.message);
                    return false;
                }
            }

            if (status == 0) {
                log ("[Vamposer] Installed system package: %s\n", package_name);
                return true;
            }

            var err = std_err != null ? std_err.strip () : "";
            if (err == "") {
                err = "command returned a non-zero exit code";
            }

            if (attempted_with_sudo) {
                log ("[Vamposer] Failed to install package '%s' (sudo): %s\n", package_name, err);
            } else {
                log ("[Vamposer] Failed to install package '%s': %s\n", package_name, err);
            }

            return false;
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
            foreach (var manager in build_supported_managers ()) {
                if (manager.id == id) {
                    return manager;
                }
            }

            return null;
        }

        private ArrayList<SystemPackageManager> build_supported_managers () {
            var managers = new ArrayList<SystemPackageManager> ();
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

        private bool command_exists (string name) {
            string? std_out;
            string? std_err;
            int status = 0;

            try {
                Process.spawn_sync (null, new string[] {"which", name}, null, SpawnFlags.SEARCH_PATH, null, out std_out, out std_err, out status);
            } catch (SpawnError e) {
                return false;
            }

            return status == 0;
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
