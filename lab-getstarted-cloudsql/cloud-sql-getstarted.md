# Getting Started with Cloud SQL
## Before You Begin

Cloud SQL allows you to run Oracle SQL against data on your Big Data Service cluster.  It is comprised of a Query Server plus Cloud SQL "cells" that are deployed to each Worker node on the cluster.  The Query Server is base on Oracle Database 18c; you will connect to Query Server and run queries against it.  Cloud SQL cells perform data local processing; they scan, filter and aggregate data on Worker nodes and return the result to the Query Server for final processing.  Cloud SQL is an optional feature on a Big Data Service cluster and is configured after the cluster creation.

### Objectives
In this lab you will set up Cloud SQL, set up users and then query data that's in Hive.  You will perform the following tasks:
1. Add Cloud SQL to your Big Data Service
1. Synchronize Kerberos users (assuming a secure cluster)
1. Synchronize Hive Metadata
1. Run a query against Hive data

### Requirements
* Login credentials and a tenancy name for the Oracle Cloud Infrastructure Console
* Big Data Service Cluster is deployed and you have the Admin credentials for that cluster [Create a Big Data Service Cluster](?create-cluster)

## Add Cloud SQL to Your Big Data Service Cluster
* From your browser, [login to Oracle Cloud Infrastructure](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)
    * Enter your **Tenancy** and then click **Continue**.
    * Enter your OCI user name and password

* In the OCI Console naviation menu, select **Big Data**
* Select **Compartment** `your-compartment` to vew the clusters in that compartment
* Find the cluster where you will add Cloud SQL.  Click the three dots and select **Add Cloud SQL**.  Sizing will depend on expected usage (number of users and amount of data that you expect to access).  This example will be for a development environment (view the [OCI Instance Shapes for more details](https://docs.cloud.oracle.com/iaas/Content/Compute/References/computeshapes.htm)):

    * **Query Server Node Shape Configuration:** `VM.Standard2.8`
    * **Query Server Node Block Storage:** `1000GB`
    * **Cluster Admin Password:** mypassword (the admin password used when setting up your cluster)
    * Click **Add**

Big Data Service will deploy a new node to the cluster.  This step will take several minutes.  This new node will run the Query Server only and will not run other Hadoop Services.

## Synchronize Kerberos Users

Once Cloud SQL is deployed, go Cloud SQL Service in Cloudera Manager and Synchronize Kerberos users
* Log into Cloudera Manager:  https://your-utility-node-1:7183
* Click **Cloud SQL** in the list of services
* Click **Actions >> Sync Kerberos principals**

The synchronization job will be started.  You can monitor it from Cloudera Manager.

## Synchronize Hive Metadata

You can synchronize Hive Metadata using Cloudera Manager or thru a PL/SQL API.  Optionally, update properties for the sync in Cloudera  Manager:
* Click **Cloud SQL** in the list of services
* Click **Configuration**.  Specify attributes for the Hive sync
    * **Synchronized Hive Databases:**  Accept the default "*".  You can change this to a comma separated list of databases if not all databases need to be synchronized
    * **Enable full synchronization:** By default, Query Server will on updated changed objects in Hive.  You can execute a full sync by checking this item.  Accept the default

Next, execute the sync:
* Click **Instances** in the Cloud SQL Cloudera Manager page
* Click **Big Data SQL Query Server** instance
* Select **Actions >> Synchronize Hive Databases**.  Click **Synchronize Hive Databases**

The synchronization job will be started.  You can monitor it from Cloudera Manager.  Once the job is complete, you can exit Cloudera Manager.

## Review Query Server Schemas

Review the users that are available. Connect to Query Server as the `bds` user - the super user that was added in section [Create User](?create-user.md).  Because this is a secure environment, you will need a kerberos ticket prior to logging into SQL Plus.  Notice, SQL Plus will not prompt for a password because you authenticated thru Kerberos:
```bash
[~]$ kinit bds
Password for bds@BDACLOUDSERVICE.ORACLE.COM:  mypassword
sqlplus /@bdsqlusr
```

Review the schemas/users that are in Query Server.
```SQL
select username from all_users where upper(username) like 'B%' or username = 'D_DEFAULT';

USERNAME
-----------------------------------------------------------
BDSQL
D_DEFAULT
BIKES
bds@BDACLOUDSERVICE.ORACLE.COM
```

Let's review three of these users:
* **D_DEFAULT:**  contains Hive objects from the default Hive database
* **BIKES:** contains Hive objects from the BIKES Hive database
* **bds@BDACLOUDSERVICE.ORACLE.COM:** the superuser created previously (and the user currently logged in)

These schemas/users where created as part of the sync processes in the previous sections.

## Run a Query Against Hive Data
What are the most popular CitiBike starting stations?  Run a query against data stored in Hive.

```SQL
set linesize 500
column START_STATION_NAME format a30
SELECT 
       start_station_name, 
       APPROX_RANK (ORDER BY APPROX_COUNT(*) DESC ) AS ranking,
       APPROX_COUNT(*) as num_trips
FROM bikes.trips
GROUP BY start_station_name
HAVING 
  APPROX_RANK ( 
  ORDER BY APPROX_COUNT(*) 
  DESC ) <= 5
ORDER BY 2;
```
## Summary
You just added Cloud SQL to Big Data Service and configured it so that you can now run queries against data in Hadoop.

**This completes the Lab!**

