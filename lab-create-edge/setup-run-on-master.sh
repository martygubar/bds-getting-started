#!/bin/bash

# Run this script on the first master node prior to running running
# setup-run-on-bastion.sh

# Pick up env vars from setup-env.sh
BASEDIR=$(dirname $0)
cd $BASEDIR

# Set env vars
echo "begin"
echo "....setting up environment"
. setup-env.sh

# Run on master
# sudo bash
# kadmin.local
#sudo kadmin.local -q "addprinc -pw Welcome1! $thisuser/$CLUSTER@BDACLOUDSERVICE.ORACLE.COM"
echo "....adding kerberos principal"
sudo kadmin.local -q "addprinc -pw $SUPER_PASSWORD $SUPER_PRINCIPAL"

echo "....adding superuser to each node"
dcli -C "sudo groupadd hadoopadmin"
dcli -C "sudo useradd -G hdfs,hive,hadoop,hadoopadmin $SUPER_PRINCIPAL"

# /etc/hosts updates
# Generate the script
echo "....get host mapping from each node"
echo 'echo `hostname -I | cut -d " " -f 2` `hostname -f` `hostname -a`' > /tmp/gethostmap
chmod +x /tmp/gethostmap

# run the script on each node to gather the customer IPs
dcli -x /tmp/gethostmap | cut -d ':' -f 2 | awk '{$1=$1};1' > /tmp/customerhosts

# review the generated file and ensure the ips match the customer IPs
echo "....update /etc/hosts on each cluster node"
dcli "sudo cp /etc/hosts /etc/hosts.`date +%F-%H-%M-%S`"
dcli "echo $ETC_HOSTS | sudo tee -a /etc/hosts"

echo "end"
