## README

## Auto launch
# Launch 3 node emqttd cluster with HAProxy load balancing
. ./launcher/launch.sh

# Remove all containers
. ./launcher/cleanup.sh


## Manual launch
# Build the docker images
docker build -t broker:latest ./broker
docker build -t proxy:latest ./proxy 

# Launch EMQ1
docker run --rm -ti --name emq1 -p 18083:18083 \
    -e EMQ_NAME="emq1" \
    -e EMQ_MQTT__LISTENER__TCP=1883 \
    broker:latest

# Launch EMQ2 and join cluster (use emq1's IP)
docker run --rm -ti --name emq2 -p 18084:18083 \
    -e EMQ_NAME="emq2" \
    -e EMQ_MQTT__LISTENER__TCP=1883 \
    -e EMQ_JOIN_CLUSTER="emq1@172.17.0.2" \
    broker:latest

# Launch EMQ3 and join cluster (use emq1's IP)
docker run --rm -ti --name emq3 -p 18085:18083 \
    -e EMQ_NAME="emq3" \
    -e EMQ_MQTT__LISTENER__TCP=1883 \
    -e EMQ_JOIN_CLUSTER="emq1@172.17.0.2" \
    broker:latest

# Create haproxy.cfg
cp ./proxy/template.haproxy.cfg ./proxy/haproxy.cfg

# Open ./proxy/haproxy.cfg and add broker IPs

# Launch HAProxy
docker run --rm -ti  --name hap1 -p 80:80 -p 1883:1883 proxy:latest

# Test with mosquitto
mosquitto_sub -h 192.168.99.100 -p 1883 -t test
mosquitto_pub -h 192.168.99.100 -p 1883 -t test -m 'hello world'

# You can bring up dashboards for each broker at 192.168.99.100:18083-18085
# Username=admin Password=public
