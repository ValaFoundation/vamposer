test_env = environment()
test_sources = files(
  'main.vala',
  'config_test.vala',
  'resolver_test.vala',
  'installer_test.vala',
)

vala_testcases_dep = dependency('vala_testcases', fallback: ['vala_testcases', 'vala_testcases_dep'])


test_exe = executable('tests',
  test_sources,
  dependencies: [
    dependency('glib-2.0'),
    dependency('gee-0.8'),
    dependency('json-glib-1.0'),
    vala_testcases_dep,
    vamposer_core_dep,
  ],
  vala_args: ['--target-glib=2.58'],
)

test('Unit Tests', test_exe, env: test_env, protocol: 'tap')
