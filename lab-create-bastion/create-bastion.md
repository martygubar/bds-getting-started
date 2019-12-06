# Create a Bastion to Access Your Cluster

## Before You Begin
A bastion is a compute instance that serves as the public entry point to users that will be accessing the cluster.  It enables you to protect sensitive resources by placing them in private networks that can't be accessed directly from the public internet. You expose a single, known public entry point that you audit regularly, harden,and secure. So you avoid exposing the more sensitive parts of the topology, without compromising access to them.  For more information about bastions, you can refer to the [OCI documentation](https://docs.oracle.com/en/solutions/set-resources-to-provision-deploy-cloud-environment/index.html#GUID-8A2C8FB7-66E8-4838-8162-09EDDC834BE2).

In the context of this tutorial, there are two types of bastions.  The first is a simple compute node that provides access to the Big Data Service cluster nodes; these nodes are only accessible thru private IP addresses (unless you decide to assign a public IP to a node).  The second has Hadoop gateway roles deployed to it (e.g. HDFS, Spark, Hive).  This allows you to easily access HDFS and run jobs from the bastion.

### Objectives
The goal for this tutorial is to create a bastion (aka "Edge Node") to your Hadoop cluster.  From this node, you will connect to the cluster to view its contents, run jobs, and more.  This eliminates the need to connect directly to the cluster nodes from a public network.

To create the bastion, you will:
1. Log into Oracle Cloud Infrastructure and create a Compute node in the same subnet as your Big Data Service cluster
1. Enable Connectivity from the Bastion to the BDS Cluster
1. Update the bastion with required software (e.g. Kerberos, Java)
1. Connect to Cloudera Manager and add that new Compute Node to the cluster - deploying only gateway roles to it

You can stop after step 2 if you do not want to access HDFS and submit jobs from the bastion.

## Requirements

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
    * **Name your instance:** `mybastion`
    * **Operating System:** `Oracle Linux 7.7` (this matches the BDS Cluster OS)
    * **Avaiability Domain:** `AD 1`  (choose what is appropriate for your deployment)
    * **Instance Type:** `Virtual Machine`
    * **Instance Shape:** `VM.Standard2.1 (VirtualMachine)`
    * **Configure networking**
        * **Virtual cloud network compartment:**  `mycompartment`
        * **Virtual cloud network:** `mynetwork`
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

## Enable Connectivity from the Bastion to the BDS Cluster
To enable connectivity from the bastion to the BDS Cluster, copy the private key used during BDS cluster creation to ~/opc/.ssh on the bastion. Then, log into the bastion and test connectivity.

* Copy the private key used during BDS cluster creation and copy it to ~/opc/.ssh.  The example below is using scp (secure copy):
    
    scp -i `your-private-key` `your-private-key` opc@`your-public-ip`:~/.ssh/

* Connect to `your-bastion` using SSH:

    ssh -i `your-private-key` opc@`your-public-ip`

Once connected to the bastion, connect to the first utility node on the Hadoop cluster.  You can find the utility node IP address by performing the following tasks:
* In a browser, log into your tenancy on OCI using the following URL:

    https://console.us-ashburn-1.oraclecloud.com/

* Select **Big Data** from the navigation menu
* Click `your-cluster` in the list of Big Data Service clusters
* Locate the IP address of the first utility node and first master node.  Save these IP addresses.
* Return to your terminal and log into that utility node using the IP address:

    ssh -i ~opc/.ssh/`your-private-key` opc@`your-utility-node1-ip`

To make subsequent connections to the cluster nodes easier, create an SSH configuration file.  Return to the bastion node by typing `exit` from the utility node.  Then, create the configuration file:

```bash
cd ~opc/.ssh
echo "Host your-utility-node1
   Hostname `your-utility-node-ip`
   ServerAliveInterval 50
   User opc
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   IdentityFile ~opc/.ssh/bdsKey
   
   Host your-master-node1
   Hostname `your-master-node-ip`
   ServerAliveInterval 50
   User opc
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   IdentityFile ~opc/.ssh/bdsKey" >> config
chmod 644 config
```
You can now connect to the utility node more easily, using just the hostname:

    ssh your-utility-node1

