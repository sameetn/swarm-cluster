# Define the common script for installing docker
$script = <<SCRIPT
echo "Installing Docker..."
apt-get update
apt-get install curl -y
curl -fsSL https://test.docker.com/ | sh
echo "Completed Installing Docker"
SCRIPT

Vagrant.configure("2") do |config|

  # Stop gatling rsync on startup if the plugin exists
  config.gatling.rsync_on_startup = false if Vagrant.has_plugin?("vagrant-gatling-rsync")

  # Configure the swarm master
  config.vm.define "swarm-master" do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.box_check_update = false
    m.vm.hostname = "swarm-master"
    m.vm.network "private_network", ip: "10.100.198.200"
    m.vm.provision "shell", inline: $script, privileged: true
    m.vm.provider :virtualbox do |vb|
      vb.memory = 512
      vb.check_guest_additions = false
      vb.functional_vboxsf     = false
    end
    m.vm.provision :shell, inline: "docker swarm init --listen-addr 10.100.198.200:2377 --auto-accept worker"
    m.vm.provision :shell, inline: "docker run -it -d -p 5000:5000 -e HOST=swarm-master -e PORT=5000 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer"
  end

  # # Configure the swarm nodes
  (1..2).each do |i|
    config.vm.define  "swarm-node-#{i}" do |n|
      n.vm.box = "ubuntu/trusty64"
      n.vm.box_check_update = false
      n.vm.hostname =  "swarm-node-#{i}"
      n.vm.network "private_network", ip: "10.100.198.20#{i}"
      n.vm.provision "shell", inline: $script, privileged: true
      n.vm.provider :virtualbox do |vb|
        vb.memory = 1024
        vb.check_guest_additions = false
        vb.functional_vboxsf     = false
      end
      n.vm.provision :shell, inline: "docker swarm join --listen-addr 10.100.198.20#{i}:2377 10.100.198.200:2377"
    end
  end

end
