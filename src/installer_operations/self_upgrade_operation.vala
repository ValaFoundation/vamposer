namespace Vamposer.InstallerOperations {
    public class SelfUpgradeOperation : Object {
        public void execute (Installer installer, string executable_name) throws Error {
            var target_path = installer.resolve_executable_path (executable_name);
            var release_binary_name = installer.get_release_binary_name ();
            var release_checksum_name = "%s.sha256".printf (release_binary_name);

            string temp_dir;
            try {
                temp_dir = DirUtils.make_tmp ("vamposer-upgrade-XXXXXX");
            } catch (FileError e) {
                throw new IOError.FAILED ("Unable to create temporary directory: %s".printf (e.message));
            }

            var cleanup_temp_dir = true;
            try {
                var binary_url = "%s/%s".printf (Installer.RELEASE_DOWNLOAD_BASE, release_binary_name);
                var checksum_url = "%s/%s".printf (Installer.RELEASE_DOWNLOAD_BASE, release_checksum_name);
                var downloaded_path = Path.build_filename (temp_dir, release_binary_name);
                var checksum_path = Path.build_filename (temp_dir, release_checksum_name);

                installer.command_runner.run (new string[] {"curl", "-fL", "-o", downloaded_path, binary_url}, "download latest Vamposer binary");
                installer.command_runner.run (new string[] {"curl", "-fL", "-o", checksum_path, checksum_url}, "download latest Vamposer checksum");

                var expected_checksum = installer.read_checksum_value (checksum_path);
                var actual_checksum = installer.calculate_sha256 (downloaded_path);
                if (expected_checksum != actual_checksum) {
                    throw new IOError.FAILED ("Downloaded Vamposer checksum mismatch");
                }

#if WINDOWS
                installer.schedule_windows_replacement (downloaded_path, target_path, temp_dir);
                cleanup_temp_dir = false;
                installer.log ("[Vamposer] Upgrade scheduled for executable: %s\n", target_path);
#else
                installer.command_runner.run (new string[] {"sudo", "install", "-m", "0755", downloaded_path, target_path}, "install upgraded Vamposer binary via sudo");
                installer.log ("[Vamposer] Upgraded executable: %s\n", target_path);
                refresh_completion_after_upgrade (installer);
#endif
            } finally {
                if (cleanup_temp_dir) {
                    try {
                        installer.remove_path_if_exists (temp_dir);
                    } catch (Error e) {
                        installer.log ("[Vamposer] Cleanup warning: %s\n", e.message);
                    }
                }
            }
        }

        private void refresh_completion_after_upgrade (Installer installer) {
            try {
                var completion_result = CompletionInstaller.install_for_current_user (true);
                switch (completion_result) {
                case CompletionInstallResult.INSTALLED:
                    installer.log ("[Vamposer] Shell completion refreshed for current user\n");
                    break;
                case CompletionInstallResult.ALREADY_INSTALLED:
                    installer.log ("[Vamposer] Shell completion already up to date\n");
                    break;
                case CompletionInstallResult.SKIPPED_UNSUPPORTED_PLATFORM:
                    installer.log ("[Vamposer] Completion refresh skipped on this platform\n");
                    break;
                case CompletionInstallResult.SKIPPED_UNSUPPORTED_SHELL:
                    installer.log ("[Vamposer] Completion refresh skipped: unsupported shell\n");
                    break;
                case CompletionInstallResult.SKIPPED_DISABLED:
                    installer.log ("[Vamposer] Completion refresh skipped: disabled by environment\n");
                    break;
                default:
                    installer.log ("[Vamposer] Completion refresh skipped: unknown result\n");
                    break;
                }
            } catch (Error e) {
                installer.log ("[Vamposer] Completion refresh warning: %s\n", e.message);
            }
        }
    }
}
