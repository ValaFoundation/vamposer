namespace AppTests {
    using GLib;
    using ValaFoundation.Testcases;
    using Vamposer;
    using Vamposer.Commands;

    public class CommandsTest : BaseTest {
        construct {
            add_test ("help_command_invokes_usage", test_help_command_invokes_usage);
            add_test ("init_command_creates_custom_config", test_init_command_creates_custom_config);
            add_test ("install_command_uses_custom_config", test_install_command_uses_custom_config);
            add_test ("require_command_missing_dependency_returns_error", test_require_command_missing_dependency_returns_error);
            add_test ("require_command_writes_dependency", test_require_command_writes_dependency);
            add_test ("remove_command_missing_dependency_returns_error", test_remove_command_missing_dependency_returns_error);
            add_test ("update_command_missing_named_dependency_returns_error", test_update_command_missing_named_dependency_returns_error);
            add_test ("self_upgrade_command_unknown_executable_returns_error", test_self_upgrade_command_unknown_executable_returns_error);
        }

        public void test_help_command_invokes_usage () {
            var command = new HelpCommand ();
            var usage_called = false;
            var exit_code = command.execute (new string[] {"vamposer", "help"}, () => {
                usage_called = true;
            });

            assert (exit_code == 0);
            assert (usage_called);
        }

        public void test_init_command_creates_custom_config () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);
            try {
                var command = new InitCommand ();
                var usage_called = false;
                var config_path = Path.build_filename (project_dir, "custom-vamposer.json");
                var exit_code = command.execute (new string[] {"vamposer", "init", config_path}, () => {
                    usage_called = true;
                });

                assert (exit_code == 0);
                assert (!usage_called);
                assert (FileUtils.test (config_path, FileTest.EXISTS));
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_install_command_uses_custom_config () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);
            try {
                var config_path = Path.build_filename (project_dir, "custom-vamposer.json");
                try {
                    FileUtils.set_contents (config_path, """
{
  "name": "com.example.app",
  "version": "0.0.1",
  "dependencies": {},
  "system_dependencies": {
    "glib-2.0": "*"
  }
}
""");
                } catch (Error e) {
                    assert_not_reached ();
                }

                var command = new InstallCommand ();
                var usage_called = false;
                var exit_code = command.execute (new string[] {"vamposer", "install", config_path}, () => {
                    usage_called = true;
                });

                assert (exit_code == 0);
                assert (!usage_called);
                assert (FileUtils.test (Path.build_filename (project_dir, "subprojects", "vamposer.build"), FileTest.EXISTS));
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_require_command_missing_dependency_returns_error () {
            var command = new RequireCommand ();
            var usage_called = false;
            var exit_code = command.execute (new string[] {"vamposer", "require"}, () => {
                usage_called = true;
            });

            assert (exit_code == 1);
            assert (usage_called);
        }

        public void test_require_command_writes_dependency () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);
            try {
                var config_path = Path.build_filename (project_dir, "custom-vamposer.json");
                var command = new RequireCommand ();
                var usage_called = false;
                var exit_code = command.execute (
                    new string[] {"vamposer", "require", "github.com/ValaFoundation/testcases", "master", config_path},
                    () => { usage_called = true; }
                );

                assert (exit_code == 0);
                assert (!usage_called);

                try {
                    var config = PackageConfig.load (config_path);
                    assert (config.dependencies.get ("github.com/ValaFoundation/testcases") == "master");
                } catch (Error e) {
                    assert_not_reached ();
                }
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_remove_command_missing_dependency_returns_error () {
            var command = new RemoveCommand ();
            var usage_called = false;
            var exit_code = command.execute (new string[] {"vamposer", "remove"}, () => {
                usage_called = true;
            });

            assert (exit_code == 1);
            assert (usage_called);
        }

        public void test_update_command_missing_named_dependency_returns_error () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);
            try {
                var config_path = Path.build_filename (project_dir, "custom-vamposer.json");
                try {
                    FileUtils.set_contents (config_path, """
{
  "dependencies": {},
  "system_dependencies": {
    "glib-2.0": "*"
  }
}
""");
                } catch (Error e) {
                    assert_not_reached ();
                }

                var command = new UpdateCommand ();
                var usage_called = false;
                var exit_code = command.execute (
                    new string[] {"vamposer", "update", "github.com/ValaFoundation/testcases", config_path},
                    () => { usage_called = true; }
                );

                assert (exit_code == 1);
                assert (!usage_called);
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_self_upgrade_command_unknown_executable_returns_error () {
            var command = new SelfUpgradeCommand ();
            var usage_called = false;
            var exit_code = command.execute (
                new string[] {"vamposer-this-command-should-not-exist", "self-upgrade"},
                () => { usage_called = true; }
            );

            assert (exit_code == 1);
            assert (!usage_called);
        }
    }
}
