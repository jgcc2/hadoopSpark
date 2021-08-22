FROM ubuntu:18.04

USER root

RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y openssh-server default-jdk wget scala python3-pip libkrb5-dev iputils-ping apt-utils python3.6 zip vim curl less
RUN pip3 install --upgrade pip
RUN pip3 install jupyter py4j numpy pandas plotly sparkmagic3 
RUN apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PYTHONIOENCODING=utf8
RUN $(which java) --version
RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

ADD tmp/hadoop-2.7.3.tar.gz .
RUN mv /hadoop-2.7.3 /usr/local/hadoop
RUN ls -l /usr/local/hadoop

ADD tmp/spark-2.4.1-bin-hadoop2.7.tgz .
RUN mv /spark-2.4.1-bin-hadoop2.7 /usr/local/spark
RUN ls -l /usr/local/spark
RUN cat /.dockerenv

ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
ENV PYSPARK_DRIVER_PYTHON="jupyter"
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook"
ENV PYSPARK_PYTHON=python3

ADD tmp/apache-livy-0.7.0-incubating-bin.zip .
RUN unzip apache-livy-0.7.0-incubating-bin.zip -d /opt/
RUN ls /opt/apache-livy-0.7.0-incubating-bin/
RUN rm apache-livy-0.7.0-incubating-bin.zip

RUN jupyter-kernelspec install /usr/local/lib/python3.6/dist-packages/sparkmagic/kernels/sparkkernel
RUN jupyter-kernelspec install /usr/local/lib/python3.6/dist-packages/sparkmagic/kernels/pysparkkernel

ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME:sbin

RUN mkdir -p $HADOOP_HOME/hdfs/namenode \
        && mkdir -p $HADOOP_HOME/hdfs/datanode

COPY config/ /tmp/
RUN mv /tmp/ssh_config $HOME/.ssh/config \
    && mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml \
    && mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
    && mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
    && cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml \
    && mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml \
    && cp /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves \
    && mv /tmp/slaves $SPARK_HOME/conf/slaves \
    && mv /tmp/spark/spark-env.sh $SPARK_HOME/conf/spark-env.sh \
    && mv /tmp/spark/log4j.properties $SPARK_HOME/conf/log4j.properties \
    && mv /tmp/spark/spark.defaults.conf $SPARK_HOME/conf/spark.defaults.conf

ADD scripts/spark-services.sh $HADOOP_HOME/spark-services.sh

RUN chmod 744 -R $HADOOP_HOME

RUN $HADOOP_HOME/bin/hdfs namenode -format

EXPOSE 50010 50020 50070 50075 50090 8020 9000
EXPOSE 10020 19888
EXPOSE 8030 8031 8032 8033 8040 8042 8088
EXPOSE 49707 2122 7001 7002 7003 7004 7005 7006 7007 8888 9000
EXPOSE 8889

ENTRYPOINT service ssh start;jupyter notebook --ip=0.0.0.0 --port=8889 --allow-root --NotebookApp.token='qwerty'; /opt/apache-livy-0.7.0-incubating-bin/bin/livy-server start; cd $SPARK_HOME; bash
