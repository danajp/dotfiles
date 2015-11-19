PWD=`pwd`

install: ~/.bashrc ~/.bash_profile ~/.i3/config ~/.screenrc

clean:
	rm -f ~/.bashrc
	rm -f ~/.bash_profile
	rm -f ~/.gemrc
	rm -rf ~/.i3

~/.bashrc:
	ln -s $(PWD)/bashrc ~/.bashrc

~/.bash_profile:
	ln -s $(PWD)/bash_profile ~/.bash_profile

~/.gemrc:
	ln -s $(PWD)/gemrc ~/.gemrc

~/.i3:
	mkdir -p ~/.i3

~/.i3/config: ~/.i3
	ln -s $(PWD)/i3-config ~/.i3/config

~/.i3/i3status.conf: ~/.i3
	ln -s $(PWD)/i3-i3status.conf ~/.i3/i3status.conf

~/.screenrc:
	ln -s $(PWD)/screenrc ~/.screenrc
