PWD=$(shell pwd)

.PHONY: install
install: bash bin i3 other

.PHONY: clean
clean:
	rm -f ~/.bashrc
	rm -f ~/.bash_profile
	rm -f ~/.gemrc
	rm -rf ~/.i3
	rm -f ~/.Xmodmap
	rm -f ~/.Xresources

.PHONY: bash
bash: ~/.bashrc ~/.bash_profile

~/.bashrc:
	ln -s $(PWD)/bashrc ~/.bashrc

~/.bash_profile:
	ln -s $(PWD)/bash_profile ~/.bash_profile

.PHONY: bin
bin: volume brightness ~/bin/vpn ~/bin/lock ~/bin/hotplug-monitor

~/bin:
	mkdir ~/bin

.PHONY: brightness
brightness: ~/bin/brightness-up ~/bin/brightness-down

~/bin/brightness: | ~/bin
	cd ~/bin && ln -s $(PWD)/bin/brightness brightness

~/bin/brightness-up: ~/bin/brightness
	cd ~/bin && ln -s brightness brightness-up

~/bin/brightness-down: ~/bin/brightness
	cd ~/bin && ln -s brightness brightness-down

.PHONY: volume
volume: ~/bin/volume-up ~/bin/volume-down ~/bin/volume-toggle-mute ~/bin/click.wav

~/bin/volume: | ~/bin
	cd ~/bin && ln -s $(PWD)/bin/volume volume

~/bin/volume-up: ~/bin/volume
	cd ~/bin && ln -s volume volume-up

~/bin/volume-down: ~/bin/volume
	cd ~/bin && ln -s volume volume-down

~/bin/volume-toggle-mute: ~/bin/volume
	cd ~/bin && ln -s volume volume-toggle-mute

~/bin/click.wav:
	cd ~/bin && ln -s $(PWD)/bin/click.wav

~/bin/vpn: | ~/bin
	cd ~/bin && ln -s $(PWD)/bin/vpn vpn

~/bin/lock: | ~/bin
	cd ~/bin && ln -s $(PWD)/bin/lock lock

~/bin/hotplug-monitor: | ~/bin
	cd ~/bin && ln -s $(PWD)/bin/hotplug-monitor hotplug-monitor

.PHONY: i3
i3: ~/.i3/config ~/.i3/i3status.conf

~/.i3:
	mkdir -p ~/.i3

~/.i3/config: | ~/.i3
	ln -s $(PWD)/i3/config ~/.i3/config

~/.i3/i3status.conf: | ~/.i3
	ln -s $(PWD)/i3/i3status.conf ~/.i3/i3status.conf

.PHONY: other
other: ~/.gemrc ~/.screenrc ~/.Xmodmap gitconfig ~/.Xresources ~/.openvpnrc

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
