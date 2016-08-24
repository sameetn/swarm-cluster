# Define the common script for installing docker
$setup_docker = <<SETUP_DOCKER
  echo "Installing Docker..."
  apt-get -q -y update
  apt-get install curl -y -q
  curl -fsSL https://get.docker.com/ | sh > /dev/null
  echo "Completed Installing Docker"
  usermod -aG docker vagrant
SETUP_DOCKER

# Script to startup and configure vault
$setup_vault = <<VAULT
  echo "Installing Vault"
  mkdir -p /opt/vault 
  cd /opt/vault
  echo "Current directory is `pwd`"
  wget https://releases.hashicorp.com/vault/0.6.0/vault_0.6.0_linux_amd64.zip
  apt-get install -y -q unzip
  unzip /opt/vault/vault_0.6.0_linux_amd64.zip
VAULT

# Store the worker token in the cluster
$store_worker_token = <<STORE_WORKER_TOKEN
  /opt/vault/vault write -address=http://10.100.198.200:8200 secret/worker-token value=`docker swarm join-token -q worker`
STORE_WORKER_TOKEN

# Join the swarm cluster
$join_cluster = <<JOIN_CLUSTER
  docker swarm join --advertise-addr 10.100.198.20#{i}:2377 10.100.198.200:2377 \
    --token `/opt/vault/vault read -address=http://10.100.198.200:8200 -field=value secret/worker-token`
JOIN_CLUSTER


Vagrant.configure("2") do |config|

  # Stop gatling rsync on startup if the plugin exists
  config.gatling.rsync_on_startup = false if Vagrant.has_plugin?("vagrant-gatling-rsync")

  # Configure the swarm master
  config.vm.define "swarm-master" do |m|
    m.vm.box = "ubuntu/trusty64"
    m.vm.box_check_update = false
    m.vm.hostname = "swarm-master"
    m.vm.network "private_network", ip: "10.100.198.200"
    m.vm.provider :virtualbox do |vb|
      vb.memory = 512
      vb.check_guest_additions = false
      vb.functional_vboxsf     = false
    end
    m.vm.provision :shell, inline: $setup_docker, privileged: true
    m.vm.provision :shell, inline: "docker swarm init --listen-addr 10.100.198.200:2377 --advertise-addr 10.100.198.200:2377"
    m.vm.provision :shell, inline: "docker run -it -d -p 5000:5000 -e HOST=swarm-master -e PORT=5000 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer"
    m.vm.provision :shell, inline: $setup_vault, privileged: true
    m.vm.provision :shell, inline: "docker run -e 'VAULT_DEV_LISTEN_ADDRESS=10.100.198.200:8200' vault"
    m.vm.provision :shell, inline: $store_worker_token
  end

  # # Configure the swarm nodes
  (1..2).each do |i|
    config.vm.define  "swarm-node-#{i}" do |n|
      n.vm.box = "ubuntu/trusty64"
      n.vm.box_check_update = false
      n.vm.hostname =  "swarm-node-#{i}"
      n.vm.network "private_network", ip: "10.100.198.20#{i}"
      n.vm.provider :virtualbox do |vb|
        vb.memory = 1024
        vb.check_guest_additions = false
        vb.functional_vboxsf     = false
      end
      n.vm.provision :shell, inline: $setup_docker, privileged: true
      n.vm.provision :shell, inline: $setup_vault, privileged: true
      n.vm.provision :shell, inline: $join_cluster
    end
  end

end
