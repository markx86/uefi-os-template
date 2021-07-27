#!/bin/bash

bash "/workspace/tools/vagrant/bootstrap_common.sh"

echo "AddressFamily inet" | tee -a "/etc/ssh/sshd_config.d/x11linuxredirection.conf"
echo "X11Forwarding yes" | tee -a "/etc/ssh/sshd_config.d/x11linuxredirection.conf"
echo "X11UseLocalhost yes" | tee -a "/etc/ssh/sshd_config.d/x11linuxredirection.conf"
echo "export DISPLAY=:10" >> /home/vagrant/.bashrc

service sshd restart
service ssh restart