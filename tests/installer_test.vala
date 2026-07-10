namespace AppTests {
    using GLib;
    using ValaFoundation.Testcases;
    using Vamposer;

    public class InstallerTest : BaseTest {
        construct {
            add_test ("init_creates_config_and_subprojects_gitignore", test_init_creates_config_and_subprojects_gitignore);
            add_test ("install_generates_vamposer_build_without_git", test_install_generates_build_file);
            add_test ("install_fails_on_missing_system_dependency", test_install_fails_on_missing_system_dep);
            add_test ("require_adds_dependency_to_config", test_require_adds_dependency_to_config);
            add_test ("remove_deletes_dependency_from_config", test_remove_deletes_dependency_from_config);
            add_test ("update_fails_when_named_dependency_is_missing", test_update_missing_named_dependency);
        }

        public void test_init_creates_config_and_subprojects_gitignore () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);

            try {
                var config_path = Path.build_filename (project_dir, "vamposer.json");

                try {
                    Installer.logs_enabled = false;
                    var installer = new Installer ();
                    installer.init_config (config_path);
                } catch (Error e) {
                    assert_not_reached ();
                } finally {
                    Installer.logs_enabled = true;
                }

                assert (FileUtils.test (config_path, FileTest.EXISTS));

                var gitignore_path = Path.build_filename (project_dir, "subprojects", ".gitignore");
                assert (FileUtils.test (gitignore_path, FileTest.EXISTS));

                try {
                    var config = PackageConfig.load (config_path);
                    assert (config.dependencies.size == 0);
                    assert (config.system_dependencies.size == 0);
                } catch (Error e) {
                    assert_not_reached ();
                }
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_install_generates_build_file () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);

            try {
                var config_path = Path.build_filename (project_dir, "vamposer.json");
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

                try {
                    Installer.logs_enabled = false;
                    var installer = new Installer ();
                    installer.install (config_path);
                } catch (Error e) {
                    assert_not_reached ();
                } finally {
                    Installer.logs_enabled = true;
                }

                var generated_path = Path.build_filename (project_dir, "subprojects", "vamposer.build");
                assert (FileUtils.test (generated_path, FileTest.EXISTS));

                var gitignore_path = Path.build_filename (project_dir, "subprojects", ".gitignore");
                assert (FileUtils.test (gitignore_path, FileTest.EXISTS));

                string contents;
                try {
                    FileUtils.get_contents (generated_path, out contents);
                } catch (Error e) {
                    assert_not_reached ();
                }

                assert (contents.contains ("vamposer_deps = ["));
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_install_fails_on_missing_system_dep () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);

            try {
                var config_path = Path.build_filename (project_dir, "vamposer.json");
                try {
                    FileUtils.set_contents (config_path, """
{
  "name": "com.example.app",
  "version": "0.0.1",
  "dependencies": {},
  "system_dependencies": {
    "this-package-does-not-exist-xyz": "*"
  }
}
""");
                                } catch (Error e) {
                                        assert_not_reached ();
                                }

                bool failed = false;
                try {
                    Installer.logs_enabled = false;
                    var installer = new Installer ();
                    installer.install (config_path);
                } catch (Error e) {
                    failed = true;
                    assert (e.message.contains ("this-package-does-not-exist-xyz"));
                } finally {
                    Installer.logs_enabled = true;
                }

                assert (failed);
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_require_adds_dependency_to_config () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);

            try {
                var config_path = Path.build_filename (project_dir, "vamposer.json");

                try {
                    Installer.logs_enabled = false;
                    var installer = new Installer ();
                    installer.require_dependency (config_path, "github.com/ValaFoundation/testcases", "master");
                } catch (Error e) {
                    assert_not_reached ();
                } finally {
                    Installer.logs_enabled = true;
                }

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

        public void test_remove_deletes_dependency_from_config () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);

            try {
                var config_path = Path.build_filename (project_dir, "vamposer.json");
                try {
                    FileUtils.set_contents (config_path, """
{
  "dependencies": {
    "github.com/ValaFoundation/testcases": "master"
  },
  "system_dependencies": {}
}
""");
                } catch (Error e) {
                    assert_not_reached ();
                }

                try {
                    Installer.logs_enabled = false;
                    var installer = new Installer ();
                    installer.remove_dependency (config_path, "github.com/ValaFoundation/testcases");
                } catch (Error e) {
                    assert_not_reached ();
                } finally {
                    Installer.logs_enabled = true;
                }

                try {
                    var config = PackageConfig.load (config_path);
                    assert (!config.dependencies.has_key ("github.com/ValaFoundation/testcases"));
                } catch (Error e) {
                    assert_not_reached ();
                }
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }

        public void test_update_missing_named_dependency () {
            var old_cwd = Environment.get_current_dir ();
            string project_dir;
            try {
                project_dir = DirUtils.make_tmp ("vamposer-test-XXXXXX");
            } catch (Error e) {
                assert_not_reached ();
            }

            Environment.set_current_dir (project_dir);

            try {
                var config_path = Path.build_filename (project_dir, "vamposer.json");
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

                bool failed = false;
                try {
                    Installer.logs_enabled = false;
                    var installer = new Installer ();
                    installer.update (config_path, "github.com/ValaFoundation/testcases");
                } catch (Error e) {
                    failed = true;
                    assert (e.message.contains ("Dependency not found"));
                } finally {
                    Installer.logs_enabled = true;
                }

                assert (failed);
            } finally {
                Environment.set_current_dir (old_cwd);
            }
        }
    }
}
