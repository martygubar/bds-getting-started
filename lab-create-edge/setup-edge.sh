#!/bin/bash

# Run this on the edge node
source /home/opc/env.sh 
# Set env vars that describe the cluster configuration
. env.sh
ssh_opt="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Pick up env vars from env.sh
BASEDIR=$(dirname $0)
cd $BASEDIR

echo "$(date +"%T") begin"
echo "....$(date +"%T") setting up environment"
echo "....$(date +"%T") updating ~opc/.ssh/config file"

echo "....$(date +"%T") enable simple ssh to $MN0_HOSTNAME"
echo "Host $MN0_HOSTNAME
   Hostname $MN0_IP
   ServerAliveInterval 50
   User opc
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   IdentityFile $PRIVATE_KEY" >> ~opc/.ssh/config
chmod 644 ~opc/.ssh/config

echo "....$(date +"%T") update /etc/hosts as workaround for networking issue"
sudo cp /etc/hosts /etc/hosts.`date +%F-%H-%M-%S`

clusterhost=`ssh $ssh_opt -i $PRIVATE_KEY $CM_IP "hostname | tr -d '[:space:]'"`
clusterhost=$clusterhost". $clusterhost"
etchosts="$CM_IP $clusterhost"
grep -qxF "$etchosts" /etc/hosts || echo $etchosts | sudo tee -a /etc/hosts

# Add master node to /etc/hosts
clusterhost=`ssh $ssh_opt -i $PRIVATE_KEY $MN0_IP "hostname | tr -d '[:space:]'"`
clusterhost=$clusterhost". $clusterhost" 
etchosts="$MN0_IP $clusterhost"
grep -qxF "$etchosts" /etc/hosts || echo $etchosts | sudo tee -a /etc/hosts

# Copy the private key for connecting to bastion to the master
scp $ssh_opt -i $PRIVATE_KEY $PRIVATE_KEY ${MN0_IP}:/home/opc/.ssh/

echo "....$(date +"%T") generating /etc/yum.repos.d/bda.repo"
#Prepare for running YUM (change this)
echo "[bda]
name=BDA repository
baseurl=http://${MN0_IP}/bda
enabled=1
gpgcheck=0
enablegroups=1" | sudo tee /etc/yum.repos.d/bda.repo

echo "....$(date +"%T") installing base software (kerberos, java)"
# install software
sudo yum clean all
sudo yum install -y krb5-workstation krb5-libs jdk1.8

echo "....$(date +"%T") configuring base software (kerberos, java)"
# set JAVA_HOME
export JAVA_HOME=/usr/java/latest 
echo "export JAVA_HOME=/usr/java/latest" | sudo tee /etc/profile.d/mystartup.sh
sudo chmod 644 /etc/profile.d/mystartup.sh
. /etc/profile.d/mystartup.sh

echo "....$(date +"%T") configure firewall to enable hosts on subnet to connect"
# Update the firewall
sudo firewall-cmd --zone=trusted --add-source=$SUBNET_CIDR --permanent						
sudo firewall-cmd --reload

#
# REMOVING BELOW.  WILL APPLY DNS PATCH IF NEC. instead of updating /etc/hosts
#
# echo "....enable cluster nodes to access bastion (req for Spark)"
# Enable Cluster Nodes to Access edge.  Can remove when network fix is in.

# Update /etc/hosts on each node of the cluster.  Can remove when network fix is in.
#ssh $MN0_HOSTNAME -t "dcli -C sudo cp /etc/hosts /etc/hosts.`date +%F-%H-%M-%S`"

# .... generate script.  Copy it to master.  Run dcli to update /etc/hosts on each
#echo "echo \"$ETC_HOSTS\" | sudo tee -a /etc/hosts" |tee /tmp/update-etc-host.sh;chmod +x /tmp/update-etc-host.sh
#scp /tmp/update-etc-host.sh $MN0_HOSTNAME:/tmp/
#ssh $MN0_HOSTNAME -t "dcli -x /tmp/update-etc-host.sh"

## END /etc/hosts UPDATE


# Copy
echo "....$(date +"%T") update authorized keys"
scp $ssh_opt $MN0_HOSTNAME:~opc/.ssh/id_rsa.pub /tmp/

cp ~opc/.ssh/authorized_keys ~opc/.ssh/authorized_keys.`date +%F-%H-%M-%S`
cat /tmp/id_rsa.pub |tee -a ~/.ssh/authorized_keys
sudo cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.`date +%F-%H-%M-%S`
cat /tmp/id_rsa.pub |sudo tee -a /root/.ssh/authorized_keys

# Enable Java processes to access Kerberized cluster by copying security files
echo "....$(date +"%T") enable java processes to access kerberized cluster"
mkdir /tmp/edgefiles
scp $ssh_opt -i $PRIVATE_KEY $MN0_HOSTNAME:/usr/java/latest/jre/lib/security/*.jar  /tmp/edgefiles/
sudo mv /tmp/edgefiles/*.jar /usr/java/latest/jre/lib/security/

# Configuration file for Kerberos
echo "....$(date +"%T") copying /etc/krb5.conf from master"
scp $ssh_opt $MN0_HOSTNAME:/etc/krb5.conf /tmp/edgefiles/
sudo mv /tmp/edgefiles/krb5.conf /etc/

echo "....$(date +"%T") installing CM Agent"
# install Cloudera Manager Agents
sudo yum install -y cloudera-manager-agent
sudo systemctl stop cloudera-scm-agent

echo ".....$(date +"%T") configuring CM Agent"
# Cloudera Manager Agent configuration file 
rm -f /tmp/edgefiles/*
scp $ssh_opt $MN0_HOSTNAME:/etc/cloudera-scm-agent/* /tmp/edgefiles/
sudo mv /tmp/edgefiles/* /etc/cloudera-scm-agent/
sudo chown cloudera-scm:cloudera-scm /etc/cloudera-scm-agent/*

# insert line into config file for min tls protocol
if ! sudo grep -q '^minimum_tls_protocol=' /etc/cloudera-scm-agent/config.ini;
 then sudo sed -i '/^use_tls=.*/a minimum_tls_protocol=TLSv1.2' /etc/cloudera-scm-agent/config.ini
fi


# SSH key file required for agents to communicate to Cloudera Manager
echo "....$(date +"%T") updating keystore and truststore"
sudo mkdir -p /opt/cloudera/security/x509/
scp $ssh_opt $MN0_HOSTNAME:/opt/cloudera/security/x509/agents.pem /tmp/edgefiles/
sudo mv /tmp/edgefiles/agents.pem /opt/cloudera/security/x509/
sudo chown root:root /opt/cloudera/security/x509/agents.pem


# Truststore
sudo mkdir -p /opt/cloudera/security/jks/
scp $ssh_opt $MN0_HOSTNAME:/opt/cloudera/security/jks/$CLUSTER.truststore /tmp/edgefiles/
sudo mv /tmp/edgefiles/$CLUSTER.truststore /opt/cloudera/security/jks/
sudo chown root:root /opt/cloudera/security/jks/$CLUSTER.truststore

echo "....$(date +"%T") starting CM Agent"
# Start agent and enable autostart
sudo systemctl restart cloudera-scm-agent
sudo systemctl enable cloudera-scm-agent

echo "$(date +"%T") finished host setup."
./add-to-cm.sh
