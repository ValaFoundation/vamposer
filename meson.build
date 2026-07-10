project('vala-library-template', 'vala', 'c', version: '0.1.0')

subdir('src')
subdir('tests')

project_dep_name = meson.project_name().replace('-', '_')
meson.override_dependency(project_dep_name, vala_library_template_dep)
