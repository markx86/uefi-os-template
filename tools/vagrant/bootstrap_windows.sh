#!/bin/bash

bash "/workspace/tools/vagrant/bootstrap_common.sh"

echo "IP=(\$(ip r | grep default))" >> /home/vagrant/.bashrc
echo "export LIBGL_ALWAYS_INDIRECT=1" >> /home/vagrant/.bashrc
echo "export DISPLAY=\${IP[2]}:0.0" >> /home/vagrant/.bashrc
echo "export PULSE_SERVER=tcp:\${IP[2]}" >> /home/vagrant/.bashrc