#!/bin/bash
docker build -t spark2/spark-hadoop-cluster .
./startHadoopCluster.sh
