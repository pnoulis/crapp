#!/usr/bin/make -f
SHELL := /bin/bash

INSTALL := /usr/bin/install

all: run

run:
	@./src/crapp.bash

install:
	@cp src/crapp.bash ~/bin/crapp && chmod +x ~/bin/crapp

.PHONY: all run install
.DEFAULT_GOAL := all