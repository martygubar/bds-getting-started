# Auth Rules


•	Collect/prepare the following:
o	Generate S3 API Secret Key, capture the secret key and access key.
o	OCI Object Storage Bucket name and OCI Tenancy name


## Get Started

| User          | Task      | Tool   | 
|:---------------|:-----------|:---------------|
|Cloud Admin| Create a Compartment for BDS entities| OCI Console: Identity >> Compartments |
|Cloud Admin| Create an Admin Group for your users that will be managing your BDS Clusters| OCI Console: Identity >> Compartments |
|Cloud Admin| Create a Big Data Service Cluster Administrator| OCI Console:  Identity >> Users |





* *Cloud Admin*:  Add a user that will be creating and managing Big Data Service Clusters
* *Cloud Admin*:  In our tutorial, 
* *Cloud Admin*:  Allow Big Data Service 

## Create a Compartment
Create a **Compartment** that will organize the entities used by Big Data Service.  There are other ways of organizing Oracle Cloud resources that you can also explore.

Log into the OCI console as the Cloud Administrator.  Then, 
* Select **Identity >> Compartments**
* Click **Create Compartment**.  Specify `your-compartment`, provide a description, and then click **Create Compartment**

In this example, all Big Data Service related items are going to be stored in a compartment called `bds-cluster`.

## Create a BDS Admin Group
Create a group for you Big Data Service administrators.  You will grant privileges to this group to perform the critical administrative tasks.
* Select **Identity >> Groups**
* Click **Create Group**.  Specify `your-admin-group`, provide a description, and then click **Create Group**



## Creating a Cluster

BDS Control Plane creates for BDS VMs VNICs to customer's subnet that is used for accessing BDS instance. Please, create following policy in your root compartment:
    
    allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_CREATE, VNIC_ATTACHMENT_READ, SUBNET_READ, SUBNET_ATTACH} in compartment your-compartment


Cloudera amdin id, password
Utility Node 1 IP Address

## Creating a Virtual Cloud Network


## Table of things you need

| Area          | Item      | Description   | Value|
|:---------------|:-----------|:---------------|:------|
|Create Cluster|
|Networking | Subnet OCID| Used



Access Key: cca1aff544e45b565418e81e94c6f6b2bc6edf5d
Secret Key: gvAzaMwncIfeiwKcwMHqg2i5GYBSMhCqXrvb7yuoiiA=