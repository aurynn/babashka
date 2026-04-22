# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "babashka" do |v|

    v.vm.box = "bento/ubuntu-24.04"
    v.vm.synced_folder ".", "/vagrant"
    v.vm.provider "vmware_desktop" do |vmware|
      vmware.allowlist_verified = true
    end
    v.vm.provision "shell", run: :once, path: "vagrant/scripts/00-init.sh"
    v.vm.provision "shell", run: :once, name: :mo, path: "vagrant/scripts/01-mo.sh"

    v.vm.provision "shell", run: :once, name: "babashka", inline: <<-SHELL
    # Link the Babashka dependencies and helpers to /etc/babashka
    sudo mkdir /etc/babashka
    pushd /etc/babashka
    sudo ln -s /vagrant/dependencies .
    sudo ln -s /vagrant/helpers .
    popd
    sudo mkdir /etc/kitbash
    pushd /etc/kitbash
    sudo ln -s /vagrant/vagrant/etc/kitbash/kits .
    sudo ln -s /vagrant/vagrant/etc/kitbash/models.d .
    sudo ln -s /vagrant/vagrant/etc/kitbash/local .
    sudo ln -s /vagrant/vagrant/etc/kitbash/variables .
    sudo ln -s /vagrant/bin/babashka /usr/bin/kitbash
    SHELL
    v.vm.provision "shell", run: :once, name: :mise, path: "vagrant/scripts/02-mise.sh" 
  end

  # we can run the tests now, if we like

end
