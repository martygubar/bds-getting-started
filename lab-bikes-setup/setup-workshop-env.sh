#!/bin/bash
# Setup environment for data used for workshop

export COMPARTMENT_OCID="ocid1.compartment.oc1..aaaaaaaa27osxvjegj2ai6qivvomc7xy5kryfq26zbuv4nlcr42rhdeonsaq"
export BUCKET_NAME="cloudsqlworkshop"
export TARGET_DIR="/tmp"
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