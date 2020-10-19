#!/bin/bash
# Download trips data and upload to boject storage

. env.sh

export FILE_HOST="https://s3.amazonaws.com/tripdata/"
export FILE_LIST="
JC-201901-citibike-tripdata.csv.zip
JC-201902-citibike-tripdata.csv.zip
JC-201903-citibike-tripdata.csv.zip
JC-201904-citibike-tripdata.csv.zip
JC-201905-citibike-tripdata.csv.zip
JC-201906-citibike-tripdata.csv.zip
JC-201907-citibike-tripdata.csv.zip
JC-201908-citibike-tripdata.csv.zip
JC-201909-citibike-tripdata.csv.zip
JC-201910-citibike-tripdata.csv.zip
JC-201911-citibike-tripdata.csv.zip
JC-201912-citibike-tripdata.csv.zip"

echo "Downloading bike rental data from NYC Bike Share, LLC and Jersey City Bike Share data sharing service."
echo "You can view the Citi Bike licensing information here:  https://www.citibikenyc.com/data-sharing-policy"

echo "... creating bucket $BUCKET_NAME in your home region."
oci os bucket create --compartment-id $COMPARTMENT_OCID --name $BUCKET_NAME

echo "... retrieving station information from Citi Bikes feed"
curl https://gbfs.citibikenyc.com/gbfs/es/station_information.json | jq -c '.data.stations[]' > $TARGET_DIR/stations.json

echo "... copy the station JSON data to bucket: $BUCKET_NAME/stations/"
oci os object put --content-type application/json --force --bucket-name $BUCKET_NAME --name "stations/stations.json" --file $TARGET_DIR/stations.json


echo "... retrieving detail trip data"
echo "... copying to $TARGET_DIR"  
echo "... directory listing prior to download:"
ls $TARGET_DIR

# download files from S3 and unzip

cd $TARGET_DIR
mkdir -p $TARGET_DIR/csv_tmp
rm $TARGET_DIR/csv_tmp/*

for file in $FILE_LIST 
do
   s3obj="https://s3.amazonaws.com/tripdata/$file"
   echo "... downloading $s3obj to $TARGET_DIR"
   curl --remote-name --silent $s3obj 
   echo "... extracting $file to $TARGET_DIR/csv_tmp"
   unzip -o $TARGET_DIR/$file -d $TARGET_DIR/csv_tmp
done

# Do a bulk upload
echo "... copy CSV files to $BUCKET_NAME/biketrips/"
oci os object bulk-upload --content-type text/csv --bucket-name $BUCKET_NAME --src-dir "$TARGET_DIR/csv_tmp" --include "JC*.csv" --object-prefix "biketrips/" --overwrite
