# Copy HDFS Data to Object Store
  ![](images/100/Title-100.png)

## Introduction

In this lab you will back up data in Oracle Big Data Cloud Service to Oracle Object Store.

## Lab 100 Objectives

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


### **STEP 3:** Configure Hadoop cluster to access Oracle Object Store
Oracle Object Store supports the S3 protocol.  In **Cloudera Manager**, update the **HDFS Safety Valve for core-site.xml** in the HDFS Configuration with the Oracle Object Store configuration information to allow for access to the Oracle Object Store:

```xml
    <property>
      <name>fs.s3a.endpoint</name>
      <value>https://<tenancy_name>.compat.objectstorage.<home_region>.oraclecloud.com</value>
    </property>
    <property>
      <name>fs.s3a.secret.key</name>
      <value><SECRET_KEY></value>
    </property>
    <property>
      <name>fs.s3a.access.key</name>
      <value><ACCESS_KEY></value>
    </property>
    <property>
      <name>fs.s3a.path.style.access</name>
      <value>true</value>
    </property>
    <property>
      <name>fs.s3a.paging.maximum</name>
      <value>1000</value>
    </property>
```

Example
* Tenancy:  `oraclebigdatadb`
* Endpoint: https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com
* Bucket:  `BDCS-MIGRATION`
* Access Key: `myaccesskey`
* Secret Key: `mysecretkey`
```xml
    <property>
      <name>fs.s3a.endpoint</name>
      <value>https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com</value>
    </property>
    <property>
      <name>fs.s3a.secret.key</name>
      <value>mysecretkey</value>
    </property>
    <property>
      <name>fs.s3a.access.key</name>
      <value>myaccesskey</value>
    </property>
    <property>
      <name>fs.s3a.path.style.access</name>
      <value>true</value>
    </property>
    <property>
      <name>fs.s3a.paging.maximum</name>
      <value>1000</value>
    </property>
```

### **STEP 4:** Use distcp to Copy Data to Oracle Object Store
Now that connectivity is established, copy data to the Oracle Object Store

    hadoop distcp /data s3a://BDCS-MIGRATION/


**This completes the Lab!**

**You are ready to proceed to [Lab 200](LabGuide200.md)**
