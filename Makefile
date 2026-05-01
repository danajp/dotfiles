PWD=$(shell pwd)

SCRIPTS_SRC:=$(wildcard bin/*)
SCRIPTS_DEST:=$(patsubst bin/%,~/bin/%,$(SCRIPTS_SRC))
DOT_SRC:=$(shell find dot/ -type f)
DOT_DEST:=$(patsubst dot/%,~/.%,$(DOT_SRC))

HOSTS:=thinkpad framework

# ── Home Manager: validation & refactor safety ──────────────────────
#
# Recommended workflow during refactoring:
#   1. make snapshot         # capture current generated configs as baseline
#   2. <make a refactor change>
#   3. make verify           # build both hosts, lint, diff vs baseline
#   4. <if clean: commit; if not: investigate the diff>

.PHONY: check
check:
	nix flake check --all-systems

# Pure-Nix unit tests for helpers in lib/. Defined in tests/.
.PHONY: test
test:
	nix run nixpkgs#nix-unit -- --flake .#tests

.PHONY: lint
lint:
	-nix run nixpkgs#deadnix -- machines/ lib/ tests/ flake.nix
	-nix run nixpkgs#statix  -- check .

# Strict lint: same as lint, but fails on any finding. Use after the
# refactor stabilizes to enforce a clean baseline going forward.
.PHONY: lint-strict
lint-strict:
	nix run nixpkgs#deadnix -- --fail machines/ lib/ tests/ flake.nix
	nix run nixpkgs#statix  -- check .

.PHONY: build-all
build-all:
	@for host in $(HOSTS); do \
	  echo "==> Building dana@$$host"; \
	  ( cd $$(mktemp -d) && home-manager build --flake $(PWD)#dana@$$host ) \
	    || exit 1; \
	done

.PHONY: snapshot
snapshot:
	./bin/hm-snapshot

.PHONY: diff
diff:
	./bin/hm-diff --summary

.PHONY: diff-full
diff-full:
	./bin/hm-diff

# `verify` is the one-shot safety gate to run after every refactor change.
# Order: cheapest checks first so failures surface fast.
.PHONY: verify
verify: check test lint build-all diff
	@echo
	@echo "✓ verify: all checks passed"

.PHONY: home-manager-install
home-manager-install:
	ln -s $(PWD) $(HOME)/.config/home-manager

.PHONY: install
install: dots scripts

.PHONY: scripts
scripts: ~/bin $(SCRIPTS_DEST)

.PHONY: dots
dots: $(DOT_DEST)

.PHONY: clean
clean:
	rm -f ~/.bashrc
	rm -f ~/.bash_profile

~/.%: dot/%
	mkdir -p "$(@D)"
	ln -sf "$(PWD)/$<" "$@"

~/bin:
	mkdir ~/bin

~/bin/%: bin/%
	ln -sf $(PWD)/$< $@
