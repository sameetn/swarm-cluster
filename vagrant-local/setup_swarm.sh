#!/usr/bin/env bash

swarm_nodes="swarm-node-1-local swarm-node-2-local"

echo "Creating the master"
docker-machine create -d virtualbox swarm-master-local
master_ip=$(docker-machine ip swarm-master)

echo "Initializing the swarm mode"
docker-machine ssh swarm-master docker swarm init --advertise-addr $master_ip

join_token=$(docker-machine ssh swarm-master docker swarm join-token -q worker)
echo "Join token is ${join_token}"

# Setup the portainer management
docker-machine ssh swarm-master \
  docker run --name=portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

# Setup the swarm visualizer
docker-machine ssh swarm-master \
  docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer


# Create and join the workers
for worker in $swarm_nodes; do
  echo "Creating worker ${worker}"
  docker-machine create -d virtualbox ${worker}
  docker-machine ssh $worker docker swarm join --token $join_token $master_ip:2377
done
