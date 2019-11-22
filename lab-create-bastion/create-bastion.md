# Create a Bastion to Access Your Cluster

## Before You Begin

### Objectives
The goal for this tutorial is to create a bastion (aka "Edge Node") to your Hadoop cluster.  From this node, you will connect to the cluster to view its contents, run jobs, and more.  This eliminates the need to connect directly to the cluster nodes from a public network.

To create the bastion, you will:
* Log into Oracle Cloud Infrastructure and create a Compute node in the same subnet as your Big Data Service cluster
* Connect to Cloudera Manager and add that new Compute Node to the cluster - deploying only gateway roles to it

### Requirements

To complete this lab, you need to have the following:

* Login credentials and a tenancy name for the Oracle Cloud Infrastructure Console
* Privileges to create a Compute Node
* Oracle Big Data Service Hadoop cluster deployed 
* Admin credentials for Cloudera Manager on your source cluster


## Create an OCI Compute Instance

* From your browser, [login to Oracle Cloud Infrastructure](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)
    * Enter your **Tenancy** and then click **Continue**.
    * Enter your OCI user name and password

    Ensure that you are creating the compute instance in the same region as your Big Data Service cluster
* Select **Compute >> Instances**
* Click **Create Instance**
* In the **Create Compute Instance** page, complete the fields similar to the example below.  You will want to use Oracle Linux 7.x.  Size the VM based on your requirements.  In this example, the bastion will only be used for accessing the cluster and submitting jobs, therefore it is sized for that use case.  

    In addition, the bastion should be added to the same VCN subnet as your Big Data Service cluster:
    * **Name your instance:** `pmteam-bastion`
    * **Operating System:** `Oracle Linux 7.7` (this matches the BDS Cluster OS)
    * **Avaiability Domain:** `AD 1`  (choose what is appropriate for your deployment)
    * **Instance Type:** `Virtual Machine`
    * **Instance Shape:** `VM.Standard2.1 (VirtualMachine)`
    * **Configure networking**
        * **Virtual cloud network compartment:**  `your-bds-network-compartment`
        * **Virtual cloud network:** `your-bds-vcn`
        * **Subnet compartment:** `your-bds-subnet-compartment`
        * **Subnet:** `your-bds-subnet`
        * **Use network security groups to control traffic:** `enable if used`
        * **Assign public IP address:** `yes`
    * **Boot Volume**
        * **Custom boot volume size:** Change this value based on requirements
        * Specify values for encryption based on your requirements
    * **Add SSH key**
        * Select the public key that you plan to use for this bastion host.  The key is used for connecting to the host.
    * Click **Create**

### Capture Instance Details
Once the instance creation is complete, save the key information required to access the cluster:
* **Public IP Address**
* **Private IP Adress**
* **Internal FQDN**

This information will be used to 1) add the host to the cluster and 2) access the host from a client

### Connect to the New Host
Connect to the host using SSH:

ssh -i `your-private-key` opc@`your-public-ip`

After successfully connecting, proceed to the next step and add the new host to your Big Data Service cluster.

## Add Bastion to Your Big Data Service Cluster

  

## Summary
Your Hadoop data and metadata are now backed up to Oracle Object Storage.  You can perform incremental backups of this data by scheduling the backup jobs.  Your next step will be to restore this data to your Big Data Service Hadoop cluster.

**This completes the tutorial!**