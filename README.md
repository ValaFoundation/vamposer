# vamposer

Template repository for creating a new Vala shared library project with Meson, tests, CI and release workflow.

## Contents

- [Build](#build)
- [Test](#test)
- [Release artifacts](#release-artifacts)
- [Use generated library in other projects](#use-generated-library-in-other-projects)
- [Dependencies](#dependencies)
- [License](#license)


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
curl -sSfL https://raw.githubusercontent.com/ValaFoundation/vamposer/master/init.sh -o init.sh && chmod +x init.sh && ./init.sh && rm init.sh
```

### Option 2: Local vapi/lib/include integration

In consumer project root:

```sh
curl -sSfL https://raw.githubusercontent.com/ValaFoundation/vamposer/master/init-local-vapi.sh | bash
```

This helper downloads release artifacts (or builds from source) and prepares local `vapi/`, `lib/`, and `include/` folders plus reusable Meson variables.

## Dependencies

- glib-2.0
- gio-2.0
- gee-0.8
- vala_testcases (tests only)

## License

MIT (see `LICENSE`).
