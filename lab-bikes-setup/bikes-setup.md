# 

## Analyzing Bike Usage - Setup
This tutorial sets up your Big Data Service to use the CitiBikes data and weather data.  Scripts will load data into HDFS and/or object storage.

* Download the CitiBikes data to HDFS
    * Download and unzip

Download data:
* Object Store

* HDFS
```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/x3p8hu-92jf0ypH_ZiVhUyS3L-zeQOiNzOn_o_wzVZajUG-8e_KVrtN1Pd6bxZhK/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/env.sh
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/BxuET89f_2j5vJYY1MRc6iR2hovqATQrhOzwqBbu_0azwx3eLiRLDkLEQ42_nLaJ/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/download-all-hdfs-data.sh
chmod +x *.sh
```

* object store
```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/x3p8hu-92jf0ypH_ZiVhUyS3L-zeQOiNzOn_o_wzVZajUG-8e_KVrtN1Pd6bxZhK/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/env.sh
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/Zwahcgh0XiqINjj4nak1bF91glbki8SieslQ9K3hqMQu8dTXX09IiRqYyce6AUte/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/download-all-objstore.sh
chmod +x *.sh
```

In HDFS, create the root data directory and make it accessible:
sudo -u hdfs hadoop fs -mkdir /data
sudo -u hdfs hadoop fs -chmod 777 /data