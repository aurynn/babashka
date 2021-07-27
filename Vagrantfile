# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.allowlist_verified = true
  end
  config.vm.provision "shell", run: :once, inline: <<-SHELL
  echo "Removing i386 from dpkg"
  sudo dpkg --remove-architecture i386
  echo "Doing initial apt-get updates"
  sudo apt-get -qq update > /dev/null
  sudo apt-get -qq dist-upgrade > /dev/null
  sudo apt-get -qq autoremove
  SHELL

  config.vm.provision "shell", run: :once, inline: <<-SHELL
  # Link the Babashka dependencies and helpers to /etc/babashka
  sudo mkdir /etc/babashka
  pushd /etc/babashka
  sudo ln -s /vagrant/dependencies .
  sudo ln -s /vagrant/helpers .
  SHELL

  config.vm.provision "reload", run: :once

  # we can run the tests now, if we like


end
