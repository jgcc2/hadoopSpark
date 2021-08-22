#!/bin/bash

# VARIABLES
IMG_NAME="spark2/spark-hadoop-cluster"
HOST_PREFIX="clstr"
NETWORK_NAME=$HOST_PREFIX

N=${1:-2}
NET_QUERY=$(docker network ls | grep -i $NETWORK_NAME)
if [ -z "$NET_QUERY" ]; then
	docker network create --driver=bridge $NETWORK_NAME
fi

# START HADOOP SLAVES 
i=1
while [ $i -le $N ]
do
	HADOOP_SLAVE="$HOST_PREFIX"-slave-$i
	docker run --name $HADOOP_SLAVE --log-driver gelf --log-opt gelf-address=udp://172.24.0.4:12201 -h $HADOOP_SLAVE --net=$NETWORK_NAME -itd "$IMG_NAME"
	i=$(( $i + 1 ))
done

# START HADOOP MASTER

HADOOP_MASTER="$HOST_PREFIX"-master
docker run --name $HADOOP_MASTER --log-driver gelf --log-opt gelf-address=udp://172.24.0.4:12201 -h $HADOOP_MASTER --net=$NETWORK_NAME \
		-p  8088:8088  -p 50070:50070 -p 50090:50090 \
		-p  8080:8080 -p 8889:8889 \
		-p 3000:3000 \
		-itd "$IMG_NAME"


# START MULTI-NODES CLUSTER
docker exec -it $HADOOP_MASTER "/usr/local/hadoop/spark-services.sh"






