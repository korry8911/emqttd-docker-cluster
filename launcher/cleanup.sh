#!/bin/bash
docker kill emq1
docker rm emq1

docker kill emq2
docker rm emq2

docker kill emq3
docker rm emq3

docker kill hap1
docker rm hap1

docker ps