PWD=$(shell pwd)

SCRIPTS_SRC:=$(wildcard bin/*)
SCRIPTS_DEST:=$(patsubst bin/%,~/bin/%,$(SCRIPTS_SRC))

.PHONY: scripts
scripts: ~/bin $(SCRIPTS_DEST)

~/bin:
	mkdir ~/bin

~/bin/%: bin/%
	ln -s $(PWD)/$< $@

.PHONY: install
install: bash scripts i3 other

.PHONY: clean
clean:
	rm -f ~/.bashrc
	rm -f ~/.bash_profile
	rm -f ~/.gemrc
	rm -rf ~/.i3
	rm -f ~/.Xmodmap
	rm -f ~/.Xresources
	rm -f ~/.tmux.conf

.PHONY: bash
bash: ~/.bashrc ~/.bash_profile

~/.bashrc:
	ln -s $(PWD)/bashrc ~/.bashrc

~/.bash_profile:
	ln -s $(PWD)/bash_profile ~/.bash_profile

~/.config:
	mkdir ~/.config

.PHONY: i3
i3: ~/.i3/config ~/.i3/i3status.conf

~/.i3:
	mkdir -p ~/.i3

~/.i3/config: | ~/.i3
	ln -s $(PWD)/i3/config ~/.i3/config

~/.i3/i3status.conf: | ~/.i3
	ln -s $(PWD)/i3/i3status.conf ~/.i3/i3status.conf

.PHONY: other
other: ~/.gemrc ~/.screenrc ~/.Xmodmap gitconfig ~/.Xresources ~/.openvpnrc ~/.tmux.conf ~/.config/powerline

~/.gemrc:
	ln -s $(PWD)/gemrc ~/.gemrc

~/.screenrc:
	ln -s $(PWD)/screenrc ~/.screenrc

~/.Xmodmap:
	ln -s $(PWD)/Xmodmap ~/.Xmodmap

~/.Xresources:
	ln -s $(PWD)/Xresources ~/.Xresources

.PHONY: gitconfig
gitconfig:
	git config --global include.path $(PWD)/gitconfig

~/.openvpnrc:
	ln -s $(PWD)/openvpnrc ~/.openvpnrc

~/.tmux.conf:
	ln -s $(PWD)/tmux.conf ~/.tmux.conf

~/.config/powerline: ~/.config
	cd ~/.config && ln -s $(PWD)/powerline
