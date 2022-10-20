SHELL := '/bin/bash'
SRCDIR ?= "$(shell cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BUILDIR ?= $(shell mktemp -dp /tmp XXXXXXX.crapp)
PREFIX ?= "$(HOME)/src"
APPNAME ?= 'random'

MKDIR := mkdir -p
CP := cp -r

dirs := src doc config tests tmp/dev.bash
utilfiles := .gitignore .gitattributes .editorconfig \
Makefile configure README.md

dirtree := $(addprefix $(BUILDIR)/, $(dirs))
utilfiles := $(addprefix $(BUILDIR)/, $(utilfiles))

.PHONY: all build install
.DEFAULT_GOAL: all

all: build

build: $(utilfiles) | $(dirtree)
	@echo 'target: build'

$(gitignore):
	@echo 'ignore_something/*' > $(gitignore)

$(makefile):

$(configure):
	@echo 'configure something' > $(configure)

$(readme):
	@echo 'read something' > $(readme)

$(utilfiles):
	@touch $(utilfiles)

$(dirtree):
	@$(MKDIR) $(dirtree)

install:
	@$(MKDIR) $(PREFIX) &>/dev/null
	@$(CP) $(BUILDIR)/. $(PREFIX)/
	@cd $(PREFIX)/.. && \
	find . -mindepth 1 -path "*$(APPNAME)*" | xargs -I {} realpath {} \
