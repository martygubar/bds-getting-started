# Create a Hadoop Admin User

## Before You Begin

Create a Hadoop admin/superuser that will be used for the Big Data Service Cluster.  This user will have full access to all the data and metadata on the cluster.

This tutorial assumes that your cluster has been created as secure and highly available.  If you did not create a secure cluster, then there is no need to create the kerberos user.

In this tutorial, you will:
* Add a Kerberos user
* Create an admin Linux OS group
* Add a user to the Linux OS
* Add this new user to Hadoop admin groups

## Connect to the Cluster's First Master Node
The KDC is running on the cluster's first master node.  Log into that node as the OPC user:

    ssh `your-first-master-node``

## Create the Admin `bds` Kerberos Principal
The opc user has sudo privileges on the cluster - allowing it to switch to the root user and then run privileged commands.  Change to the root user, connect to the Kerberos KDC and add a new kerberos principal `bds`.  Specify a password for this user and keep the password in a safe place.

    # sudo bash
    # kadmin.local
    kamdin.local: addprinc bds
    kadmin.local: exit

## Create a `hadoopadmin` Linux OS Group
Create a Hadoop admin group that will contain the list of Hadoop admins for the cluster.  This group will be superusers and can update any HDFS directory.  While still logged in as the root user, use **dcli** to add the group to each node on the cluster:

    dcli -C "groupadd hadoopadmin"

## Add the `bds` Linux OS User
Create the `bds` admin user and it to the hive and hdfs superuser groups.  The **dcli** utility allows you to run commands across each node of the clsuter.  Use **dcli** to add the `bds` user to each node on the cluster:

```bash
dcli -C "useradd -G hdfs,hive,hadoop,hadoopadmin bds"
```
Because `bds` is part of the hive group, it is considered an admin for Sentry.

## Update HDFS Supergroup
Make `hadoopadmin` the supergroup for HDFS.
* Log into Cloudera Manager (1st Utility Node):  https://`your-utility-node1`:7183
* Enter the Cloudera `admin` User and the password specified a cluster creation.
* In the list of Hadoop services, click **HDFS >> Configuration**
* Search for property `super`.  Specify `hadoopadmin` as the **Superuser Group**.
* At the bottom of the page, enter a reason for the update and click **Save Changes**.

You will now need to update the cluster with the new settings by deploying the cluster client configuration and restarting the cluster:
* Click **Cloudera Manager** to return to the home screen
* Next to the cluster name, click the triangle and then select **Deploy Client Configuration**.  Confirm that the step should be run.  Click **Close** when complete.
* Restart the cluster by clicking the triangle next to the cluster and select **Restart**.  This action will take a few minutes.


## Optionally Add `bds` User to Hue
Log into Hue as an administrator and add the `bds` user as an administrator.
* Log into Hue (2nd Utility Node):  https://localhost:8888/
* Select **Manage Users**
* Click **Add User**
* **Step 1:** Add user `bds`.  Check **Create home directory**
* **Step 3:** Check **Superuser status**
* Click **Add user** on the bottom of the page.


**This completes the Lab!**
