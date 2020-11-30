#!/bin/bash

# Call this script to download and install all object store data
. env.sh

compartment_name=`oci iam compartment get --compartment-id $COMPARTMENT_OCID | jq '.data.name'`
echo "Downloading to compartment: $compartment_name"
echo ""
echo "Getting scripts."
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/Y40ykoOwtaOb6prcVlHFLSjNTUf6qlhialPY-UH-GOL3ZckW9h9wDtT_jJ-BES7d/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/download-citibikes-objstore.sh
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/wuWqXX7ykot9bjn3UeetSz4wJOT4L7ygwT5oxIY_asBbI7-YogUVzdVotNKWcEVx/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/download-weather-objstore.sh
chmod +x *.sh

echo "Running scripts."
./download-citibikes-objstore.sh
./download-weather-objstore.sh


echo "Done."
compartment_name=`oci iam compartment get --compartment-id $COMPARTMENT_OCID | jq -r '.data.name'`
echo "Data can be found in:"
echo "   Compartment:  $compartment_name"
echo "        Bucket:  $BUCKET_NAME"
