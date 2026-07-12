using GLib;
using Gee;

int main (string[] args) {

    ValaFoundation.Testcases.BaseTest.saved_commands = new Gee.ArrayList<ValaFoundation.Testcases.TestCommand> ();
    Test.init (ref args);

    ValaFoundation.Testcases.register_test_suite<AppTests.ConfigTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.DependencyResolverTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.InstallerTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.SystemDependencyInstallerTest> ();


    return Test.run ();
}
