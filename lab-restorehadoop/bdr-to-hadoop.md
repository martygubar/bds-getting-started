# Restore Your Hadoop Cluster from Oracle Object Storage
  ![](images/100/Title-100.png)

## Before You Begin

The goal for this tutorial is to restore a backup of your Hadoop cluster to Big Data service.

To restore your Hadoop cluster, you will:
* As an administrator, log into Cloudera Manager on your Big Data Service
* Configure your Big Data Service Cluster to access Oracle Object Storage
* Restore Hive data and metadata 
* Restore HDFS data 

### Requirements

To complete this lab, you need to have the following:

* A Hadoop cluster backup.  See tutorial [Backup Your Cluster to Object Storage](?bdr-to-objstore.md)
* Oracle Big Data Service Hadoop cluster deployed 
* Access to the Secret Key that has privileges to read the Oracle Object Storage bucket containing the Hadoop cluster backup
* Admin credentials for Cloudera Manager on your Big Data Service Cluster


## Log into Cloudera Manager on Your Big Data Service Cluster
* Log into https://`your-utility-node-1`:7183
* Enter user name `admin` and the password specified during cluster creation

## Create an External Account in Cloudera Manager
Use the Access Key and Secret Key to create an external account in Cloudera Manager
* Go to **Administration >> External Accounts**
* Click **Add Access Key Credentials** and specify your Access and Secret Key
  * **Name:**  `oracle-credential`
  * **AWS Access Key ID:** `myaccesskey`
  * **AWS Secret Key:** `mysecretkey`
* Do not check **Enable S3Guard**

After saving the credential, allow **Cluster Access to S3**:
* Click **Enable for** *cluster*
* Select **More Secure** credential policy
* Restart the dependent services

## Update the s3a Endpoint
Update the s3a endpoint to point to Oracle Object Storage.  
* Go to the Cloudera Manager home.  
* Select **S3 Connector >> Configuration**
* Update the **Default S3 Endpoint* property with the following
    https://`yourtenancy`.compat.objectstorage.`yourregion`.oraclecloud.com`

    For example:
    `https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com`


## Create a Hive Replication Schedule
Create a Hive Replication Schedule to restore from Oracle Object Storage.  In Cloudera Manager:

* Select **Backup >> Replication Schedules** and the select **Create Schedule**.  Fill out the details for the Hive replication schedule.  For example:

  * **Name:**  `hive-rep1`
  * **Source:** `oracle-credential`
  * **Destination:** `hive`
  * **Cloud Root Path:**  `s3a://BDCS-BACKUP/`
  * **HDFS Destination Path:** `/`
  * **Databases:** `Replicate All`
  * **Replication Option:**  `Metadata and Data`
  * **Schedule:** `Immediate`
  * **Run As Username:** `bds`  (See [Create a Hadoop Admin User](lab-createuser/create-user.md))
  
  Click **Save Schedule** and run the restore.  You can monitor the replication in Replication Schedules.

## Create an HDFS Replication Schedule
Restore HDFS data that had been backed up to Oracle Object Storage.  In this example, `/data/` directory had been backed up.  Restore the HDFS data to the HDFS file system root directory in order to mirror the source.

* Create an HDFS Replication Schedule.  In Cloudera Manager, select **Backup >> Replication Schedules** and the select **Create Schedule**.  Fill out the details for the HDFS replication schedule.  For example:

  * **Name:**  `hdfs-rep1`
  * **Source:** `oracle-credential`
  * **Source Path:** `oracle-credential`
  * **Destination:** `HDFS`
  * **Destination Path:**  `/`
  * **Schedule:** `Immediate`
  * **Run As Username:** `bds`
  
  Click **Save Schedule** and run the restore.
  

## Summary
Your Big Data Service cluster has been updated with the data and metadata from your source cluster.  You can now use the cluster to analyze and process data.
**This completes the tutorial!**
