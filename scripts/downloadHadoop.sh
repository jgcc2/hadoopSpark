#!/bin/bash
wget -c http://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz -P ../tmp
wget -c https://archive.apache.org/dist/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz ../tmp
wget -c https://downloads.apache.org/incubator/livy/0.7.0-incubating/apache-livy-0.7.0-incubating-bin.zip ../tmp
exit 0
