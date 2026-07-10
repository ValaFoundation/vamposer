namespace AppTests {
    using GLib;
    using ValaFoundation.Testcases;
    using Vamposer;

    public class DependencyResolverTest : BaseTest {
        construct {
            add_test ("resolver_short_form_to_https_git", test_short_form_to_https_git);
            add_test ("resolver_keeps_https_and_appends_git", test_https_normalization);
            add_test ("resolver_supports_gitlab_ssh_form", test_gitlab_ssh_form);
            add_test ("resolver_extracts_project_name", test_extract_project_name);
        }

        public void test_short_form_to_https_git () {
            var url = DependencyResolver.normalize_repository_url ("github.com/ValaFoundation/testcases");
            assert (url == "https://github.com/ValaFoundation/testcases.git");
        }

        public void test_https_normalization () {
            var url = DependencyResolver.normalize_repository_url ("https://github.com/ValaFoundation/downloader-lib");
            assert (url == "https://github.com/ValaFoundation/downloader-lib.git");
        }

        public void test_gitlab_ssh_form () {
            var url = DependencyResolver.normalize_repository_url ("git@gitlab.com:group/project");
            assert (url == "git@gitlab.com:group/project.git");
        }

        public void test_extract_project_name () {
            assert (DependencyResolver.extract_project_name ("git@gitlab.com:group/project.git") == "project");
            assert (DependencyResolver.extract_project_name ("https://gitlab.com/group/custom-lib/") == "custom-lib");

            var resolved = DependencyResolver.resolve ("github.com/ValaFoundation/testcases", "master");
            assert (resolved.project_name == "testcases");
            assert (resolved.local_directory == "subprojects/testcases");
        }
    }
}
