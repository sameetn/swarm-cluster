#!/usr/bin/env bash

echo "Clean up existing contianers"
docker-machine ssh swarm-master docker rm -fv portainer
docker-machine ssh swarm-master docker rm -fv visualizer

echo "Stopping the swarm master and nodes"
docker-machine stop swarm-{master,node-1,node-2}

echo "Stopping the jenkins master"
docker-machine stop jenkins-master
