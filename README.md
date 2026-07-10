# Vala library template

Template repository for creating a new Vala shared library project with Meson, tests, CI and release workflow.

## Contents

<!-- TEMPLATE_BOOTSTRAP_START -->
- [Template bootstrap (template only)](#template-bootstrap-template-only)
<!-- TEMPLATE_BOOTSTRAP_END -->
- [Build](#build)
- [Test](#test)
- [Release artifacts](#release-artifacts)
- [Use generated library in other projects](#use-generated-library-in-other-projects)
- [Dependencies](#dependencies)
- [License](#license)

<!-- TEMPLATE_BOOTSTRAP_START -->
## Template bootstrap (template only)

1. Click **Use this template** on GitHub.
2. Clone your new repository.
3. Push your initial commit (or run the workflow manually).
4. The `Template Bootstrap` GitHub Action auto-runs once, commits renamed defaults, and removes itself.

Manual fallback:

```sh
./bootstrap-template.sh
```

Optional: explicit project slug:

```sh
./bootstrap-template.sh my-awesome-lib
```

Keep bootstrap script after run:

```sh
KEEP_SCRIPT=1 ./bootstrap-template.sh
```
<!-- TEMPLATE_BOOTSTRAP_END -->

## Build

```sh
meson setup builddir
meson compile -C builddir
```

## Test

```sh
meson test -C builddir
```

or via Makefile helper:

```sh
make tests
```

## Release artifacts

Tag-based release workflow (`v*`) publishes:

- shared library (`lib*.so*`)
- generated VAPI (`src/vapi/*.vapi`)
- generated header (`src/*.h`)
- bundled ZIP (`<repo-name>-<tag>-linux.zip`)

## Use generated library in other projects

### Option 1: Meson subproject dependency

In consumer project root:

```sh
./init.sh
```

Or run directly from GitHub:

```sh
curl -sSfL https://raw.githubusercontent.com/ValaFoundation/library-template/master/init.sh -o init.sh && chmod +x init.sh && ./init.sh && rm init.sh
```

### Option 2: Local vapi/lib/include integration

In consumer project root:

```sh
curl -sSfL https://raw.githubusercontent.com/ValaFoundation/library-template/master/init-local-vapi.sh | bash
```

This helper downloads release artifacts (or builds from source) and prepares local `vapi/`, `lib/`, and `include/` folders plus reusable Meson variables.

## Dependencies

- glib-2.0
- gio-2.0
- gee-0.8
- vala_testcases (tests only)

## License

MIT (see `LICENSE`).
