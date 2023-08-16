#!/usr/bin/make -f

# Package
PKG_VERSION=0.0.1
PKG_VVERSION=v$(PKG_VERSION)

# Installation directories
PKGDIR_ABS := /home/pnoul/projects/pp/crapp
PKGDIR := .
SRCDIR := $(PKGDIR)/src
SRCDIR_ABS := $(PKGDIR_ABS)/src
BINDIR := ~/bin
DATADIR := ~/.local/share/crapp
TEMPDIR := /tmp

# Devired directories
TEMPLATESROOTDIR = ~/.local/share/crapp/templates
MACROSDIR = $(PKGDIR)/lib
INSTALLATION_DIRS  = $(BINDIR) $(DATADIR) $(TEMPLATESROOTDIR)

# Sources
VPATH := $(SRCDIR) $(MACROSDIR)
EXECUTABLE = crapp
CRAPP := $(BINDIR)/$(EXECUTABLE)
OBJS = $(addprefix $(SRCDIR)/, config common filenames subcommands crapp)

# Macro
MPP = /usr/bin/m4
MPP_INCLUDES = -I $(SRCDIR)
MPP_DEFINES =  -D __TEMPLATESROOTDIR__=$(TEMPLATESROOTDIR) \
	-D __TEMPDIR__=$(TEMPDIR) \
	-D __CRAPP__=$(CRAPP) \
	-D __VERSION__=$(PKG_VVERSION) \

MPP_MACROS = macros
MPP_FLAGS = $(MPP_INCLUDES) $(MPP_DEFINES) $(MPP_MACROS)


.DEFAULT_GOAL := all
all: build


install: build
	cp -f $(EXECUTABLE) $(BINDIR)/$(EXECUTABLE)
	chmod +x $(BINDIR)/$(EXECUTABLE)
	mkdir -p $(TEMPLATESROOTDIR)
	cp -r templates/* $(TEMPLATESROOTDIR)

uninstall:
	@printf "'%s'\n" 'rm -irdf $(BINDIR)/$(EXECUTABLE)'
	@printf "'%s'\n" 'rm -irdf $(TEMPLATESROOTDIR)'

build: $(EXECUTABLE)

$(EXECUTABLE): $(MPP_MACROS) $(OBJS)
	$(MPP) $(MPP_FLAGS) $(SRCDIR)/crapp > $@
	chmod +x $@

# Objects
$(SRCDIR)/%: %.sh
	$(MPP) $(MPP_FLAGS) $< > $@

$(MPP_MACROS): $(MACROSDIR)/*.m4
	cp -f $< $@

clean:
	-rm -f $(OBJS)
	-rm -f $(EXECUTABLE)
	-rm -f $(MPP_MACROS)

distclean: clean
	-rm -f $(PKGDIR)/Makefile

test:
	@echo $(MPP_DEFINES)

.PHONY: all install build clean distclean test
