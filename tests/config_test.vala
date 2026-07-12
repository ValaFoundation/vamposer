namespace AppTests {
    using GLib;
    using ValaFoundation.Testcases;
    using Vamposer;

    public class ConfigTest : BaseTest {
        construct {
            add_test ("config_loads_valid_json", test_config_loads_valid_json);
            add_test ("config_fails_on_non_object_dependencies", test_config_fails_on_non_object_dependencies);
        }

        public void test_config_loads_valid_json () {
            string path;
            try {
                path = write_temp_json ("""
{
  "name": "com.example.app",
  "version": "1.2.3",
  "description": "A test app",
  "dependencies": {
    "github.com/ValaFoundation/testcases": "master"
  },
  "dependencies-dev": {
    "github.com/ValaFoundation/downloader-lib": "master"
  },
  "system_dependencies": {
    "glib-2.0": "*"
  }
}
""");
        } catch (Error e) {
          assert_not_reached ();
        }

        PackageConfig? config = null;
        try {
          config = PackageConfig.load (path);
        } catch (Error e) {
          assert_not_reached ();
        }

            assert (config.name == "com.example.app");
            assert (config.version == "1.2.3");
            assert (config.description == "A test app");
            assert (config.dependencies.size == 1);
            assert (config.dependencies.get ("github.com/ValaFoundation/testcases") == "master");
            assert (config.dev_dependencies.size == 1);
            assert (config.dev_dependencies.get ("github.com/ValaFoundation/downloader-lib") == "master");
            assert (config.system_dependencies.get ("glib-2.0") == "*");
        }

        public void test_config_fails_on_non_object_dependencies () {
          string path;
          try {
            path = write_temp_json ("""
{
  "dependencies": ["github.com/ValaFoundation/testcases"]
}
""");
          } catch (Error e) {
            assert_not_reached ();
          }

            bool failed = false;
            try {
                PackageConfig.load (path);
            } catch (Error e) {
                failed = true;
                assert (e.message.contains ("dependencies"));
            }

            assert (failed);
        }

        private string write_temp_json (string content) throws Error {
            string path = "%s/vamposer-config-%s.json".printf (Environment.get_tmp_dir (), Uuid.string_random ());
            FileUtils.set_contents (path, content);
            return path;
        }
    }
}