Copy this file to the root users .ssh home.  This will allow secure copy to work in the next sections:
```bash
sudo cp ~opc/.ssh/config /root/.ssh/
```

## DONT THINK DCLI IS REQUIRED
### Enable dcli to Work with the Bastion
**dcli** is an Oracle utility installed on the cluster nodes that allows you to execute commands and copy files across multiple hosts.  It is an extremely useful utility that we will use later when updating the cluster and the bastion.  **dcli** is typically executed by the root user and requires passwordless connections.  To enable passwordless ssh into the bastion from the cluster, copy the ssh public key from the utility node to the bastion and then add it to the authorized_keys file for the root user.

On the bastion node, run the following commands as the opc user:
```bash
cd
scp your-utility-node1:.ssh/id_rsa.pub .
cat id_rsa.pub | sudo tee -a /root/.ssh/authorized_keys
rm id_rsa.pub
```
### Update /etc/hosts on the Bastion
Update the **/etc/hosts** file on the bastion to include the first master and utility node.  To determine the hostname and the fqdn, you can log into the two nodes using the host names that you used in the ssh confg file and then running the `hostname` command.  For example:
```bash
ssh your-utility-node1
hostname
```
The hostname that is returned by the command is the fqdn.  The short name is the name prior to the first ".".  Add the IP address, fqdn and host short name to the /etc/hosts file on the bastion.  NOTE: the IP addresses in the /etc/hosts file on the utility and master nodes will be different than the IP addresses add to the bastion; they are private IP addresses used for intra-cluster communication.  Use the IP addresses that you added to the SSH config file in the previous section.

Below is an example of a before and after snapshot of an /etc/hosts file for the ``pmteam`` cluster.

**Before:**
```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```
**After**
```bash
$ echo "10.0.0.14 pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com. pmteamun0" | sudo tee -a /etc/hosts
$ echo "10.0.0.12 pmteammn0.bmbdcsad1.bmbdcs.oraclevcn.com pmteammn0.bmbdcsad1.bmbdcs.oraclevcn.com. pmteammn0" | sudo tee -a /etc/hosts

$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.0.0.14 pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com. pmteamun0
10.0.0.12 pmteammn0.bmbdcsad1.bmbdcs.oraclevcn.com pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com. pmteammn0
```
Your bastion will now be able to communicate with the cluster using both SSH and other protocols.

## Update the Bastion with Required Software
Now that connectivity to the cluster is configured, install and configure the required software for the ede node:
* Kerberos
* Cloudera Manager Agents
* Java 8

### Install Core Software
The core software will be installed from Oracle's software repository.  The Big Data Service specific repository is on the first master node of the cluster.  Copy the **bda.repo** file from the cluster node to the bastion.  On the bastion node:

* Make Big Data Service software available to the bastion via YUM.  Copy the **bda.repo** file to the bastion node as the root user.  
```bash
sudo scp your-utility-node1:/etc/yum.repos.d/bda.repo /etc/yum.repos.d/

```

* Now that the Big Data Service software is available, install Kerberos, Cloudera Manager Agents and the Oracle JDK (v8).  As the opc user on the bastion node, run the following commands:
    ```bash
    sudo yum clean all
    sudo yum install -y krb5-workstation krb5-libs jdk1.8
    export JAVA_HOME=/usr/java/latest 
    echo "export JAVA_HOME=/usr/java/latest" | sudo tee -a /etc/profile.d/mystartup.sh
    sudo chmod 644 /etc/profile.d/mystartup.sh
    sudo yum install -y cloudera-manager-agent
    ```
### Configure the Core Software
There are configuration files that must be updated for each of the newly installed packages:
* Java:  Java Cryptography Extension (JCE) unlimited strength jurisdiction policy files.  This is required for Kerberos access to the cluster.
    ```bash
    sudo scp pmteamun0:/usr/java/latest/jre/lib/security/*.jar /usr/java/latest/jre/lib/security/
    ```
* Keberos:  Kerberos configuration file
    ```bash
    sudo scp pmteamun0:/etc/krb5.conf /etc/
    ```
