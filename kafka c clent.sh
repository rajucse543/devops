#!bin/bash
log INFO "unzip kafka client"
unzip $MEDIA/librdkafka-master.zip
cd librdkafka-master
log Info "Config Kafka Client"
./configure --prefix=/usr/local
make

sudo make install
