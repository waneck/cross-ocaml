.PHONY: all dist clean patch cross-ocaml findlib binary install

CROSS          := x86_64-apple-darwin11
OCAML_DIR      := ocaml
BUILD_DIR      := build
BINARY_DIR     := $(CURDIR)/binary
INSTALL_PREFIX := /usr/$(CROSS)
BUILD_CC       := clang

DISTFILES := LICENSE Makefile README files findlib ocaml patches.in

all: binary

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	cp -rf $(FLEXDLL_DIR)  $(OCAML_DIR) $(BUILD_DIR)

patches:
	mkdir -p patches
	find patches.in | grep '.patch' | while read i; do \
	  sed -e 's#@ocaml_cross@#$(CROSS)#g' < $$i > \
	  `echo $$i | sed -e 's#patches.in#patches#'`; \
	done
	cp patches.in/series patches

patch: stamp-quilt-patches

stamp-quilt-patches: patches $(BUILD_DIR)
	quilt push -a
	touch stamp-quilt-patches

stamp-build-ocaml: stamp-quilt-patches
	cd build/ocaml && ./configure -host $(CROSS) -cross $(CROSS)- -cc $(BUILD_CC) -prefix $(INSTALL_PREFIX) && make cross
	touch stamp-build-ocaml

install: stamp-binary-all
	cd build/ocaml && make install

binary: stamp-binary-all

stamp-binary-all: stamp-build-ocaml
	touch stamp-binary-all

clean:
	rm -rf $(BUILD_DIR) $(BINARY_DIR) $(INSTALL_DIR) patches .pc/ stamp-*

dist: clean
	rm -rf mingw-ocaml
	mkdir mingw-ocaml
	cp -rf $(DISTFILES) mingw-ocaml
	find mingw-ocaml -name .git | xargs rm -rf
	tar cvzf mingw-ocaml.tar.gz mingw-ocaml
	rm -rf mingw-ocaml 