* Cloudera Manager Agent: Configuration files and PEM file
Update the Cloudera Manager configuration so that it can connect to the Cloudera Manager Server.
    
    ```bash
    sudo scp pmteamun0:/etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/
    sudo scp pmteamun0:/etc/cloudera-scm-agent/agentkey.pw /etc/cloudera-scm-agent/
    sudo mkdir -p /opt/cloudera/security/x509/
    sudo scp pmteamun0:/opt/cloudera/security/x509/agents.pem /opt/cloudera/security/x509/
    ```
* Start the Cloudera Manager Agents
    ```bash
    sudo systemctl start cloudera-scm-agent
    sudo systemctl enable cloudera-scm-agent
    ````

### Enable Cluster Nodes to Access Bastion
Update /etc/hosts with the bastion IP

** Update the /etc/yum.repos.d














## Enable Bastion to Communicate to Cloudera Manager Server
### Bastion to Cloudera Manager Server
The configuration of the bastion will on the cluster require that it can communicate to Cloudera Manager Server on port 7182.  Update the Security List for the VCN to enable that communication:

REMOVE THIS SECTION
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


## Update /etc/hosts on the bastion
... specify the updates to =/etc/hosts here

## Add Bastion to Your Big Data Service Cluster
You will use Cloudera Manager to add the bastion to the cluster and then assign it gateway roles.  These gateway roles will allow you to access data on the cluster and run jobs.  The bastion Hadoop software will be managed by Cloudera Manager.

* Log into Cloudera Manager.  Enter the admin id and password used when creating the cluster:

    https://`your-utility-node1`:7183


# ERRORS
Administration >> Settings >> Security
Disable Use TLS Encryption for Agents.  Save
sudo systemctl restart cloudera-scm-server

* Copy the private key for your cluster to the bastion.  From a MacOS or Linux client, use secure copy to copy the private key

    ```bash
    scp -i your-private-key your-private-key opc@your-bastion:~opc/.ssh/
    ```

Install Kerberos
* Log into `your-bastion`
* Install the Kerberos clients

    sudo yum install -y krb5-workstation krb5-libs

* Copy the bda.repo file to /etc/yum.repos.d/  ### DON"T DO THIS
    ```bash
    scp -i ~opc/.ssh/bdsKey 10.0.0.6:/etc/yum.repos.d/bda.repo /tmp
    sudo mv /tmp/bda.repo /etc/yum.repos.d
    sudo chown root:root /etc/yum.repos.d/bda.repo
    sudo chmod 644 /etc/yum.repos.d/bda.repo
    ```
* Update /etc/hosts on the bastion with settings from 


* Log into the bastion and copy the krb5.conf file from `your-utility-node1` to `your-bastion`

    ```bash
    scp -i ~opc/.ssh/bdsKey 10.0.0.14:/etc/krb5.conf /tmp
    sudo mv /tmp/krb5.conf /etc/
    sudo chown root:root /etc/krb5.conf
    sudo chmod 644 /etc/krb5.conf
    ```

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
 * Select Repository:  
    * Choose **Public Cloudera Repository**
        * If this does not work, select a Custom Repository with the Cloudera URL.  For Cloudera 6.32.0, this would be:  `https://archive.cloudera.com/cm6/6.2.0/redhat7/yum/`
    * Click **Continue**
 * **Accept JDK License**
    * Select **Install Oracle Java SE Development Kit (JDK 8)**.  
    * Select **Install Java Unlimited Strength Encryption Policy Files**
    * Click **Continue**
 * **Enter Login Credentials**
    * Select **Login To All Hosts as Another User**: `opc`  
    * **Authentication Method:** Check **All hosts accept same private key**.  Upload the private key you used to create the cluster.  
    * Click **Continue**

The Cloudera Manager Agents will then be installed on the bastion node.

Error
If Use TLS Encryption for Agents is enabled in Cloudera Manager (Administration -> Settings -> Security), ensure that /etc/cloudera-scm-agent/config.ini has use_tls=1 on the host being added. Restart the corresponding agent and click the Retry link here.

systemctl restart cloudera-scm-agent.service

/etc/hosts
10.200.18.34 pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com pmteamun0.bmbdcsad1.bmbdcs.oraclevcn.com. pmteamun0

## Summary
Your Hadoop data and metadata are now backed up to Oracle Object Storage.  You can perform incremental backups of this data by scheduling the backup jobs.  Your next step will be to restore this data to your Big Data Service Hadoop cluster.

**This completes the tutorial!**