echo "------------------------------------------"
echo "Setting up jenkins"
echo "------------------------------------------"

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
docker-machine ssh jenkins-master 'apt-get -qq -y update'
docker-machine ssh jenkins-master 'apt-get -qq -y install jenkins'

# Add jenkins to the docker group
docker-machine ssh jenkins-master 'chown -R root:docker /var/lib/docker'
docker-machine ssh jenkins-master 'usermod -a -G docker jenkins'

# Install nodejs
docker-machine ssh jenkins-master 'curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh'
docker-machine ssh jenkins-master 'chmod +x ./nodesource_setup.sh && ./nodesource_setup.sh && apt-get -qq -y install nodejs'

# Create jenkins keys and copy those to the swarm manager
docker-machine ssh jenkins-master "su - jenkins -c 'mkdir ~/.ssh && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N \"\" && chmod -R 700 ~/.ssh'"
jenkins_key=$(docker-machine ssh jenkins-master cat ~jenkins/.ssh/id_rsa.pub)
docker-machine ssh swarm-master "echo $jenkins_key >> ~/.ssh/authorized_keys"
