#!/bin/bash

# Call this script to download and install all object store data
. env.sh

compartment_name=`oci iam compartment get --compartment-id $COMPARTMENT_OCID | jq '.data.name'
echo "Downloading to compartment: $compartment_name"
echo ""
echo "Getting scripts."
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/download-citibikes-objstore.sh
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/download-weather-objstore.sh
chmod +x *.sh

echo "Running scripts."
./download-citibikes-objstore.sh
./download-weather-objstore.sh


echo "Done."