PWD=`pwd`

install: clean
	echo "export ETC_DIR='$(PWD)'" > ~/.bashrc
	echo 'source $$ETC_DIR/bashrc' >> ~/.bashrc
	ln -s $(PWD)/bash_profile ~/.bash_profile
	ln -s $(PWD)/screenrc ~/.screenrc
	ln -s $(PWD)/gemrc ~/.gemrc

clean:
	if [ -h ~/.bashrc ]; then rm ~/.bashrc;	fi
	if [ -h ~/.bash_profile ]; then rm ~/.bash_profile; fi
	if [ -h ~/.screenrc ]; then rm ~/.screenrc;	fi
