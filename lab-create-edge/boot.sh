#!/bin/bash

# Run this on the edge node

# Set env vars that describe the cluster configuration
. env.sh

# Pick up env vars from setup-env.sh
BASEDIR=$(dirname $0)
cd $BASEDIR

echo "begin"
echo "....setting up environment"
echo "....updating ~opc/.ssh/config file"

echo "Enable simple ssh to $MN0_HOSTNAME"
echo "Host $MN0_HOSTNAME
   Hostname $MN0_IP
   ServerAliveInterval 50
   User opc
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   IdentityFile $PRIVATE_KEY" >> ~opc/.ssh/config
chmod 644 ~opc/.ssh/config

# Copy the private key for connecting to bastion to the master
scp -i $PRIVATE_KEY $PRIVATE_KEY ${MN0_IP}:/home/opc/.ssh/

echo "....generating /etc/yum.repos.d/bda.repo"
#Prepare for running YUM (change this)
echo "[bda]
name=BDA repository
baseurl=http://${MN0_IP}/bda
enabled=1
gpgcheck=0
enablegroups=1" | sudo tee /etc/yum.repos.d/bda.repo

echo "....installing base software (kerberos, java)"
# install software
sudo yum clean all
sudo yum install -y krb5-workstation krb5-libs jdk1.8

echo "....configuring base software (kerberos, java)"
# set JAVA_HOME
export JAVA_HOME=/usr/java/latest 
echo "export JAVA_HOME=/usr/java/latest" | sudo tee /etc/profile.d/mystartup.sh
sudo chmod 644 /etc/profile.d/mystartup.sh
. /etc/profile.d/mystartup.sh

echo "....configure firewall to enable hosts on subnet to connect"
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
scp $MN0_HOSTNAME:~opc/.ssh/id_rsa.pub /tmp/

cp ~opc/.ssh/authorized_keys ~opc/.ssh/authorized_keys.`date +%F-%H-%M-%S`
cat id_rsa.pub |tee -a ~/.ssh/authorized_keys
sudo cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.`date +%F-%H-%M-%S`
cat id_rsa.pub |sudo tee -a /root/.ssh/authorized_keys

# Enable Java processes to access Kerberized cluster by copying security files
echo "....enable java processes to access kerberized cluster"
mkdir /tmp/edgefiles
scp -i $PRIVATE_KEY $MN0_HOSTNAME:/usr/java/latest/jre/lib/security/*.jar 
sudo mv /tmp/edgefiles/*.jar /usr/java/latest/jre/lib/security/

# Configuration file for Kerberos
echo "....copying /etc/krb5.conf from master"
scp $MN0_HOSTNAME:/etc/krb5.conf /tmp/edgefiles/
sudo mv /tmp/edgefiles/krb5.conf /etc/

echo "....installing CM Agent"
# install Cloudera Manager Agents
sudo yum install -y cloudera-manager-agent

echo "....configuring CM Agent"
# Cloudera Manager Agent configuration file 
rm -f /tmp/edgefiles/*
scp $MN0_HOSTNAME:/etc/cloudera-scm-agent/* /tmp/edgefiles/
sudo mv /tmp/edgefiles/* /etc/cloudera-scm-agent/
sudo chown cloudera-scm:cloudera-scm /etc/cloudera-scm-agent/*

# insert line into config file for min tls protocol
if ! sudo grep -q '^minimum_tls_protocol=' /etc/cloudera-scm-agent/config.ini;
 then sudo sed -i '/^use_tls=.*/a minimum_tls_protocol=TLSv1.2' /etc/cloudera-scm-agent/config.ini
fi


# SSH key file required for agents to communicate to Cloudera Manager
echo "....updating keystore and truststore"
sudo mkdir -p /opt/cloudera/security/x509/
scp $MN0_HOSTNAME:/opt/cloudera/security/x509/agents.pem /tmp/edgefiles/
sudo mv /tmp/edgefiles/agents.pem /opt/cloudera/security/x509/
sudo chown root:root /opt/cloudera/security/x509/agents.pem


# Truststore
sudo mkdir -p /opt/cloudera/security/jks/
scp $MN0_HOSTNAME:/opt/cloudera/security/jks/$CLUSTER.truststore /tmp/edgefiles/
sudo mv /tmp/edgefiles/$CLUSTER.truststore /opt/cloudera/security/jks/
sudo chown root:root /opt/cloudera/security/jks/$CLUSTER.truststore

echo "....starting CM Agent"
# Start agent and enable autostart
sudo systemctl restart cloudera-scm-agent
sudo systemctl enable cloudera-scm-agent

echo "....TO DO add edge node to CM"


echo "end setup"