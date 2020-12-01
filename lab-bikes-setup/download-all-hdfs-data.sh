#!/bin/bash
# Call this script to download and install all hdfs data
SCRIPT_FULL_PATH=$(dirname "$0")
. $SCRIPT_FULL_PATH/env.sh

echo "Getting scripts."
wget $SOURCE_PREFIX/download-citibikes-hdfs.sh
wget $SOURCE_PREFIX/download-weather-hdfs.sh
chmod +x *.sh
echo "Running scripts."
./download-citibikes-hdfs.sh
./download-weather-hdfs.sh

echo "Done."