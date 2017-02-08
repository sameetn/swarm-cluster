#!/usr/bin/env bash

# Remove the droplets
docker-machine rm -f swarm-{master,node-1,node-2}

# Remove the DNS entries
echo "Removing the DNS record for the swarm-master"
master_record_id=$(doctl compute domain records list tmsapp.us --format ID,Name | grep swarm-master | cut -f1)
command -v doctl >/dev/null 2>&1 && doctl compute domain records delete tmsapp.us $master_record_id