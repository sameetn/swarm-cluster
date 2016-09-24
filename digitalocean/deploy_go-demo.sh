# switch to swarm master
eval $(docker-machine env swarm-master)

# Create the go-demo overlay network
docker network create --driver overlay go-demo
echo "Network created for go-demo"
docker network ls

#  Deploy the mongo-db service on the go-demo network
docker service create --name go-demo-db --network go-demo mongo
sleep 5
echo "DB deployed"
docker service inspect --pretty go-demo-db

# Create the proxy network for reverse proxy
docker network create --driver overlay proxy

# Deploy the app container on the go-demo and the proxy network
docker service create --name go-demo -e DB=go-demo-db \
   --network go-demo --network proxy vfarcic/go-demo
sleep 5
echo "Application deployeed"
docker service inspect --pretty go-demo

# Create the proxy
docker service create --name proxy \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    --network proxy \
    -e MODE=swarm \
    vfarcic/docker-flow-proxy
sleep 5
curl "$(docker-machine ip swarm-node-1):8080/v1/docker-flow-proxy/reconfigure?serviceName=go-demo&servicePath=/demo&port=8080"
echo "Proxy deployeed"
docker service inspect --pretty proxy

# Test the Proxy and service setup
curl -i $(docker-machine ip swarm-node-1)/demo/hello


