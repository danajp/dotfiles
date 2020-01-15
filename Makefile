PWD=$(shell pwd)

SCRIPTS_SRC:=$(wildcard bin/*)
SCRIPTS_DEST:=$(patsubst bin/%,~/bin/%,$(SCRIPTS_SRC))
DOT_SRC:=$(shell find dot/ -type f)
DOT_DEST:=$(patsubst dot/%,~/.%,$(DOT_SRC))

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
