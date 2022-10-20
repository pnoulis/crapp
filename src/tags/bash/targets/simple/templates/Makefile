SHELL := '/bin/bash'
SRCDIR ?= "$(shell cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PREFIX ?= "/usr/local"
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/man

.PHONY: all build run debug dev test release install uninstall clean
.DEFAULT_GOAL: all

all: build
	@echo all

build:
	@echo build

run:
	@echo run

debug:
	@echo debug

test:
	@echo test

release:
	@echo release

install:
	@echo install

uninstall:
	@echo uninstall

clean:
	@echo clean
