#!/bin/bash

# Call this script to download and install all object store data
SCRIPT_FULL_PATH=$(dirname "$0")
. $SCRIPT_FULL_PATH/env.sh

compartment_name=`oci iam compartment get --compartment-id $COMPARTMENT_OCID | jq '.data.name'`
echo "Downloading to compartment: $compartment_name"
echo ""
echo "Getting scripts."
wget $SOURCE_PREFIX/download-citibikes-objstore.sh
wget $SOURCE_PREFIX/download-weather-objstore.sh
chmod +x *.sh

echo "Running scripts."
./download-citibikes-objstore.sh
./download-weather-objstore.sh


echo "Done."
compartment_name=`oci iam compartment get --compartment-id $COMPARTMENT_OCID | jq -r '.data.name'`
echo "Data can be found in:"
echo "   Compartment:  $compartment_name"
echo "        Bucket:  $BUCKET_NAME"
