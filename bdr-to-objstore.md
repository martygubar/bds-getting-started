# Use BDR to Backup Your Cluster to Object Store
  ![](images/100/Title-100.png)

## Introduction

In this lab you will back up data and Metadata to Oracle Object Store

## Lab:  Backup to Oracle Object Store

- Use Zeppelin to report on data captured in Oracle Database 18c
- Learn how to seamlessly access data in Oracle Object Store from Oracle Database using Big Data SQL-enabled external tables.

## Steps

### **STEP 1:** Create a bucket in Oracle Object Store

* From your browser, Oracle Cloud Infrastructure:
  [http://localhost:8090/#/](http://localhost:8090/#/)

* Select Object Storage

* Create a bucket called `BDCS-MIGRATION`.  Use an UPPERCASE name; this is required for the Hadoop S3 connector to work.

### **STEP 2:** Create a Customer Secret Key

* Select **Identity >> Users >> User Details >> Customer Secret Keys**
* Click **Generate Secret Key**
* Name the secret key `migration-key`
* Save the secret key to a safe place.  It will not be shown again..
    * Access Key: `myaccesskey`
    * Secret Key: `mysecretkey`


### **STEP 3:** Create an External Account in Cloudera Manager
Use the Access Key and Secret Key to create an external account in Cloudera Manager
* Go to **Administration >> External Accounts**
* Click **Add Access Key Credentials** and specify your Access and Secret Key
  * **Name:**  `oracle-credential`
  * **AWS Access Key ID:** `myaccesskey`
  * **AWS Secret Key:** `mysecretkey`
* Do not check **Enable S3Guard** 

### **STEP 4:** Create a Hive Replication Schedule
Prior to running the replication, ensure that snapshots are enabled for the /user/hive/warehouse directory.  This will ensure that any changes made to files during the replication process will not cause replication failures.

For more details, see [Using Snapshots with Replication](https://docs.cloudera.com/documentation/enterprise/5-15-x/topics/cm_bdr_snap_repl.html) in the Cloudera Administration documentation..

* Enable Snapshots for the **/user/hive/warehouse** directory.  In Cloudera Manager:
  * Select the **HDFS** service
  * Click the **File Browser**
  * Navigate to **/user/hive/warehouse** directory
  * Click **Enable Snapshots**

* Create a Hive Replication Schedule.  In Cloudera Manager, select **Backup >> Replication Schedules** and the select **Create Schedule**.  Fill out the details for the Hive replication schedule.  For example:

  * **Name:**  `hive-rep1`
  * **Source:** `hive`
  * **Destination:** `oracle-credential`
  * **Cloud Root Path:**  `s3a://BDCS-BACKUP/`
  * **Replication Option:**  `Metadata and Data`
  * **Schedule:** `Immediate`
  * **Run As Username:** `Default`
  
  Click **Save Schedule** and run the backup.  You can monitor the replication in Replication Schedules.

### **STEP 5:** Create an HDFS Replication Schedule
Similar to Hive replication, ensure that the directories that will be replicated are Snapshot enabled.  In this example, `/data/` directory will be backed up to object store.
* Enable Snapshots for the **/data** directory.  In Cloudera Manager:
  * Select the **HDFS** service
  * Click the **File Browser**
  * Navigate to **/data** directory
  * Click **Enable Snapshots**

* Create an HDFS Replication Schedule.  In Cloudera Manager, select **Backup >> Replication Schedules** and the select **Create Schedule**.  Fill out the details for the HDFS replication schedule.  For example:

  * **Name:**  `hdfs-rep1`
  * **Source:** `hdfs`
  * **Destination:** `oracle-credential`
  * **Destination Path:**  `s3a://BDCS-BACKUP/`
  * **Replication Option:**  `Metadata and Data`
  * **Schedule:** `Immediate`
  * **Run As Username:** `Default`
  
  Click **Save Schedule** and run the backup.
  

## Summary
You just created an Oracle Big Data SQL table over data stored in Oracle Object Store and queried it as you would any other Oracle table.  This allows you to easily blend data across data sources to gain new insights.

**This completes the Lab!**

**You are ready to proceed to [Lab 200](LabGuide200.md)**
