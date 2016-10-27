#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export LANG=en_US.UTF-8
export TERM=xterm

locale-gen en_US en_US.UTF-8
echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /home/server1001/.bashrc
sudo apt-get update

# Runit
sudo apt-get install -y --no-install-recommends runit
# export > /etc/envvars && /usr/sbin/runsvdir-start
# echo 'export > /etc/envvars' >> ~/.bashrc

# Utilities
sudo apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute

#Install Oracle Java 8
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java8-installer
sudo apt install oracle-java8-unlimited-jce-policy
sudo rm -r /var/cache/oracle-jdk8-installer
export JAVA_HOME=/usr/lib/jvm/java-8-oracle

#PredictionIO
wget -O - http://download.prediction.io/PredictionIO-0.9.5.tar.gz | tar zx
mv ./PredictionIO* ~/PredictionIO
mkdir ~/PredictionIO/vendors
export PIO_HOME=~/PredictionIO
echo 'PIO_HOME=~/PredictionIO' >> ~/.bashrc
export PATH=$PATH:$PIO_HOME/bin
echo 'PATH=$PATH:$PIO_HOME/bin' >> ~/.bashrc

#Spark
wget -O - http://d3kbcqa49mib13.cloudfront.net/spark-1.5.1-bin-hadoop2.6.tgz | tar zx
mv ./spark* ~/spark

#ElasticSearch
mkdir elasticsearch
wget -O - https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz | tar zx -C ~/elasticsearch --strip-components=1
mv ~/elasticsearch ~/PredictionIO/vendors/elasticsearch

#HBase
mkdir hbase
wget -O - http://archive.apache.org/dist/hbase/hbase-1.0.0/hbase-1.0.0-bin.tar.gz | tar zx -C ~/hbase --strip-components=1
mv ~/hbase ~/PredictionIO/vendors/hbase
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/PredictionIO/vendors/hbase/conf/hbase-env.sh 

#Python SDK
sudo apt-get install -y python-pip
sudo pip install pytz
sudo pip install predictionio

#For Spark MLlib
sudo apt-get install -y libgfortran3 libatlas3-base libopenblas-base

#Download SBT
sudo ~/PredictionIO/sbt/sbt package 

#Configuration
sed -i 's|SPARK_HOME=.*|SPARK_HOME=~/spark|' /PredictionIO/conf/pio-env.sh
sed -i "s|PIO_STORAGE_REPOSITORIES_METADATA_SOURCE=PGSQL|PIO_STORAGE_REPOSITORIES_METADATA_SOURCE=ELASTICSEARCH|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|PIO_STORAGE_REPOSITORIES_MODELDATA_SOURCE=PGSQL|PIO_STORAGE_REPOSITORIES_MODELDATA_SOURCE=LOCALFS|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|PIO_STORAGE_REPOSITORIES_EVENTDATA_SOURCE=PGSQL|PIO_STORAGE_REPOSITORIES_EVENTDATA_SOURCE=HBASE|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|PIO_STORAGE_SOURCES_PGSQL|# PIO_STORAGE_SOURCES_PGSQL|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|# PIO_STORAGE_SOURCES_LOCALFS|PIO_STORAGE_SOURCES_LOCALFS|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|# PIO_STORAGE_SOURCES_ELASTICSEARCH_TYPE|PIO_STORAGE_SOURCES_ELASTICSEARCH_TYPE|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|# PIO_STORAGE_SOURCES_ELASTICSEARCH_HOME=.*|PIO_STORAGE_SOURCES_ELASTICSEARCH_HOME=~/PredictionIO/vendors/elasticsearch|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|# PIO_STORAGE_SOURCES_HBASE|PIO_STORAGE_SOURCES_HBASE|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|PIO_STORAGE_SOURCES_HBASE_HOME=.*|PIO_STORAGE_SOURCES_HBASE_HOME=~/PredictionIO/vendors/hbase|" ~/PredictionIO/conf/pio-env.sh
sed -i "s|# HBASE_CONF_DIR=.*|HBASE_CONF_DIR=~/PredictionIO/vendors/hbase/conf|" ~/PredictionIO/conf/pio-env.sh

wget -O - https://raw.githubusercontent.com/mingfang/docker-predictionio/master/hbase-env.sh > hbase-env.sh
wget -O - https://raw.githubusercontent.com/mingfang/docker-predictionio/master/hbase-site.xml > hbase-site.xml

cp hbase-site.xml ~/PredictionIO/vendors/hbase/conf/
cp hbase-env.sh ~/PredictionIO/vendors/hbase/conf/

~/PredictionIO/bin/pio-start-all
pio status

#Get Recommendation Engine
mkdir -p ~/PEngine/Recommendation
pio template get PredictionIO/template-scala-parallel-universal-recommendation ~/PEngine/Recommendation


