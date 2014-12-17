#!/bin/sh
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"


  # Setup networking (80->80)
  config.vm.network :private_network, ip: "192.168.33.10"

  #Provision script - run once
  config.vm.provision "shell", path: "provisioning/provision.sh"

  # Copy the vhost file to default and reload apache - run every vagrant up
  config.vm.provision "shell", path: "provisioning/apache.sh"

  # Compass watch - don't run as sudo
#  config.vm.provision "shell", path: 'provisioning/compass.sh', privileged: false
end
