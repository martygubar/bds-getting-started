#!/bin/bash

. env.sh
# List buckets
# oci os bucket list --compartment-id $COMPARTMENT_OCID --name cloudsqlworkshop
# Create Bucket
echo "Adding weather data"
echo "... creating bucket $BUCKET_NAME"
oci os bucket create --compartment-id $COMPARTMENT_OCID --name $BUCKET_NAME
echo "... retrieving weather data and uploading to bucket $BUCKET_NAME"
#curl -sS -k -L --post302 -X GET curl "https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/weather-newark-airport.csv" | oci os object put --content-type text/csv --force --bucket-name $BUCKET_NAME --name "weather/weather-newark-airport.csv" --file -
curl "https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/weather-newark-airport.csv" | oci os object put --content-type text/csv --force --bucket-name $BUCKET_NAME --name "weather/weather-newark-airport.csv" --file -