using Gee;
using Json;

namespace Vamposer {
    public class PackageConfig : GLib.Object {
        public string? name { get; private set; }
        public string? version { get; private set; }
        public string? description { get; private set; }

        public HashMap<string, string> dependencies { get; private set; }
        public HashMap<string, string> system_dependencies { get; private set; }

        public PackageConfig () {
            dependencies = new HashMap<string, string> ();
            system_dependencies = new HashMap<string, string> ();
        }

        public static PackageConfig create_empty () {
            return new PackageConfig ();
        }

        public static PackageConfig load (string file_path) throws Error {
            if (!FileUtils.test (file_path, FileTest.EXISTS)) {
                throw new FileError.NOENT ("Config file not found: %s".printf (file_path));
            }

            var parser = new Parser ();
            parser.load_from_file (file_path);

            var root = parser.get_root ();
            if (root == null || root.get_node_type () != NodeType.OBJECT) {
                throw new FileError.INVAL ("File %s must contain a JSON object at the root level".printf (file_path));
            }

            var root_object = root.get_object ();
            var config = new PackageConfig ();

            if (root_object.has_member ("name")) {
                config.name = root_object.get_string_member ("name");
            }
            if (root_object.has_member ("version")) {
                config.version = root_object.get_string_member ("version");
            }
            if (root_object.has_member ("description")) {
                config.description = root_object.get_string_member ("description");
            }

            config.dependencies = load_string_map (root_object, "dependencies");
            config.system_dependencies = load_string_map (root_object, "system_dependencies");

            return config;
        }

        public void save (string file_path) throws Error {
            var builder = new Builder ();
            builder.begin_object ();

            if (name != null) {
                builder.set_member_name ("name");
                builder.add_string_value (name);
            }
            if (version != null) {
                builder.set_member_name ("version");
                builder.add_string_value (version);
            }
            if (description != null) {
                builder.set_member_name ("description");
                builder.add_string_value (description);
            }

            add_string_map (builder, "dependencies", dependencies);
            add_string_map (builder, "system_dependencies", system_dependencies);

            builder.end_object ();

            var generator = new Generator ();
            generator.set_root (builder.get_root ());
            generator.pretty = true;

            var json = generator.to_data (null);
            FileUtils.set_contents (file_path, json + "\n");
        }

        private static HashMap<string, string> load_string_map (Json.Object root_object, string field) throws Error {
            var result = new HashMap<string, string> ();

            if (!root_object.has_member (field)) {
                return result;
            }

            var section_node = root_object.get_member (field);
            if (section_node == null || section_node.get_node_type () != NodeType.OBJECT) {
                throw new FileError.INVAL ("Field '%s' must be a JSON object".printf (field));
            }

            var section = root_object.get_object_member (field);
            foreach (var key in section.get_members ()) {
                var value_node = section.get_member (key);
                if (value_node == null || value_node.get_node_type () != NodeType.VALUE || !value_node.get_value ().holds (typeof (string))) {
                    throw new FileError.INVAL ("Value '%s.%s' must be a string".printf (field, key));
                }

                var value = section.get_string_member (key);
                result.set (key, value);
            }

            return result;
        }

        private static void add_string_map (Builder builder, string field, HashMap<string, string> values) {
            builder.set_member_name (field);
            builder.begin_object ();

            foreach (var entry in values.entries) {
                builder.set_member_name (entry.key);
                builder.add_string_value (entry.value);
            }

            builder.end_object ();
        }
    }
}
