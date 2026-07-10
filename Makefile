.PHONY: tests

tests:
	(meson setup build-tests && meson compile -C build-tests && meson test -C build-tests --verbose)
