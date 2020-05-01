# Run this script on the bastion node after running
# setup-run-on-master.sh

# Update vars below to match your environment
export CLUSTER="martyg"
export UN0_HOSTNAME="martygun0"  # first utility node
export UN0_IP="10.0.0.34"
export MN0_HOSTNAME="martygmn0"  # first master node
export MN0_IP="10.0.0.31"
export EDGE_IP="10.0.0.36"       # IP address for edge node
export EDGE_HOSTNAME="bdsqldb"
export EDGE_FQDN="bdsqldb.sub03252331260.field.oraclevcn.com"
export PRIVATE_KEY="~opc/.ssh/bdsKey"  # private key used to connect to cluster
export SUBNET_CIDR="10.0.0.0/16"
export ETC_HOSTS="$EDGE_IP $EDGE_FQDN $EDGE_HOSTNAME"
export SUPER_PRINCIPAL=bds
export SUPER_PASSWORD=Welcome1!