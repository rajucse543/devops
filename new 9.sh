#!/bin/bash

############################################
#  Kafka Installation                      #
#  Author : Nagaraju N                     #
############################################


# npbc-admin user creation
WORKDIR="/appl/home/attcloud/kafka_2.13-2.7.0/bin"
DIR1="/opt/npdc/cm"
DIR2="/var/npbc"
LOGGER=/bin/logger
logfile=logs/instllation.log

sudo adduser $NPBC_ADMIN_USER
log INFO "user created..."
#directory creation

sudo mkdir -p $NPDC_DIRCM && sudo mkdir  -p $NPBC_DIR

if [ -d  $NPDC_DIRCM ]; then

log INFO "Directories created"

fi

log INFO "Granting permission"


sudo chown -R $NPBC_ADMIN_USER $NPDC_DIR
sudo chown -R $NPBC_ADMIN_USER $NPBC_DIR

## Installing JDK Packages

#sudo apt update && sudo apt upgrade
#apt-get install java-11-openjdk -y
#apt-get install java-11-openjdk-devel -y


c= `java -version`
log INFO "java version is:" $c

if [ ! -f $BIN_DIR/$KAFKA_BIN_PATH ]; then
 log ERROR "Kafa installables not found"
exit 1
fi

tar -xvzf $BIN_DIR/$KAFKA_BIN_PATH $OPT/


log INFO "Starting Zookeepr service"
#Zookeeper service will run in the backgorund and wait for 1 minutes to come up
nohup ./$KAFKA_BIN/zookeeper-server-start.sh $KAFKA_CONFIG/zookeeper.properties > /dev/null 2>&1 &
sleep 1m

log INFO "Starting Kafka server...."
#Kafka service will run in the backgorund and wait for 1 minutes to come up
nohup ./$KAFKA_BIN/kafka-server-start.sh $KAFKA_CONFIG/config/server.properties >  /dev/null 2>&1 &

sleep 1m


for topic in"${TOPICS[@]}"; do

    log INFO "Creating Topic $topic"
	
  ./$KAFKA_BIN/kafka-topics.sh --create --bootstrap-server $HOST:$KAFKA_PORT --replication-factor 1 --partitions 1 --topic $topic

done

log INFO "Kafka installed and configured...."


############################################
#         Mysql Installation               #
############################################

mysql -V
mysqlstatus=$?
if [ $mysqlstatus -eq 0 ]; then
        log INFO "Mysql is alredy installed. Removing mysql ...."
        apt-get remove --purge 'mysql-.*' -y
        rm -r $MYSQL_DIR $MYSQL_LIBDIR
fi

log INFO "Installing mysql server"
sudo apt-get install mysql-server -y

sudo mysql -u $DB_ROOT <<'EOF'
# Make sure that NOBODY can access the server without a password
UPDATE mysql.user SET authentication_string=PASSWORD('$ROOT_PASS') WHERE User='$DB_ROOT';
# Kill the anonymous users
DELETE FROM mysql.user WHERE User='';
# disallow remote login for root
DELETE FROM mysql.user WHERE User='$DB_ROOT' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# Kill off the demo database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
# Make our changes take effect
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
        log INFO "Mysql Installed successfully"
fi

log INFO "Creating Database and User"

sudo mysql -u root <<'EOM'
create database if not exists $NPBC_DB; 
create user '$NPBC-USER' identified by '$NPBC_PASS';
grant all privileges on `$NPBC_DB`.* to '$NPBC-USER'@'%';
EOM

if [ $? -eq 0 ]; then
        log INFO "Npbc user created \n npbc Datbase created"
fi


# initialize logging

log_init $logfile
log_debug

......................................
function addhost(){
HOSTNAME=$1
HOST_LINE="$IP\t$HOSTNAME"
if [-n "$(grep $HOSTNAME/etc/hosts)"]
then
log INFO "$HOSTNAME alredy exists: $(grep $HOSTNAME $ETC_HOSTS)"
else
log INFO "Adding $HOSTNAME to your $ETC_HOSTS";
sudo --sh-c-e "echo '$HOSTS_LINE'>>/etc/hosts";

if [-n"$(grep $HOSTNAME/etc/hosts)"] then

   log INFO "$HOSTNAME was added successfully\n $(grep $HOSTNAME/etc/hosts)";
else
log ERROR "Failed to Add $HOSTNAME,Try again!";

   fi
 fi
 } 

