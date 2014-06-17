# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |vb, override|
    #vb.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
    override.vx.box = "ubuntu/trusty64"
  end

  config.vm.provider "vmware_fusion" do |fs, override|
    #override.vm.box_url = 'http://files.vagrantup.com/precise64_vmware.box'
    override.vm.box = 'jpease/ubuntu-trusty'
  end

  %w{ mq web worker logger }.each_with_index do |name, idx|
    config.vm.define name.to_sym do |s|
      ip = "192.168.47.#{idx + 10}"
      s.vm.network :private_network, ip: ip
      s.vm.hostname = "#{name}.vexor.local"

      case name
      when  "worker"
        s.vm.network :forwarded_port, guest: 4243, host: 4243 # docker
        s.vm.network :forwarded_port, guest: 2022, host: 2122 # docker
      when  "web"
        s.vm.network :forwarded_port, guest: 5432, host: 5432 # pg
      when "mq"
        s.vm.network :forwarded_port, guest: 5672, host: 5672 # amqp
        s.vm.network :forwarded_port, guest: 15672, host: 15672 # amqp ui
      end
    end
  end

  sources = <<SOURCES
#############################################################
################### OFFICIAL UBUNTU REPOS ###################
#############################################################

###### Ubuntu Main Repos
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse

###### Ubuntu Update Repos
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
SOURCES

  script = <<SCRIPT
set -e

echo "---> Update /etc/apt/sources.list"

cat > /etc/apt/sources.list <<EOL
#{sources}
EOL

echo "---> Run apt-get update"
apt-get update -qy > /dev/null
SCRIPT

  config.vm.provision "shell", inline: script
end

