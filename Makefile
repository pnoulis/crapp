#!/usr/bin/make -f
SHELL := /bin/bash


#!/usr/bin/make -f
SHELL := /bin/bash

# Meta package
package := bash_utils
package_version := 1.0.0
package_distname := $(package)-$(package_version)

# Directories
## Anchors
srcdir = .
abs_srcdir = $(realpath .)
## Build
buildir = $(srcdir)/build
VPATH = src
abs_buildir = $(abs_srcdir)/build
built = $(buildir)
## Distribute
distdir = $(srcdir)/dist
distribution = $(distdir)/$(package_distname)
## Install
DESTDIR ?=
prefix = $(HOME)
exec_prefix = $(prefix)
bindir = $(prefix)/bin
dirs := $(abs_buildir)

sources = $(addprefix $(srcdir)/src/, \
	crapp.sh \
	filenames.sh \
	new_subs.sh\
)
executables = $(addprefix $(buildir)/, \
	crapp \
	filenames \
	new_subs\
)

MPP = /usr/bin/m4
MPP_INCLUDES = -I $(srcdir)/src
MPP_DEFINES = -D DATADIR='$(abs_srcdir)/src'
MPPFLAGS = $(MPP_INCLUDES) $(MPP_DEFINES)


INSTALL := /usr/bin/install
.DEFAULT_GOAL := all

all: install

run:
	@echo run

.PHONY: build
build: $(executables)

$(buildir)/%: %.sh | $(dirs)
	$(MPP) $(MPPFLAGS) $< > $@
	chmod +x $@

.PHONY: expand
expand:
	$(MPP) $(MPPFLAGS) $(MPPINCLUDE) $(srcdir)/src/testm42.sh $(srcdir)/src/testm4.sh

.PHONY: install

install: clean-install $(bindir)/crapp

$(bindir)/crapp: src/crapp.sh
	cat $< > $@
	chmod +x $(bindir)/crapp

clean:
	-rm -rdf $(buildir)

clean-install:
	-rm $(bindir)/crapp

.PHONY: test
test:
	@echo $(sources)
	@echo $(SRC)

$(dirs):
	mkdir -p $@
