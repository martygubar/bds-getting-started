# Use BDR to Restore Your Hadoop Cluster from Oracle Object Storage
  ![](images/100/Title-100.png)

## Introduction

In this lab you will restore the data and Metadata from Oracle Object Store to your Hadoop Cluster

## Lab:  Restore Hadoop Data and Metadata from Oracle Object Storage

* Restore the cluster that was backed up in [BDR to Backup Your Cluster to Object Storage]()
    * Configure your Big Data Service Cluster to access Oracle Object Storage
    * Restore Hive data and metadata 
    * Restore HDFS data 

## Steps

### **STEP 1:** Create an External Account in Cloudera Manager
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

Finally, update the s3a endpoint to point to Oracle Object Storage

https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com

### **STEP 2:** Create a Hive Replication Schedule
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
  * **Run As Username:** `bds`  (See [Create a Hadoop Admin User](create-user.md))
  
  Click **Save Schedule** and run the restore.  You can monitor the replication in Replication Schedules.

### **STEP 5:** Create an HDFS Replication Schedule
Similar to Hive replication, ensure that the directories that will be replicated are Snapshot enabled.  In this example, `/data/` directory will be backed up to object store.
* Enable Snapshots for the **/data** directory.  In Cloudera Manager:
  * Select the **HDFS** service
  * Click the **File Browser**
  * Navigate to **/data** directory
  * Click **Enable Snapshots**

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
You just created an Oracle Big Data SQL table over data stored in Oracle Object Store and queried it as you would any other Oracle table.  This allows you to easily blend data across data sources to gain new insights.

**This completes the Lab!**

**You are ready to proceed to [Lab 200](LabGuide200.md)**
