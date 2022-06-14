#!/bin/bash

set -e

sudo apt-get -y update
sudo apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-dev ca-certificates \
                   git-core curl locales libmysqlclient-dev libsqlite3-dev tzdata memcached libmemcached-tools
sudo locale-gen en_US.UTF-8

sudo adduser --disabled-password deployer < /dev/null
sudo mkdir -p /home/deployer/.ssh

sudo cp /home/ubuntu/.ssh/authorized_keys /home/deployer/.ssh
sudo chown -R deployer:deployer /home/deployer/.ssh
sudo chmod 600 /home/deployer/.ssh/authorized_keys
sudo mkdir -p /var/www
sudo chown deployer:deployer /var/www
sudo loginctl enable-linger deployer
sudo systemctl restart memcached

