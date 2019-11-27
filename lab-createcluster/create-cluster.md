# Create a Big Data Service Cluster

## Before You Begin

### Objectives
The goal for this tutorial is to step thru process of creating a secure, highly available Cloudera Hadoop cluster.  This will be a small, development cluster that is not intended to process huge amounts of data.  It will be based on small VM shapes that are perfect for developing applications and testing functionality at a minimal cost.

To create your Hadoop cluster:
* Log into Oracle Cloud Infrastructure 
* Use the Big Data Service Console to create a cluster

### Requirements

To complete this lab, you need to have the following:

* Login credentials and a tenancy name for the Oracle Cloud Infrastructure Console
* Performed the prerequisite tasks found in tutorial [Preparing for Big Data Service](?preparing-for-big-data-service)


## Open the Big Data Service Console

* From your browser, [login to Oracle Cloud Infrastructure](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)
    * Enter your **Tenancy** and then click **Continue**.
    * Enter your OCI user name and password

* In the OCI Console naviation menu, select **Big Data**
* Select **Compartment** `your-compartment` to create the cluster in that compartment

## Create a Big Data Service Cluster
There are many options when creating a cluster.  You will need to understand the sizing requirements based on your use case and performance needs.  This example will create a development cluster.  It is designed to use all features - but is targeted at small workloads and flexibility. Listed below is the cluster profile:
* Highly available and secure
* Master and Utility nodes will be 8 cores and use Block Storage
* Worker nodes will be small - 2 cores and also use Block Storage

For better performance and scalability, change the above specs appropriately.  Consider DensIO shapes (with direct attached storage) and bare metal shapes.

### Create the Cluster
Click **Create Cluster**.  Specify the cluster properties:
* **Cluster Name:** `your-cluster-name`
* **Cluster Admin Password:** `your-password`  (this will be the administrator password for Cloudera Manager)
* Select **Secure & Highly Available:** 
* **Cluster Version:** Select `CDH 6.2`
* **Hadoop Nodes: Master/Utility Nodes**
    * **Choose Instance Type:** `Virtual Machine`
    * **Choose Master/Utility Node Shape:** `VM.Standard2.8`
    * **Block Storage Size per Master/Utility Node (in GB):** `250`
* **Hadoop Nodes: Worker Nodes**
    * **Choose Instance Type:** `Virtual Machine`
    * **Choose Worker Node Shape:** `VM.Standard2.2`
    * **Block Storage Size per Worker Node (in GB):** `750`
    * **Number of Worker Nodes:** `3`
* **Network Settings**
    * **Compartment:** `your-compartment`
    * **Choose VCN:** `your-vcn`
    * **Choose Subnet:** `your-subnet`
    * Select **Enable NAT Gateway**
    * **CIDR Block:** `your-cidr` (e.g. 10.0.0.0/16)
* **Additional Options**
    * Upload your public key.  The associated private will be used to make SSH connections to the cluster
* **Click Create**

### Monitor Cluster Creation
The cluster creation will take some time.  You can monitor its progress at any time:
* Select **Big Data** from the OCI navigation menu
* Select `your-cluster-name` from the list of clusters
* Click **Work Requests**


## Summary
You created a secure, highly available cluster that is now ready to be used for developming big data applications and processing data in Hadoop.

**This completes the tutorial!**