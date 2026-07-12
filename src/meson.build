subdir('package_managers')

vamposer_core_sources = files(
  'config.vala',
  'dependency_resolver.vala',
  'installer.vala',
  'system_dependency_installer.vala',
) + package_manager_sources

vamposer_deps = [
  dependency('glib-2.0'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
]

vamposer_core = static_library(
  'vamposer_core',
  vamposer_core_sources,
  dependencies: vamposer_deps,
  vala_vapi: 'vamposer_core.vapi',
  vala_header: 'vamposer_core.h',
  install: false,
)

vamposer_core_dep = declare_dependency(
  link_with: vamposer_core,
  include_directories: include_directories('.'),
)

vamposer_cli_sources = files(
  'main.vala',
)

executable(
  meson.project_name(),
  vamposer_cli_sources,
  dependencies: [vamposer_core_dep] + vamposer_deps,
  install: true,
)
