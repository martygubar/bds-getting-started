#!/bin/bash
# Call this script to download and install all hdfs data

echo "Getting scripts."
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/dB4smlMsV2ShMNm6mIhaTkoS0N_4J2crBE81Z2umLCGlBrMKStDuMJJ7amejIYYl/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/download-citibikes-hdfs.sh
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/jvILFUrmUML6mfc-iWk3Ie-t7i9a05gYxjmkAOfLlHW1-gyjO51JRXxEI_Q2MWvA/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/download-weather-hdfs.sh
chmod +x *.sh
echo "Running scripts."
./download-citibikes-hdfs.sh
./download-weather-hdfs.sh

echo "Done."