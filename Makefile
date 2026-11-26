##
# Makefile for locate-cc
# docs/main.md is the README source. README.md is generated; do not edit it.
# Requires markdown-toc-go to build the docs.
##
MTOC := markdown-toc-go

.PHONY: all docs check help

all: help

# generate README.md from docs/main.md
docs:
	@command -v $(MTOC) >/dev/null || { echo "$(MTOC) not found"; exit 1; }
	$(MTOC) -i docs/main.md -o README.md --glossary docs/glossary.txt -f

# syntax check the script
check:
	bash -n locate_cc.sh

help:
	@echo "make docs  - generate README.md from docs/main.md"
	@echo "make check - syntax check locate_cc.sh"
