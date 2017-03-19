#!/bin/bash

docker build -t broker:latest ./broker

# launch broker 1
docker run -tid --name emq1 -p 18083:18083 \
    -e EMQ_NAME="emq1" \
    -e EMQ_MQTT__LISTENER__TCP=1883 \
    broker:latest

sleep 3

emq1_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' emq1)

docker run -tid --name emq2 -p 18084:18083 \
    -e EMQ_NAME="emq2" \
    -e EMQ_MQTT__LISTENER__TCP=1883 \
    -e EMQ_JOIN_CLUSTER="emq1@$emq1_ip" \
    broker:latest

sleep 3

docker run -tid --name emq3 -p 18085:18083 \
    -e EMQ_NAME="emq3" \
    -e EMQ_MQTT__LISTENER__TCP=1883 \
    -e EMQ_JOIN_CLUSTER="emq1@$emq1_ip" \
    broker:latest

sleep 3

emq2_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" emq2)
emq3_ip=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" emq3)

cp ./proxy/template.haproxy.cfg ./proxy/haproxy.cfg

sed -i ".bak" "s~HOST_IP_NODE_1~$emq1_ip~g" ./proxy/haproxy.cfg
sed -i ".bak" "s~HOST_IP_NODE_2~$emq2_ip~g" ./proxy/haproxy.cfg
sed -i ".bak" "s~HOST_IP_NODE_3~$emq3_ip~g" ./proxy/haproxy.cfg

rm ./proxy/haproxy.cfg.bak

docker build -t proxy:latest ./proxy
docker run -tid  --name hap1 -p 80:80 -p 1883:1883 proxy:latest
docker ps