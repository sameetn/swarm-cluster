#!/usr/bin/env bash

docker-machine rm -f swarm-{master,node-1,node-2}
docker-machine rm -f jenkins-master
