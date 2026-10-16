# Makefile for scales (Skink Package Manager & Module Resolution System)
#
# Usage:
#   make          - build the scales binary
#   make check    - type-check scales without linking
#   make test     - run scales unit and integration test suite
#   make install  - install scales to $(BINDIR)
#   make clean    - remove build artifacts

SKINK_PREFIX ?= $(HOME)/.local/skink
BINDIR       ?= $(SKINK_PREFIX)/bin
SKINK        ?= skink
SKINK_HOME   ?= $(SKINK_PREFIX)/std

SCALES_BIN   := scales
SCALES_MAIN  := scales.skink
SCALES_PKGS  := $(wildcard pkg/*.skink) version.skink

.DEFAULT_GOAL := all
.PHONY: all build check test install uninstall clean help

all: build

build: $(SCALES_BIN)

$(SCALES_BIN): $(SCALES_MAIN) $(SCALES_PKGS)
	@echo "Building scales..."
	SKINK_HOME=$(SKINK_HOME) $(SKINK) -o $(SCALES_BIN) $(SCALES_MAIN)
	@echo "Built: $(SCALES_BIN)"

check:
	@echo "Type-checking scales..."
	SKINK_HOME=$(SKINK_HOME) $(SKINK) -check $(SCALES_MAIN)

test: build
	@echo "Running scales test suite..."
	SKINK_HOME=$(SKINK_HOME) $(SKINK) -t scales_test.skink

install: build
	@echo "Installing scales to $(BINDIR)..."
	install -d $(BINDIR)
	cp -f $(SCALES_BIN) $(BINDIR)/$(SCALES_BIN)
	chmod 755 $(BINDIR)/$(SCALES_BIN)
	@echo "Installed: $(BINDIR)/$(SCALES_BIN)"

uninstall:
	rm -f $(BINDIR)/$(SCALES_BIN)

clean:
	rm -f $(SCALES_BIN) *.ll *.o __skink_test_bin*

help:
	@echo "scales Build System"
	@echo "  make          - Build scales binary"
	@echo "  make check    - Type-check only"
	@echo "  make test     - Run unit & integration tests"
	@echo "  make install  - Install scales to $(BINDIR)"
	@echo "  make clean    - Remove build artifacts"
