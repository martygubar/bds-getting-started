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
* Performed the prerequisite tasks found in tutorial [Preparing for Big Data Service](?lab=preparing-for-big-data-service)


## Open the Big Data Service Console

* From your browser, [login to Oracle Cloud Infrastructure](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)
    * Enter your **Tenancy** and then click **Continue**.
    * Enter your OCI user name and password

* In the OCI Console naviation menu, select **Big Data**
* Select **Compartment** `mycompartment` to create the cluster in that compartment

## Create a Big Data Service Cluster
There are many options when creating a cluster.  You will need to understand the sizing requirements based on your use case and performance needs.  This example will create a development cluster.  It is designed to use all features - but is targeted at small workloads and flexibility. Listed below is the cluster profile:
* Highly available and secure
* Master and Utility nodes will be 8 cores and use Block Storage
* Worker nodes will be small - 4 cores and also use Block Storage

For better performance and scalability, change the above specs appropriately.  Consider DensIO shapes (with direct attached storage) and Bare Metal shapes.

### Create the Cluster
Click **Create Cluster**.  Specify the cluster properties:
* **Cluster Name:** `mycluster`
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
    * **Compartment:** `mycompartment`
    * **Choose VCN:** `mynetwork`
    * **Choose Subnet:** `Public Subnet-mynetwork`
    * Select **Deploy Oracle-managed Service gateway and NAT gateway (Quick Start)**
* **Additional Options**
    * Upload your public key.  The associated private will be used to make SSH connections to the cluster
* **Click Create**

### Monitor Cluster Creation
The cluster creation will take some time.  You can monitor its progress at any time:
* Select **Big Data** from the OCI navigation menu
* Select `mycluster` from the list of clusters
* Click **Work Requests**

## Review Your Cluster
Once the cluster creation is complete, you will see 7 nodes.  
* 2 Master Nodes
* 2 Utility Nodes
* 3 Worker Nodes

For the remainder of the tutorial, the names used will match the order of the nodes in the list.  For example, "first utility node" will refer to the first utility node in the list of nodes (notice the **Node Types**).  Physical host names also follow a naming pattern:

* [first 6 letters of cluster name][two letters representing node type][the order in the node list]

In our example with the cluster name `mycluster`:
* 2 Master Nodes:  `myclustmn0`, `myclustmn1`
* 2 Utility Nodes: `myclustun0`, `myclustun1`
* 3 Worker Nodes:  `myclustwn0`, `myclustwn1`, `myclustwn2`

Because this is a highly available cluster, the services are distributed as follows:

| Master Node 1<br />myclustmn0| Master Node 2<br />myclustmn1| Utility Node 1<br />myclustun0| Utility Node 2<br />myclustun1| Worker Nodes<br />myclustwn0...2 |
|:----|:----|:----|:----|:----|
HDFS Failover Controller<br />HDFS JournalNode<br />HDFS NameNode<br />Key Trustee KMS Proxy<br />Key Trustee Server Active<br />KTS Active Database<br />Spark History Server<br />YARN JobHistory Server<br />YARN ResourceManager<br />ZooKeeper Server<br />MIT KDC Primary| HDFS Balancer<br />HDFS Failover Controller<br />HDFS HttpFS<br />HDFS JournalNode<br />HDFS NameNode<br />Hue Load Balancer<br />Hue Server<br />Hue Kerberos Ticket Renewer<br />Key Trustee KMS Proxy<br />KTS Passive Database<br />KTS Passive<br />ResourceManager<br />ZooKeeper Server<br />MIT KDC Secondary| HDFS JournalNode<br />Cloudera Manager<br /> CM Alert Publisher<br />CM Service Event Server<br />CM Service Host Monitor<br />CM Service Navigator Audit Server<br />CM Service Navigator Metadata Server<br />CM Service Reports Manager<br />CM Service Monitor<br />Sentry Server<br />Zookeeper Server| Hive Metastore Server<br />HiveServer2<br />Hive WebHCat Server<br />Hue Load Balancer<br />Hue Server<br />Hue Kerberos Ticket Renewer<br />Oozie Server<br />Sentry Server|HDFS DataNode<br />YARN NodeManager





## Summary
You created a secure, highly available cluster that is now ready to be used for developing big data applications and processing data in Hadoop.

**This completes the tutorial!**
