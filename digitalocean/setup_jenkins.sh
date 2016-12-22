# Run the settings for DigitalOcean
[ -f ~/bin/settings_do.sh ] && source ~/bin/settings_do.sh

# Create the jenkins droplet
echo "Creating jenkins master"
docker-machine create \
  -d digitalocean \
  --digitalocean-access-token=$DO_ACCESS_TOKEN \
  --digitalocean-size 1gb \
  --digitalocean-ssh-key-fingerprint=$DO_KEY \
  jenkins-master
master_ip=$(docker-machine ip jenkins-master)

echo "Setup a DNS record for the jenkins-master"
command -v doctl >/dev/null 2>&1 && \
  doctl compute domain records create tmsapp.us --record-data $master_ip \
    --record-name jenkins --record-type A

# Install Jenkins using apt-get
docker-machine ssh jenkins-master 'wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -'
docker-machine ssh jenkins-master 'echo "deb https://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list'
docker-machine ssh jenkins-master 'apt-get -y update'
docker-machine ssh jenkins-master 'apt-get -y install jenkins'