DIST ?= fc33
VERSION := $(file <version)
REL := $(file <rel)

FEDORA_SOURCES := https://src.fedoraproject.org/rpms/lorax/raw/f$(subst fc,,$(DIST))/f/sources
FEDORA_REL ?= $(REL)
SRC_FILE := lorax-$(VERSION).tar.gz

BUILDER_DIR ?= ../..
SRC_DIR ?= qubes-src

DISTFILES_MIRROR ?= https://ftp.qubes-os.org/distfiles/
UNTRUSTED_SUFF := .UNTRUSTED

fetch = $(or $(FETCH_CMD),$(error You can not run this Makefile without having FETCH_CMD defined))

SHELL := /bin/bash

%: %.sha512
	@$(fetch) $@$(UNTRUSTED_SUFF) $(DISTFILES_MIRROR)$@
	@sha512sum --status -c <(printf "$(file <$<)  -\n") <$@$(UNTRUSTED_SUFF) || \
		{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

.PHONY: get-sources
get-sources: $(SRC_FILE)

.PHONY: verify-sources
verify-sources:
	@true

.PHONY: clean-sources
clean-sources:
	@rm -f $(SRC_FILE)

# This target is generating content locally from upstream project
# 'sources' file. Sanitization is done but it is encouraged to perform
# update of component in non-sensitive environnements to prevent
# any possible local destructions due to shell rendering
.PHONY: update-sources
update-sources:
	@$(BUILDER_DIR)/$(SRC_DIR)/builder-rpm/scripts/generate-hashes-from-sources $(FEDORA_SOURCES)


.PHONY: get-sources-from-srpm
get-sources-from-srpm:
	@$(BUILDER_DIR)/$(SRC_DIR)/builder-rpm/scripts/get_sources_from_srpm $(DIST) lorax lorax-$(VERSION)-$(FEDORA_REL).$(DIST).src.rpm lorax-$(VERSION).tar.gz