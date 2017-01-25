docker \
  network create --driver overlay monitoring

docker \
  service create --name cadvisor \
  --mode global \
  --network monitoring \
  --label com.docker.stack.namespace=monitoring \  
  --container-label com.docker.stack.namespace=monitoring \
  --mount type=bind,src=/,dst=/rootfs:ro \
  --mount type=bind,src=/var/run,dst=/var/run:rw \
  --mount type=bind,src=/sys,dst=/sys:ro \
  --mount type=bind,src=/var/lib/docker/,dst=/var/lib/docker:ro \
  google/cadvisor:v0.24.1

docker \
  service create --name node-exporter \
  --mode global \
  --network monitoring \
  --label com.docker.stack.namespace=monitoring \
  --container-label com.docker.stack.namespace=monitoring \
  --mount type=bind,source=/proc,target=/host/proc \
  --mount type=bind,source=/sys,target=/host/sys \
  --mount type=bind,source=/,target=/rootfs \
  --mount type=bind,source=/etc/hostname,target=/etc/host_hostname \
  -e HOST_HOSTNAME=/etc/host_hostname \
  basi/node-exporter:v0.1.1 \
  -collector.procfs /host/proc \
  -collector.sysfs /host/sys \
  -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)" \
  --collector.textfile.directory /etc/node-exporter/ \
  --collectors.enabled="conntrack,diskstats,entropy,filefd,filesystem,loadavg,mdadm,meminfo,netdev,netstat,stat,textfile,time,vmstat,ipvs"

docker \
  service create --name alertmanager \
  --network monitoring \
  --label com.docker.stack.namespace=monitoring \
  --container-label com.docker.stack.namespace=monitoring \
  --publish 9093:9093 \
  -e "SLACK_API=https://hooks.slack.com/services/TOKEN-HERE" \
  -e "LOGSTASH_URL=http://logstash:8080/" \
  basi/alertmanager:v0.1.0 \
    -config.file=/etc/alertmanager/config.yml

docker \
  service create \
  --name prometheus \
  --network monitoring \
  --label com.docker.stack.namespace=monitoring \
  --container-label com.docker.stack.namespace=monitoring \
  --publish 9090:9090 \
  basi/prometheus-swarm:v0.3.1 \
    -config.file=/etc/prometheus/prometheus.yml \
    -storage.local.path=/prometheus \
    -web.console.libraries=/etc/prometheus/console_libraries \
    -web.console.templates=/etc/prometheus/consoles \
    -alertmanager.url=http://alertmanager:9093

docker \
  service create \
  --name grafana \
  --network monitoring \
  --label com.docker.stack.namespace=monitoring \
  --container-label com.docker.stack.namespace=monitoring \
  --publish 3000:3000 \
  -e "GF_SERVER_ROOT_URL=http://grafana.${CLUSTER_DOMAIN}" \
  -e "GF_SECURITY_ADMIN_PASSWORD=$GF_PASSWORD" \
  -e "PROMETHEUS_ENDPOINT=http://prometheus:9090" \
  -e "ELASTICSEARCH_ENDPOINT=$ES_ADDRESS" \
  -e "ELASTICSEARCH_USER=$ES_USERNAME" \
  -e "ELASTICSEARCH_PASSWORD=$ES_PASSWORD" \
  basi/grafana:v4.1.1