# Swarm cluster on Vagrant

This creates a docker swarm cluster using the swarm mode in Docker 1.12.0 and later. To use this you need Vagrant 1.8 or later installed.
Once you clone this repo all you need to do is run `vagrant up`. This will start the swarm-master and two nodes. 
It also sets up a swarm visualizer at http://10.100.198.200:5000 which allows you to visualize any containers you deploy to the swarm.
The following screenshot shows 10 instances of a container across all the nodes.

![Swarm Cluster Screenshot]
(swarm_diagram.png) 

