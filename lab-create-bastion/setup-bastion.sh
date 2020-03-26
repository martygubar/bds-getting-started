export UN0_HOSTNAME=fieldun0
export UN0_IP=10.0.0.7
export MN0_HOSTNAME=fieldmn0
export MN0_IP=10.0.0.4
export PRIVATE_KEY=~opc/.ssh/bdsKey

echo "Host $UN0_HOSTNAME
   Hostname $UN0_IP
   ServerAliveInterval 50
   User opc
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   IdentityFile $PRIVATE_KEY

   Host $MN0_HOSTNAME
   Hostname $MN0_IP
   ServerAliveInterval 50
   User opc
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   IdentityFile $PRIVATE_KEY" >> ~opc/.ssh/config
chmod 644 ~opc/.ssh/config


# Run on masternode0
# sudo bash
# kadmin.local
kadmin.local: addprinc bds
kadmin.local: exit
dcli -C "groupadd hadoopadmin"
dcli -C "useradd -G hdfs,hive,hadoop,hadoopadmin bds"
