#!/bin/bash
# Call this script to download and install all hdfs data

echo "Getting scripts."
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/download-citibikes-hdfs.sh
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/download-weather-hdfs.sh
chmod +x *.sh
echo "Running scripts."
./download-citibikes-hdfs.sh
./download-weather-hdfs.sh

echo "Done."