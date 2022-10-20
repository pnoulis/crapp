SHELL := '/bin/bash'
SRCDIR ?= "$(shell cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BUILDIR ?= $(shell mktemp -dp /tmp XXXXXXX.crapp)
PREFIX ?= "$(HOME)/src"
APPNAME ?= 'random'

MKDIR := mkdir -p
CP := cp -r

dirs := src docs config tests tmp
dirtree := $(addprefix $(BUILDIR)/, $(dirs))
utilities := makefile configure readme gitignore \
gitattributes editorconfig

.PHONY: all build install
.DEFAULT_GOAL: all

all: build

build: $(utilities) initvc | $(dirtree)
	@echo 'target: build'

install:
	@$(MKDIR) $(PREFIX) &>/dev/null
	@$(CP) $(BUILDIR)/. $(PREFIX)/
	@echo $(PREFIX)/
	@find $(PREFIX)/ -mindepth 1

initvc:
	@echo initialize git repository

makefile:
	@awk '\
	{ print $$0 } \
	' $(SRCDIR)/templates/Makefile > $(BUILDIR)/Makefile

configure:
	@echo 'configure something' > $(BUILDIR)/configure

gitignore:
	@cat $(CRAPP_ASSETS)/gitignore/emacs > $(BUILDIR)/.gitignore
	@cat $(CRAPP_ASSETS)/gitignore/common_transients >> $(BUILDIR)/.gitignore

gitattributes:
	@cat $(CRAPP_ASSETS)/gitattributes/common.shell.linux > $(BUILDIR)/.gitattributes

editorconfig:
	@echo -e 'root = true\n' > $(BUILDIR)/.editorconfig
	@cat $(CRAPP_ASSETS)/editorconfig/base.linux >> $(BUILDIR)/.editorconfig

readme:
	@echo 'read something' > $(BUILDIR)/.README.md

$(dirtree):
	@$(MKDIR) $(dirtree)
