#!/usr/bin/make

# Make Configuration
SHELL=/usr/bin/bash
.DELETE_ON_ERROR:

# Directories
SRCDIR=$(shell pwd)
SCRIPTSDIR=$(SRCDIR)/scripts

# Programs
BUNDLER=npx vite
TESTER=npx vitest
LINTER=npx eslint
FORMATER=npx prettier
DOCGEN=npx jsdoc
DOTENV=$(SCRIPTSDIR)/dotenv.sh
MACRO=$(SCRIPTSDIR)/gpp.sh

.PHONY: all
all: build

.PHONY: run
.PHONY: dev
.PHONY: test
.PHONY: build
build:
	@echo $(SRCDIR)
	@echo $(SRCDIR_ABS)
.PHONY: release
.PHONY: deploy
.PHONY: dist
.PHONY: doc
.PHONY: lint lint-check
lint:
lint-check:
.PHONY: format format-check
format:
format-check:
.PHONY: host
.PHONY: clean distclean allclean
.PHONY: docker
.PHONY: env
