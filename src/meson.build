vala_library_template_sources = files('library.vala')

vala_library_template_deps = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
]

vala_library_template_shared = shared_library(
  meson.project_name(),
  vala_library_template_sources,
  dependencies: vala_library_template_deps,
  install: true,
  vala_vapi: 'vapi/' + meson.project_name() + '.vapi',
  vala_header: meson.project_name() + '.h'
)

vala_library_template_dep = declare_dependency(
  link_with: vala_library_template_shared,
  include_directories: include_directories('.'),
)

pkg = import('pkgconfig')
pkg.generate(
  vala_library_template_shared,
  version: meson.project_version(),
  name: meson.project_name(),
  filebase: meson.project_name(),
  description: 'Vala Library Template.'
)
