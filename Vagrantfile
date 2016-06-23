Vagrant.configure("2") do |config|

  # Stop gatling rsync on startup
  config.gatling.rsync_on_startup = false

  # Configure the swarm master
  config.vm.define "swarm-master" do |m|
    m.vm.box = "docker-swarm/base"
    m.vm.box_check_update = false
    m.vm.hostname = "swarm-master"
    m.vm.network "private_network", ip: "10.100.198.200"
    m.vm.provider :virtualbox do |vb|
      vb.memory = 512
      # On VirtualBox, we don't have guest additions or a functional vboxsf
      # in CoreOS, so tell Vagrant that to make it  smarter.
      vb.check_guest_additions = false
      vb.functional_vboxsf     = false
    end
    m.vm.provision :shell, inline: "docker swarm init"
  end

  # # Configure the swarm nodes
  (1..2).each do |i|
    config.vm.define  "swarm-node-#{i}" do |n|
      n.vm.box = "docker-swarm/base"
      n.vm.box_check_update = false
      n.vm.hostname =  "swarm-node-#{i}"
      n.vm.network "private_network", ip: "10.100.198.20#{i}"
      n.vm.provider :virtualbox do |vb|
        vb.memory = 1024
        # On VirtualBox, we don't have guest additions or a functional vboxsf
        # in CoreOS, so tell Vagrant that to make it  smarter.
        vb.check_guest_additions = false
        vb.functional_vboxsf     = false
        vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
      end
      n.vm.provision :shell, inline: "docker swarm join"
    end
  end

end
