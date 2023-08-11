#!/usr/bin/make -f
SHELL = /usr/bin/bash

# Installation directories
PKGDIR = .
PKGDIR_ABS = $(realpath .)
SRCDIR = $(PKGDIR)/src
SRCDIR_ABS = $(PKGDIR_ABS)/src
BUILDIR ?= $(PKGDIR)/build
BUILDIR_ABS ?= $(PKGDIR_ABS)/build
BINDIR ?= $(BUILDIR_ABS)
DATADIR ?= $(BINDIR)
TEMPDIR ?= $(SRCDIR_ABS)/tmp
INSTALLATION_DIRS := $(BINDIR) $(DATADIR)

# Macros
MPP = /usr/bin/m4
MPP_INCLUDES =
MPP_DEFINES =  -D __DATADIR__=$(DATADIR) -D __TEMPDIR__=$(TEMPDIR)
MPP_MACROS = $(PKGDIR)/lib/macros.m4
MPP_FLAGS = $(MPP_INCLUDES) $(MPP_DEFINES) $(PKGDIR)/lib/macros.m4

# Programs

# Sources
VPATH := $(SRCDIR)
EXECUTABLES = $(addprefix $(BUILDIR)/, $(basename crapp.sh))
DATA = $(addprefix $(BUILDIR)/, $(basename filenames.sh new_subs.sh))

all: build

install: build

build: $(EXECUTABLES) $(DATA)

$(EXECUTABLES): | $(INSTALLATION_DIRS)
$(BUILDIR)/crapp: crapp.sh
	$(MPP) $(MPP_FLAGS) $< > $@
	chmod +x $@

$(BUILDIR)/%: %.sh
	cat $< > $@
	chmod +x $@

clean:
	-rm -rdf $(BUILDIR)

$(INSTALLATION_DIRS):
	-mkdir -p $@

.DEFAULT_GOAL := all
.PHONY: all build install clean

