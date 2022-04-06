setup:
	brew install --cask virtualbox
	brew install vagrant
	echo "* 0.0.0.0/0 ::/0" >> /etc/vbox/networks.conf
	vagrant up
	vagrant ssh-config chuspace > .ssh/chuspace
