# Create a Hadoop Admin User
  ![](images/100/Title-100.png)

## Introduction

Create a Hadoop admin user that will be used for the Big Data Servi Cluster

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

### **STEP 3:** Add the `bds` OS User
Create the `bds` admin user and it to the hive and hdfs superuser groups.  Use **dcli** to add the user to each node on the cluster:

    dcli -C "useradd -G hdfs,hive ,hadoop bds"

### **STEP 4:** Update HDFS Supergroup and Sentry Admins
Make BDS the supergroup
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
