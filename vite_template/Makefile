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

.PHONY: all
all: run

.PHONY: node-exec
node-exec: env
	@if test -z "$$params"; then echo \
	"make node-exec missing params: -> params=./file make node-exec"; \
	exit 1; \
	fi
	@set -a; source ./.env && node "$${params}" | $(PRETTY_OUTPUT)

.PHONY: scratch
scratch: env
	set -a; source ./.env && node ./tmp/scratch.js | $(PRETTY_OUTPUT)

.PHONY: run
run: dirs env-dev
	NODE_ENV=development $(BUILD_SYS) serve \
	--mode development $(params)

.PHONY: run-staging
run-staging: dirs env-staging
	NODE_ENV=development $(BUILD_SYS) serve \
	--mode staging $(params)

.PHONY: run-prod
run-prod: dirs env-prod
	NODE_ENV=development $(BUILD_SYS) serve \
	--mode production $(params)

.PHONY: build
build:
	NODE_ENV=production $(BUILD_SYS) build \
	--mode development $(params)

.PHONY: build-staging
build-staging:
	NODE_ENV=production $(BUILD_SYS) build \
	--mode staging $(params)

.PHONY: build-prod
build-prod:
	NODE_ENV=production $(BUILD_SYS) build \
	--mode production $(params)

.PHONY: test
test: env-dev
	NODE_ENV=development $(VITEST) run \
	--reporter verbose --mode development $(params)

.PHONY: test-staging
test-staging: env-staging
	NODE_ENV=development $(VITEST) run \
	--reporter verbose --mode staging $(params)

.PHONY: test-prod
test-prod: env-prod
	NODE_ENV=development $(VITEST) run \
	--reporter verbose --mode production $(params)

.PHONY: lint
lint:
	$(LINTER) --ext js,jsx --fix .

.PHONY: lint-check
lint-check:
	$(LINTER) --ext js,jsx .

.PHONY: fmt
fmt:
	$(FORMATER) --write "$${params:-.}"

.PHONY: fmt-check
params ?=.
fmt-check:
	$(FORMATER) --check $(params)

dirs:
	$(MKDIRP) $(LOGDIR)

.PHONY: env env-dev env-staging env-prod
env:
	./scripts/dotenv.sh --pkgdir=. --envdir=./config/env --mode $(MODE)
	@cat .env
env-dev:
	./scripts/dotenv.sh --pkgdir=. --envdir=./config/env --mode dev
	@cat .env
env-staging:
	./scripts/dotenv.sh --pkgdir=. --envdir=./config/env --mode staging
	@cat .env
env-prod:
	./scripts/dotenv.sh --pkgdir=. --envdir=./config/env --mode prod
	@cat .env
