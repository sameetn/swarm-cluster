#!/usr/bin/env bash

echo "Starting swarm master and nodes"
docker-machine start swarm-{master,node-1,node-2}

echo "Update the DNS record for the swarm-master"
master_ip=$(docker-machine ip swarm-master)
master_record_id=$(doctl compute domain records list tmsapp.us --format ID,Name | grep swarm-master | cut -f1)
command -v doctl >/dev/null 2>&1 && \
  doctl compute domain records update tmsapp.us --record-data $master_ip \
    --record-name swarm-master --record-type A --record-id $master_record_id

echo "Setting up Portainer for controlling the swarm"
docker-machine ssh swarm-master \
  docker run --name=portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer --swarm

echo "Setting up a Swarm visualizer for visualizing the cluster per node"
docker-machine ssh swarm-master \
  docker run -it -d --name=visualizer -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer

echo "Starting Jenkins"
docker-machine start jenkins-master

echo "Update the DNS record for the jenkins-master"
jenkins_master_ip=$(docker-machine ip jenkins-master)
jenkins_record_id=$(doctl compute domain records list tmsapp.us --format ID,Name | grep jenkins | cut -f1)
command -v doctl >/dev/null 2>&1 && \
  doctl compute domain records update tmsapp.us --record-data $jenkins_master_ip \
    --record-name jenkins --record-type A --record-id $jenkins_record_id