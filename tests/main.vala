using GLib;
using Gee;

int main (string[] args) {

    ValaFoundation.Testcases.BaseTest.saved_commands = new Gee.ArrayList<ValaFoundation.Testcases.TestCommand> ();
    Test.init (ref args);

    ValaFoundation.Testcases.register_test_suite<AppTests.ExampleTest> ();


    return Test.run ();
}
