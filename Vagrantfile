module OS
  def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
      !OS.windows?
  end

  def OS.linux?
      OS.unix? and not OS.mac?
  end
end


Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.synced_folder ".", "/workspace"
  config.vm.hostname = "OSDevVM"
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  if OS.windows?
    config.vm.provision :shell, path: "tools/vagrant/bootstrap_windows.sh"
  elsif OS.linux?
    config.vm.provision :shell, path: "tools/vagrant/bootstrap_linux.sh"
  end
end
