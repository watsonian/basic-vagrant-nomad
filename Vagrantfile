# -*- mode: ruby -*-
# vi: set ft=ruby :

NOMAD_CLIENTS=2
NOMAD_SERVERS=3
CONSUL_SERVERS=1

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant"

  1.upto(CONSUL_SERVERS) do |n|
    config.vm.define "consul-server-#{n}" do |server|
      server.vm.box = "bento/ubuntu-21.04"
      server.vm.hostname = "consul-server-#{n}"
      server.vm.network "private_network", type: "dhcp"

      if n == 1
        server.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"
      end

      server.vm.provision "shell", path: "scripts/bootstrap-ip.sh", privileged: false
      server.vm.provision "shell", path: "scripts/bootstrap-consul.sh", privileged: false

      server.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
    end
  end

  1.upto(NOMAD_SERVERS) do |n|
    config.vm.define "nomad-server-#{n}" do |server|
      server.vm.box = "bento/ubuntu-21.04"
      server.vm.hostname = "nomad-server-#{n}"
      server.vm.network "private_network", type: "dhcp"

      if n == 1
        server.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true, host_ip: "127.0.0.1"
      end
  
      server.vm.provision "shell", path: "scripts/bootstrap-ip.sh", privileged: false
      server.vm.provision "shell", path: "scripts/bootstrap-nomad.sh", privileged: false
  
      server.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
    end
  end

  1.upto(NOMAD_CLIENTS) do |n|
    config.vm.define "nomad-client-#{n}" do |server|
      server.vm.box = "bento/ubuntu-21.04"
      server.vm.hostname = "nomad-client-#{n}"
      server.vm.network "private_network", type: "dhcp"

      server.vm.provision "shell", path: "scripts/bootstrap-ip.sh", privileged: false
      server.vm.provision "shell", path: "scripts/bootstrap-nomad-client.sh", privileged: false

      if n == NOMAD_CLIENTS
        server.vm.provision "shell", path: "scripts/bootstrap-nomad-run-job.sh", privileged: false  
      end

      server.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
    end
  end
end
