vamposer_sources = files('library.vala')

vamposer_deps = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
]

vamposer_shared = shared_library(
  meson.project_name(),
  vamposer_sources,
  dependencies: vamposer_deps,
  install: true,
  vala_vapi: 'vapi/' + meson.project_name() + '.vapi',
  vala_header: meson.project_name() + '.h'
)

vamposer_dep = declare_dependency(
  link_with: vamposer_shared,
  include_directories: include_directories('.'),
)

pkg = import('pkgconfig')
pkg.generate(
  vamposer_shared,
  version: meson.project_version(),
  name: meson.project_name(),
  filebase: meson.project_name(),
  description: 'Vala Library Template.'
)
