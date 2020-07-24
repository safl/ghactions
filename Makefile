#
# C build skeleton -- wrapping CMake providing the conventional 'make' interface
#
# ./configure
# make
# make install
#
# The initial targets of this Makefile supports the behavior, instrumenting
# CMake based on the options passed to "./configure"
#
# Additional targets come after these which modify CMAKE build-options and other
# common practices associated with build development
#
PROJECT = foobar
PLATFORM_ID = $$( uname -s )
PLATFORM = $$( \
	case $(PLATFORM_ID) in \
		( Linux | FreeBSD | OpenBSD | NetBSD ) echo $(PLATFORM_ID) ;; \
		( * ) echo Unrecognized ;; \
	esac)

CTAGS = $$( \
	case $(PLATFORM_ID) in \
		( Linux ) echo "ctags" ;; \
		( FreeBSD | OpenBSD | NetBSD ) echo "exctags" ;; \
		( * ) echo Unrecognized ;; \
	esac)

MAKE = $$( \
	case $(PLATFORM_ID) in \
		( Linux ) echo "make" ;; \
		( FreeBSD | OpenBSD | NetBSD ) echo "gmake" ;; \
		( * ) echo Unrecognized ;; \
	esac)

NPROC = $$( \
	case $(PLATFORM_ID) in \
		( Linux ) nproc ;; \
		( FreeBSD | OpenBSD | NetBSD ) sysctl -n hw.ncpu ;; \
		( * ) echo Unrecognized ;; \
	esac)

BUILD_DIR?=build

.PHONY: default
default: info tags
	@echo "## build: make default"
	@if [ ! -d "$(BUILD_DIR)" ]; then $(MAKE) config; fi;
	$(MAKE) build

.PHONY: config
config:
	@echo "## build: make configure"
	CC=$(CC) ./configure

.PHONY: config-debug
config-debug:
	@echo "## build: make configure"
	CC=$(CC) ./configure --enable-debug

.PHONY: info
info:
	@echo "## build: make info"
	@echo "OSTYPE: $(OSTYPE)"
	@echo "PLATFORM: $(PLATFORM)"
	@echo "CC: $(CC)"
	@echo "CXX: $(CXX)"
	@echo "MAKE: $(MAKE)"
	@echo "CTAGS: $(CTAGS)"
	@echo "NPROC: $(NPROC)"

.PHONY: build
build: info
	@echo "## build: make build"
	@if [ ! -d "$(BUILD_DIR)" ]; then			\
		echo "Please run ./configure";			\
		echo "See ./configure --help for config options"\
		echo "";					\
		false;						\
	fi
	cd $(BUILD_DIR) && ${MAKE}
	@if [ -f "$(BUILD_DIR)/build_deb" ]; then	\
		cd $(BUILD_DIR) && ${MAKE} package;	\
	fi

.PHONY: install
install:
	@echo "## build: make install"
	cd $(BUILD_DIR) && ${MAKE} install

#
# The binary DEB packages generated here are not meant to be used for anything
# but easy install/uninstall during development
#
# make install-deb
#
# Which will build a deb pkg and install it instead of copying it directly
# into the system paths. This is convenient as it is easier to purge it by
# running e.g.
#
# make uninstall-deb
#
.PHONY: install-deb
install-deb:
	@echo "## build: make install-deb"
	dpkg -i $(BUILD_DIR)/*.deb

.PHONY: uninstall-deb
uninstall-deb:
	@echo "## build: make uninstall-deb"
	apt-get --yes remove ${PROJECT}-* || true

.PHONY: clean
clean:
	@echo "## build: make clean"
	rm -fr $(BUILD_DIR) || true
	rm -fr cmake-build-debug || true

#
# Helper-target to produce full-source archive
#
.PHONY: gen-src-archive
gen-src-archive:
	@echo "## build: make gen-src-archive"
	./scripts/xnvme_gen_src_archive.sh

#
# Helper-target to produce Bash-completions for tools (tools, examples, tests)
#
# NOTE: This target requires a bunch of things: binaries must be built and
# residing in 'build/tools' etc. AND installed on the system. Also, the find
# command has only been tried with GNU find
#
.PHONY: gen-bash-completions
gen-bash-completions:
	@echo "## build: make gen-bash-completions"
	$(eval TOOLS := $(shell find build/tools build/examples build/tests -not -name "*.so" -type f -executable -exec basename {} \;))
	python ./scripts/xnvmec_generator.py cpl --tools ${TOOLS} --output scripts/bash_completion.d

#
# Helper-target to produce man pages for tools (tools, examples, tests)
#
# NOTE: This target requires a bunch of things: binaries must be built and
# residing in 'build/tools' etc. AND installed on the system. Also, the find
# command has only been tried with GNU find
#
.PHONY: gen-man-pages
gen-man-pages:
	@echo "## build: make gen-man-pages"
	$(eval TOOLS := $(shell find build/tools build/examples build/tests -not -name "*.so" -type f -executable -exec basename {} \;))
	python ./scripts/xnvmec_generator.py man --tools ${TOOLS} --output man/

#
# Helper-target to produce tags
#
.PHONY: tags
tags:
	@echo "## build: make tags"
	@$(CTAGS) * --languages=C -h=".c.h" -R --exclude=build \
		include \
		src \
		examples \
		|| true

#
# clobber: clean the build and any left-over files / changes in the repos
#
.PHONY: clobber
clobber: third-party-clobber clean
	@git clean -dfx
	@git clean -dfX
	@git checkout .
