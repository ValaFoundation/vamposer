namespace Vamposer {
    public class DependencyResolver : Object {
        public static ResolvedDependency resolve (string source_id, string revision) {
            var repository_url = normalize_repository_url (source_id);
            var project_name = extract_project_name (source_id);
            var local_directory = Path.build_filename ("subprojects", project_name);

            return new ResolvedDependency (source_id, revision, repository_url, project_name, local_directory);
        }

        public static string normalize_repository_url (string source_id) {
            var repository_url = source_id.strip ();

            if (repository_url.has_prefix ("git+https://")) {
                repository_url = "https://%s".printf (repository_url.substring (12));
            }

            if (!has_transport_prefix (repository_url)) {
                repository_url = "https://%s".printf (repository_url);
            }

            if (!repository_url.has_suffix (".git")) {
                repository_url += ".git";
            }

            return repository_url;
        }

        public static string extract_project_name (string source_id) {
            var cleaned = source_id.strip ();
            if (cleaned.has_suffix ("/")) {
                cleaned = cleaned.substring (0, cleaned.length - 1);
            }

            var slash_idx = cleaned.last_index_of_char ('/');
            if (slash_idx >= 0 && slash_idx + 1 < cleaned.length) {
                cleaned = cleaned.substring (slash_idx + 1);
            }

            if (cleaned.has_suffix (".git")) {
                cleaned = cleaned.substring (0, cleaned.length - 4);
            }

            return cleaned;
        }

        private static bool has_transport_prefix (string value) {
            return value.has_prefix ("https://")
                || value.has_prefix ("http://")
                || value.has_prefix ("ssh://")
                || value.has_prefix ("git://")
                || value.has_prefix ("git+https://")
                || value.has_prefix ("git@");
        }
    }
}
