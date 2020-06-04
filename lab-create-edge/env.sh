# Update vars below to match your environment
export CLUSTER="martyg"
export MN0_HOSTNAME="martygmn0"  # first master node
export MN0_IP="10.0.0.42"
export CM_IP="10.0.0.41"  # first utility node
export CM_ADMIN_USER=admin
export CM_ADMIN_PASSWORD=Welcome1!
export PRIVATE_KEY="/home/opc/.ssh/bdsKey"  # private key used to connect to cluster
export SUBNET_CIDR="10.0.0.0/24"    # customer subnet CIDR block.  Will be used to update firewall rules

# do not alter
export EDGE_IP="$(echo -e $(hostname -I) | tr -d '[:space:]')"    # IP address for edge node
export EDGE_HOSTNAME="$(echo -e $(hostname -a) | tr -d '[:space:]')"
export EDGE_FQDN="$(echo -e $(hostname -A) | tr -d '[:space:]')"
export ETC_HOSTS="$EDGE_IP $EDGE_FQDN $EDGE_HOSTNAME"
