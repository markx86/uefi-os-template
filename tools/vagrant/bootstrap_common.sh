#!/bin/bash

HOME="/workspace"
echo "cd $HOME" >> /home/vagrant/.bashrc
cd "$HOME/tools"
apt-get update > /dev/null
apt-get upgrade -y
apt-get install -y xorg openssh-client openssh-server ssh
bash download_deps.sh -y