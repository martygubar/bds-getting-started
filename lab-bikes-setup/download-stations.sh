#!/bin/bash
. setup-workshop-env.sh

echo "... retrieving station information from Citi Bikes feed"
curl https://gbfs.citibikenyc.com/gbfs/es/station_information.json | jq -c '.data.stations[]' > $TARGET_DIR/stations.json

echo "Copy the data to hdfs: /data/stations/"
hadoop fs -mkdir -p /data/stations
hadoop fs -put $TARGET_DIR/stations.json /data/stations/
