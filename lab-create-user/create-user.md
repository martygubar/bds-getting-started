# Create a Hadoop Admin User
  ![](images/100/Title-100.png)

## Introduction

Create a Hadoop admin user that will be used for the Big Data Service Cluster

## Lab:  Create a User

* Add a Kerberos user
* Add a user to the Linux OS
* Add this user to Hadoop admin groups

## Steps

### **STEP 1:** Connect to the master node that contains the primary Kerberos KDC
The KDC is running on the first master node.

    ssh pmteammn0

### **STEP 2:** Create the admin `bds` kerberos principal
The opc user has sudo privileges on the cluster - allowing it to switch to the root user and tgeb run privileged commands.  Change to the root user, connect to the Kerberos KDC and add a new kerberos principal `bds`.  Specify a password for this user and keep the password in a safe place.

    # sudo bash
    # kadmin.local
    kamdin.local: addprinc bds
    kadmin.local: exit

### **STEP X: Create a `hadoopadmin` Group
Create a hadoopgroup that will server Hadoop admins for the system.  This group will be superusers and can update any HDFS directory.  While still logged in as the root user, use **dcli** to add the group to each node on the cluster:

    dcli -C "groupadd hadoopadmin"

### **STEP 3:** Add the `bds` OS User
Create the `bds` admin user and it to the hive and hdfs superuser groups.  Use **dcli** to add the user to each node on the cluster:

    dcli -C "useradd -G hdfs,hive,hadoop,hadoopadmin bds"

Because `bds` is part of the hive group, it is considered an admin for Sentry.

### **STEP 4:** Update HDFS Supergroup
Make `hadoopadmin` the supergroup for HDFS.
* Log into Cloudera Manager (1st Utility Node):  https://`your-utility-node1`:7183
* Enter the Cloudera `admin` User and the password specified a cluster creation.
* In the list of Hadoop services, click **HDFS >> Configuration**
* Search for property `super`.  Specify `hadoopadmin` in the **Superuser Group**.
* At the bottom of the page, enter a reason for the update and click **Save Changes**.

You will now need to update the cluster with the new settings by deploying the cluster client configuration and restarting the cluster:
* Click **Cloudera Manager** to return to the home screen
* Next to the cluster name, click the triangle and then select **Deploy Client Configuration**.  Confirm that the step should be run.  Click **Close** when complete.
* Restart the cluster by clicking the triangle next to the cluster and select **Restart**.  This action will take a few minutes.


### **STEP 4:** Optionally Add `bds` User to Hue
Log into Hue as an administrator and add the bds user as an administrator.

* Log into Hue (2nd Utility Node):  https://localhost:8888/
* Select **Manage Users**
* Click **Add User**
* **Step 1:** Add user `bds`.  Check **Create home directory**
* **Step 3:** Check **Superuser status**
* Click **Add user** on the bottom of the page.


**This completes the Lab!**

**You are ready to proceed to [Lab 200](LabGuide200.md)**
