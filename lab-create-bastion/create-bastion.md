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
* Private key required to access the BDS cluster
* Privileges to create a Compute Node
* Oracle Big Data Service Hadoop cluster deployed 
* Admin credentials for Cloudera Manager on your source cluster


## Create an OCI Compute Instance

* From your browser, [login to Oracle Cloud Infrastructure](https://console.us-ashburn-1.oraclecloud.com/)
    * Enter your **Tenancy** and then click **Continue**.
    * Enter your OCI user name and password

    Ensure that you are creating the compute instance in the same region as your Big Data Service cluster
* Select **Compute >> Instances**
* Click **Create Instance**
* In the **Create Compute Instance** page, complete the fields similar to the example below.  You will want to use Oracle Linux 7.x.  Size the VM based on your requirements.  In this example, the bastion will only be used for accessing the cluster and submitting jobs, therefore it is sized for that use case.  

    In addition, the bastion should be added to the same VCN subnet as your Big Data Service cluster:
    * **Name your instance:** `your-bastion`
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

### Enable Connectivity from the Bastion to the BDS Cluster
To enable connectivity from the bastion to the BDS Cluster, copy the private key used during BDS cluster creation to ~/opc/.ssh on the bastion. Then, log into the bastion and test connectivity.

* Copy the private key used during BDS cluster creation and copy it to ~/opc/.ssh.  The example below is using scp (secure copy) :
    
    scp -i `your-private-key` `your-private-key` opc@`your-public-ip`:~/.ssh/

* Connect to `your-bastion` using SSH:

    ssh -i `your-private-key` opc@`your-public-ip`

Once connected to the bastion, connect to a utility node on the Hadoop cluster.  You can find the IP address by performing the following tasks:
* In a browser, log into your tenancy on OCI using the following URL:

    https://console.us-ashburn-1.oraclecloud.com/

* Select **Big Data** from the navigation menu
* Click `your-cluster` in the list of Big Data Service clusters
* Locate the IP address of a utility node
* Return to your terminal and log into that utility node using the IP address:

    ssh -i ~opc/.ssh/`your-private-key` opc@`your-utility-node-ip`

After successfully connecting, proceed to the next step and open a network port to enable the bastion to connect to the Cloudera Manager Server.

## Enable Bastion to Communicate to Cloudera Manager Server
The configuration of the bastion will on the cluster require that it can communicate to Cloudera Manager Server on port 7182.  Update the Security List for the VCN to enable that communication:

* Select **Networking >> Virtual Cloud Networks** from the OCI Console navigation menu
* Select the VCN used by your BDS Cluster
* Select the Subnet used by your BDS Cluster
* Select the Security List used by the VCN
* Click **Add Ingress Rules**
    * **Source Type:**  `CIDR`
    * **Source CIDR:**  `range`, e.g. 10.200.0.0/16
    * **IP Protocol:** `TCP`
    * **Source Port Range:** All
    * **Destination Port Range:** 7182

    Click **Add Ingress Rules**


## Add Bastion to Your Big Data Service Cluster
You will use Cloudera Manager to add the bastion to the cluster and then assign it gateway roles.  These gateway roles will allow you to access data on the cluster and run jobs.  The bastion Hadoop software will be managed by Cloudera Manager.

* Log into Cloudera Manager.  Enter the admin id and password used when creating the cluster:

    https://`your-utility-node1`:7183


# ERRORS
Administration >> Settings >> Security
Disable Use TLS Encryption for Agents.  Save
sudo systemctl restart cloudera-scm-server

Install Kerberos
* Log into `your-bastion`
* Install the Kerberos clients

    sudo yum install -y krb5-workstation krb5-libs

* Copy the private key for your cluster to the bastion.  From a MacOS or Linux client, use secure copy to copy the private key

    ```bash
    scp -i your-private-key your-private-key opc@your-bastion:~opc/.ssh/
    ```
* Log into the bastion and copy the krb5.conf file from `your-utility-node1` to `your-bastion`

    ```bash
    scp -i ~opc/.ssh/bdsKey 10.0.0.6:/etc/krb5.conf /tmp
    sudo mv /tmp/krb5.conf /etc/
    sudo chown root:root /etc/krb5.conf
    sudo chmod 644 /etc/krb5.conf
    ```
* Copy the bda.repo file to /etc/yum.repos.d/
    ```bash
    scp -i ~opc/.ssh/bdsKey 10.0.0.6:/etc/yum.repos.d/bda.repo /tmp
    sudo mv /tmp/bda.repo /etc/yum.repos.d
    sudo chown root:root /etc/yum.repos.d/bda.repo
    sudo chmod 644 /etc/yum.repos.d/bda.repo
    ```
* Update /etc/hosts on the bastion with settings from 

Install continued, but then it attempts to install parcels and fails b/c 

 * BDS sets up TLS Encryption for Cloudera Manager Agents.  Temporarily disable TLS:
    * Click **Administration >> Settings**
    * Select the **Security** category.
    * Disable TLS by clearing the option: **Use TLS Encryption for Agents**
    * Click **Save Changes**
    * Log into the Cloudera Manager host (first utility node)
    * Restart the Cloudera Manager server

    sudo systemctl restart cloudera-scm-server

    * The server will take a few minutes to restart.  You will not be able to log into Cloudera Manager until the restart successfullhy compltes



 * Click menu item **Hosts >> Add Hosts**
 * Select **Add hosts to cluster** `your-cluster`.  Click **Continue**
 * Copy the `your-bastion-private-ip` into the hostname field.  Click **Search**
 * The host will be found and displayed in the table.  If it's not listed, then fix the private IP address.  Click **Continue**
 * Select Repository:  Accept the default **Custom Repository**. http://pmteammn0.bmbdcsad1.bmbdcs.oraclevcn.com/bda  Click **Continue**
 * **Accept JDK License**
    * Select **Install Oracle Java SE Development Kit (JDK 8)**.  
    * Select **Install Java Unlimited Strength Encryption Policy Files**
    * Click **Continue**
 * **Enter Login Credentials**
    * Select **Login To All Hosts as Another User**: `opc`  
    * **Authentication Method:** Check **All hosts accept same private key**.  Upload the private key you used to create the cluster.  
    * Click **Continue**

The Cloudera Manager Agents will then be installed on the 

Error
If Use TLS Encryption for Agents is enabled in Cloudera Manager (Administration -> Settings -> Security), ensure that /etc/cloudera-scm-agent/config.ini has use_tls=1 on the host being added. Restart the corresponding agent and click the Retry link here.

systemctl restart cloudera-scm-agent.service

/etc/hosts
10.200.18.34 pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com. pmteamun0

## Summary
Your Hadoop data and metadata are now backed up to Oracle Object Storage.  You can perform incremental backups of this data by scheduling the backup jobs.  Your next step will be to restore this data to your Big Data Service Hadoop cluster.

**This completes the tutorial!**