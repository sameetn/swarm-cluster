#!/usr/bin/env bash

# Remove the droplet(s)
docker-machine rm -f jenkins-master

# Remove the DNS entries
echo "Removing the DNS record for the jenkins-master"
jenkins_record_id=$(doctl compute domain records list tmsapp.us --format ID,Name | grep jenkins | cut -f1)
command -v doctl >/dev/null 2>&1 && doctl compute domain records delete tmsapp.us $jenkins_record_id
