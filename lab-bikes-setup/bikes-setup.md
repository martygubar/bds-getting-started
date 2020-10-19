# 

## Analyzing Bike Usage - Setup
This tutorial sets up your Big Data Service to use the CitiBikes data and weather data.  Scripts will load data into HDFS and/or object storage.

* Download the CitiBikes data to HDFS
    * Download and unzip

Download data:
* Object Store

* HDFS
```
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/env.sh
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/download-all-hdfs-data.sh
chmod +x *.sh
```

* object store
```
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/env.sh
wget https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/download-all-objstore.sh
chmod +x *.sh
```

In HDFS, create the root data directory and make it accessible:
sudo -u hdfs hadoop fs -mkdir /data
sudo -u hdfs hadoop fs -chmod 777 /data