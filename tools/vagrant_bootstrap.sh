#!/bin/bash

HOME="/workspace"

echo "IP=(\$(ip r | grep default))" >> /home/vagrant/.bashrc
echo "export LIBGL_ALWAYS_INDIRECT=1" >> /home/vagrant/.bashrc
echo "export DISPLAY=\${IP[2]}:0.0" >> /home/vagrant/.bashrc
echo "export PULSE_SERVER=tcp:\${IP[2]}" >> /home/vagrant/.bashrc
echo "cd $HOME" >> /home/vagrant/.bashrc

cd "$HOME/tools"
apt-get update > /dev/null
apt-get upgrade -y
apt-get install -y xorg
bash download_deps.sh -y