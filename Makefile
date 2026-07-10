.PHONY: build tests

BUILD_DIR ?= builddir

build:
	@if [ ! -d "$(BUILD_DIR)" ]; then meson setup "$(BUILD_DIR)"; fi
	meson compile -C "$(BUILD_DIR)"

tests:
	(meson setup build-tests && meson compile -C build-tests && meson test -C build-tests --verbose)
