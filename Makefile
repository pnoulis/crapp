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
VPATH = src
## Build
buildir = $(srcdir)/build
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

INSTALL := /usr/bin/install
.DEFAULT_GOAL := all

all: install

run:
	@echo run

.PHONY: install

install: clean-install $(bindir)/crapp

$(bindir)/crapp: src/crapp.sh
	cat $< > $@
	chmod +x $(bindir)/crapp

clean-install:
	-rm $(bindir)/crapp
