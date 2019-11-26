# Auth Rules


•	Collect/prepare the following:
o	Generate S3 API Secret Key, capture the secret key and access key.
o	OCI Object Storage Bucket name and OCI Tenancy name


## Getting Started
There are a few tasks that are required to get started with Big Data Service.  Several of these tasks need to be performed by the Cloud Administrator for your tenancy.  There are also optional tasks that make it easier to manage your environment.  For example, creating compartments and groups will simplify administration tasks as your environment exapnds.

| User | Task | Purpose | Required | How to |
|:----|:----|:----|:----|:----|
|Cloud Admin| [Create a Compartment for BDS Resources](#CreateaCompartment)| Helps organize your cloud resources | No |OCI Console: Identity >> Compartments |
|Cloud Admin| Create a BDS Admin Group for users that will manage BDS Cluster lifecycle| Apply policies to groups instead of individual users | No | OCI Console: Identity >> Compartments |
|Cloud Admin| Create a Big Data Service Cluster Administrator | User that will manage cluster lifecycle operations | No | OCI Console:  Identity >> Users |
|Cloud Admin | Create policy to enable BDS Admin Group to manage clusters | Required when Tenancy Admin is delegating cluster management to BDS Administrators | No|OCI Console: Identity >> Policies|
|Cloud Admin | Create policy to enable BDS service to create clusters within a customer tenancy | BDS Service will create cloud resources (VMs, Bare Metal nodes, etc).  It must be granted the privilege to do so. | Yes|OCI Console: Identity >> Policies|
|Cloud Admin or BDS Admin | Create a Virtual Cloud Network| Use an existing Tenancy VCN or create a new one.  Required if a VCN does not exist | Yes |OCI Console: Networking >> Virtual Cloud Networks|


## Create a Compartment
Create a **Compartment** that will capture the resources used by Big Data Service.  There are other ways of organizing Oracle Cloud resources that you can also explore.

Log into the OCI console as the Cloud Administrator.  Then, 
* Select **Identity >> Compartments**
* Click **Create Compartment**.  Specify `your-compartment`, provide a description, and then click **Create Compartment**

## Create a BDS Administrator Group and add an Admin User
Create a group for you Big Data Service administrators.  You will grant privileges to this group to perform the critical administrative tasks required to manage your cluster lifecycle.
* Select **Identity >> Groups**
* Click **Create Group**.  Specify `your-admin-group`, provide a description, and then click **Create Group**
* Select `your-admin-group` from the list of groups
* Click **Add User to Group**
* Select `your-admin-user` from the list of users and click **Add**


## Create Policies Required to Administer your Big Data Service Instances
### Manage Big Data Services and Manage Virtual Cloud Networks
In the OCI Console navigation menu, select **Identity >> Policies**.  Ensure that you are in the `your-tenancy` compartment. Then, click **Create Policy**.  Name the policy `your-admin-policies` and provide a description.  Then, add the following policiy statements:

    allow group your-admin-group to manage bds-instance in compartment your-compartment
    allow group your-admin-group to manage virtual-network-family in compartment your-compartment

### Creating a Cluster

The Big Data Service creates VMs, creates VNICs and adds them to the customer subnet that is used for accessing BDS instance. Create following policy in your **root** compartment to allow cluster creation. 

In the OCI Console navigation menu, select **Identity >> Policies**.  Ensure that you are in the **root** compartment.  Click **Create Policy** and name it `your-bds-policy`.  Then, add the following policy statement:
    
    allow service bdsprod to {VNIC_READ, VNIC_ATTACH, VNIC_CREATE, VNIC_ATTACHMENT_READ, SUBNET_READ, SUBNET_ATTACH} in compartment your-compartment

## Create a Virtual Cloud Network 
In this section, you will set up the Virtal Cloud Network that will be used by your Big Data Service.  Note, you may also leverage an existing VCN if you already have one.  If you have an existing VCN, ensure it is using a Regional subnet and that the appropriate ports are opened.

### Create a VCN
* In the OCI Console navigation menu, select **Networking >> Virtual Cloud Networks**
* Click **Create Virtual Cloud Network**
    * **Name:** `your-network-name`
    * **Create in Compartment:** `your-compartment`
    * Select **CREATE VIRTUAL CLOUD NETWORK ONLY**
    * **CIDR BLOCK:** `10.0.0.0/16` (modify as required)
    * Select **Use DNS Hostnames in this VCN:** 
    * **DNS LABEL:** `bdsnetwork`
    * **Create Virtual Cloud Network**

### Create a Subnet
* Click **Create Subnet** in this VCN
    * **Name:** `your-subnet`
    * **Subnet Type:** `Regional`
    * **CIDR Block:** `10.0.0.0/24` (modify as required)
    * **Route Table:**  `Default Route Table for your-network`
    * Select **Public Subnet**
    * Check **Use DNS Hostnames in this Subnet**
    * **DNS Label:** `bdssubnet`
    * **DHCP Options:** `Default DHCP Options for your-network`
    * **Security List:** `Default Security List for your-network`
    * Click **Create Subnet**

### Create a NAT Gateway
A NAT gateway lets instances that don't have a public IP address access the internet.
* From the list of Resources, click **NAT Gateways**
* Click **Create NAT Gateway**
    * **Name:** `your-nat-gateway`    
    * **Create in Compartment:** `your-compartment`
    * Click **Create NAT Gateway**

### Create an Internet Gateway
An internet gateway is an optional virtual router you can add to your VCN to enable direct connectivity to the internet.  The gateway supports connections initiated from within the VCN (egress) and connections initiated from the internet (ingress).
* From the list of Resources, click **Internet Gateways**
* Click **Create Internet Gateway**
    * **Name:** `your-internet-gateway`    
    * **Create in Compartment:** `your-compartment`
    * Click **Create Internet Gateway**

### Create a Service Gateway
A service gateway enables cloud resources without public IP addresses to privately access Oracle services.  This allows a service to access the Oracle Services Network without the traffic going over the internet.
* From the list of Resources, click **Service Gateways**
* Click **Create Service Gateway**
    * **Name:** `your-service-gateway`    
    * **Create in Compartment:** `your-compartment`
    * **Services:** `All <region> Services in Oracle Services Network`
    * Click **Create Service Gateway**


### Create a Routing Rule
Add two routing rules, one for internet access and the other for the Oracle service gateway
* From the list of Resources, select **Route Tables**
* Click **Default Route Table for ``your-network``**
* Add the internet access rule.  Click **Add Route Rules**
    * **Target Type:** `Internet Gateway`
    * **Destination CIDR Block:** `0.0.0.0/0`
    * **Compartment:** `your-compartment`
    * **Target Internet Gateway:**  `your-internet-gateway`
    * Click **Add Route Rules**
* Add the service route rule.  Click **Add Route Rules**
    * **Target Type:** `Service Gateway`
    * **Destination Service:** `OCI <region> Object Storage`
    * **Compartment:** `your-compartment`
    * **Target Service Gateway:** `your-service-gateway`
    * Click **Add Route Rules**

### Update the Security List
Open up ports for Hadoop services:
* Click **Security Lists**
* Click **Default Security List for `your-network-name`**
* Add the following Ingress Rules:
    * Click **Add Ingress Rule**
    * Update Source CDR: `0.0.0.0/0`
    * Specify the following **Destination Port Range**: `7183,7182,7180,8888-8890,8090,18088`
    * Click **Add Ingress Rules** 




Access Key: cca1aff544e45b565418e81e94c6f6b2bc6edf5d
Secret Key: gvAzaMwncIfeiwKcwMHqg2i5GYBSMhCqXrvb7yuoiiA=