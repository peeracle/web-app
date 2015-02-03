# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
BOX_HEAVY = "peeracle/utopic64"
BOX_LIGHT = "hashicorp/precise64"

domain = 'peeracle.local'

nodes = [
  { :hostname => 'api', :ip => '192.168.250.50', :box => BOX_HEAVY, :ram => 512, :shared => true },
  { :hostname => 'client', :ip => '192.168.250.51', :box => BOX_LIGHT, :ram => 128, :shared => true },
  { :hostname => 'db', :ip => '192.168.250.52', :box => BOX_HEAVY, :ram => 512, :shared => false },
  { :hostname => 'redis', :ip => '192.168.250.53', :box => BOX_LIGHT, :ram => 128, :shared => false },
  { :hostname => 'mq', :ip => '192.168.250.54', :box => BOX_LIGHT, :ram => 128, :shared => false },
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|

      node_config.hostmanager.enabled = true
      node_config.hostmanager.manage_host = true
      node_config.hostmanager.ignore_private_ip = false
      node_config.hostmanager.include_offline = true
      
      node_config.vm.box = node[:box]
      node_config.vm.host_name = node[:hostname] + '.' + domain
	  node_config.vm.network "private_network", ip: node[:ip], auto_correct: true

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm.provider :virtualbox do |v|
	v.customize [
	  'modifyvm', :id,
	  '--name', node[:hostname],
	  '--memory', memory.to_s
	]
      end
      
      if node[:shared] == true
	node_config.vm.synced_folder node[:hostname], '/home/vagrant/' + node[:hostname],
		                     owner: 'vagrant',
		                     group: 'vagrant'
      end

      node_config.vm.provision :hostmanager
    end
    
  end
  
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = 'vagrant/puppet/manifests'
    puppet.manifest_file = 'site.pp'
    puppet.module_path = 'vagrant/puppet/modules'
  end
end
