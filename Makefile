LIBPYTHON?=$(HOME)/.local/share/uv/python/cpython-3.13-macos-aarch64-none/lib/libpython3.13.dylib
LIBPYTHON_VERSION:=$(lastword $(shell otool -l "${LIBPYTHON}" | grep -F -A4 LC_ID_DYLIB | tail -n1))
ifeq ($(filter 3.%,$(LIBPYTHON_VERSION)),)
	$(error something wrong with libpython)
endif

CFLAGS=-Wall -Wextra -Werror -Os -fPIC

all: libpython_with_venv.dylib

.PHONY: all clean

clean:
	rm -f libpython_with_venv.dylib libida.dylib

libida.dylib: libida.c
	cc $(CFLAGS) -shared -Wl,-install_name,@executable_path/$@ -o $@ $<

libpython_with_venv.dylib: activate_venv.c libida.dylib
	cc $(CFLAGS) -shared -Wl,-current_version,$(LIBPYTHON_VERSION) -Wl,-reexport_library,$(LIBPYTHON) -o $@ $^
