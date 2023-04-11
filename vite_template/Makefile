#!/usr/bin/make

# Make and Shell behavior
SHELL = /usr/bin/bash
.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

# Critical Paths
LOGDIR=var/log

# Programs
INSTALL = /usr/bin/install
MKDIRP = /usr/bin/mkdir -p
CP = /usr/bin/cp
RM = /usr/bin/rm
CHMOD = /usr/bin/chmod
BUILD_SYS = npx vite
LINTER = npx eslint
FORMATER = npx prettier
VITEST = npx vitest
PRETTY_OUTPUT = npx pino-pretty
MAKE_ENV = ./scripts/dotenv.sh --pkgdir=. --envdir=./config/env

.PHONY: all
all: run

.PHONY: node-run
node-run:
	@if test -z "$$params"; then echo \
	"make node-exec missing params: -> params=./file make node-exec"; \
	exit 1; \
	fi
	$(MAKE_ENV) --mode=dev --host=dev
	@set -a; source ./.env && node "$${params}" | $(PRETTY_OUTPUT)

.PHONY: scratch
scratch:
	$(MAKE_ENV) --mode=dev --host=dev
	set -a; source ./.env && node ./tmp/scratch.js | $(PRETTY_OUTPUT)

.PHONY: run
run: dirs
	$(MAKE_ENV) --mode=dev --host=dev
	set -a; source ./.env && $(BUILD_SYS) serve

.PHONY: run-staging
run-staging: dirs
	$(MAKE_ENV) --mode=staging --host=dev
	set -a; source ./.env && $(BUILD_SYS) serve

.PHONY: run-prod
run-prod: dirs
	$(MAKE_ENV) --mode=prod --host=dev
	set -a; source ./.env && $(BUILD_SYS) serve

.PHONY: build
build:
	$(MAKE_ENV) --mode=dev
	set -a; source ./.env && $(BUILD_SYS) build

.PHONY: build-staging
build-staging:
	$(MAKE_ENV) --mode=staging
	set -a; source ./.env && $(BUILD_SYS) build

.PHONY: build-prod
build-prod:
	$(MAKE_ENV) --mode=prod
	set -a; source ./.env && $(BUILD_SYS) build

.PHONY: test
test:
	$(MAKE_ENV) --mode=dev --host=dev
	$(VITEST) run --reporter verbose

.PHONY: test-staging
test-staging:
	$(MAKE_ENV) --mode=staging --host=dev
	$(VITEST) run --reporter verbose

.PHONY: test-prod
test-prod:
	$(MAKE_ENV) --mode=prod --host=dev
	$(VITEST) run --reporter verbose

.PHONY: lint
lint:
	$(LINTER) --ext js,jsx --fix "$${params:-.}"

.PHONY: lint-check
lint-check:
	$(LINTER) --ext js,jsx "$${params:-.}"

.PHONY: fmt
fmt:
	$(FORMATER) --write "$${params:-.}"

.PHONY: fmt-check
fmt-check:
	$(FORMATER) --check "$${params:-.}"


.PHONY: env
env:
	$(MAKE_ENV) $(params)

dirs:
	$(MKDIRP) $(LOGDIR)
