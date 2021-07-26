Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.synced_folder ".", "/workspace"
  config.vm.provision :shell, path: "tools/vagrant_bootstrap.sh"
  config.vm.hostname = "OSDevVM"
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
end
