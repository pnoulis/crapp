SHELL := '/usr/bin/bash'
SRCDIR := "$(shell cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

MKDIR = mkdir -p
CP = cp -r
MOVE = mv


dirs := src doc conf tests tmp assets
dirtree := $(addprefix $(package_path)/, $(dirs))
utilities := readme gitignore gitattributes \
	editorconfig makefile configure npm

.PHONY: all build install
.DEFAULT_GOAL := all

all: build

build: $(dirtree) $(utilities) initvc
	@echo $(package_path)
	@tree -a -I .git $(package_path)

initvc:
	cd $(package_path) \
	&& git init && git add . && git commit -m 'Initial commit'

npm:
	cd $(package_path) && npm init -y

makefile:
	@touch $(package_path)/Makefile

configure:
	@touch $(package_path)/configure

gitignore:
	@cat $(crapp_assets)/gitignore/common_transients > $(package_path)/.gitignore

gitattributes:
	@cat $(crapp_assets)/gitattributes/common.shell.linux > $(package_path)/.gitattributes

editorconfig:
	@echo -e 'root = true\n' > $(package_path)/.editorconfig
	@cat $(crapp_assets)/editorconfig/base.linux >> $(package_path)/.editorconfig

readme:
	@echo $(package_summary) > $(package_path)/README.md


$(dirtree):
	@$(MKDIR) $(dirtree)