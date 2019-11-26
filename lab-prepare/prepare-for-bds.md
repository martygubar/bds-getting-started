# Preparing for Big Data Service

## Before You Begin
There are a few tasks that are required to get started with Big Data Service.  Several of these tasks need to be performed by the Cloud Administrator for your tenancy.  There are also optional tasks that make it easier to manage your environment.  For example, creating compartments and groups are optional - but they will simplify administration tasks as your environment exapnds.

| User | Task | Purpose | Required | How to |
|:----|:----|:----|:----|:----|
|Cloud Admin| [Create a Compartment for BDS Resources](/?preparing-for-big-data-service#CreateaCompartment)| Helps organize your cloud resources | No |OCI Console: Identity >> Compartments |
|Cloud Admin| [Create a BDS Administrator Group and Add an Admin User]()| Apply policies to groups instead of individual users | No | OCI Console: Identity >> Compartments |
|Cloud Admin | [Create Policies Required to Administer your Big Data Service Instances]() | Enable the Big Data Service to create clusters in the customer tenancy.  Also delegate cluster lifecycle management operations to BDS Administrators | Yes|OCI Console: Identity >> Policies|
|Cloud Admin or BDS Admin | [Create a Virtual Cloud Network]()| Use an existing Tenancy VCN or create a new one.  Required if a VCN does not exist | Yes |OCI Console: Networking >> Virtual Cloud Networks|
|Cloud Admin or BDS Admin | [Configure API Access to OCI]()| Enables programmatic control over cluster lifecycle operations | No |OCI API and CLI|



## Create a Compartment
Create a **Compartment** that will organize the resources used by Big Data Service.  There are other ways of organizing Oracle Cloud resources that you can also explore.

Log into the OCI console as the Cloud Administrator.  Then, 
* Select **Identity >> Compartments**
* Click **Create Compartment**.  Specify `your-compartment`, provide a description, and then click **Create Compartment**

## Create a BDS Administrator Group and Add an Admin User
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

The Big Data Service creates VMs, creates VNICs and adds them to the customer subnet that is used for accessing BDS instance. Create the following policy in your **root** compartment to allow cluster creation. 

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
Open ports for Hadoop services.  Ports include those required by Hue and Cloudera Manager.

* Click **Security Lists**
* Click **Default Security List for `your-network-name`**
* Add the following Ingress Rules:
    * Click **Add Ingress Rule**
    * Update Source CDR: `0.0.0.0/0`
    * Specify the following **Destination Port Range**: `7183,7182,7180,8888-8890,8090,18088`
    * Click **Add Ingress Rules** 

## Configure API Access to OCI
There are times when you will want programmatic access to OCI.  This is useful, for example, when you want to automate cluster management using the API. 

These steps are the same for any client setup that will make requests using the OCI API (see [Tools Configuration](https://docs.cloud.oracle.com/iaas/Content/ToolsConfig.htm)):
1. Collect the required identifiers (user, tenancy, subnet) and Big Data Service region
1. Create a secret key
1. Generate an API Signing Key
1. Upload the API Signing Key
1. Create a Configuration File that uses all of this information

These steps are highlighted below.  For more details, please review the OCI documentation [Required Keys and OCIDs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).


### Collect Oracle Cloud Identifiers (OCIDs) Needed by APIs
Follow the steps listed below.  For more details, please review the OCI documentation [Required Keys and OCIDs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).

#### Collect Oracle Cloud Identifiers (OCIDs)
**Tenancy:**  Find the Oracle Cloud Identifiers (OCID) for your *tenancy*:
* Go to **Administration >> Tenancy Details**
* Copy the **OCID** in the **Tenancy Information** tab.  Save this information.
* Example:  `ocid1.tenancy.oc1..xxx`

**Subnet:**  Next, find the Oracle Cloud Identifiers (OCID) for the *subnet* specified when creating the BDS Cluster:
* Go to **Networking >> Virtual Cloud Networks**
* Click the VCN used by your BDS cluster
* Click the three dots for your cluster's subnet.  Click **Copy OCID**.  Save this information.
* Example:  `ocid1.subnet.oc1.xxxxxx`

**User Identity:** Next, find the OCID for your *User Identity*:
* Select **Identity >> Users**
* Navigate to the IAM user that will be making the API call.  Copy the user OCID
* Example:  `ocid1.user.oc1..aaabbbcccc`

### Create a Secret Key
The Secret Key is associated with the user making the API requests.  
* Select **Identity >> Users**.  
* Navigate to the IAM user that will be making the API call.
* Click **Customer Secret Keys** on the left side
* Click **Generate Secret Key**.  
    * Give the secret key a name and click **Generate Secret Key**
    * Save the generated secret key.  It will not be shown again.  Click **Close**
    * A new secret key is created.  Copy the **Access Key** associated with that secret key and save it.

### Generate an API Signing Key
Run the following commands to generate the public/private key pair in PEM format.  The steps below work in Linux and Macos environments - see the documentation for [Windows environments](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).
```bash
# store generated keys in this folder
mkdir ~/.oci

# generate the private key w/no passcode.  Alter this command to add a passcode
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# change the permissions so that only you can see the private key
chmod go-rwx ~/.oci/oci_api_key.pem

# generate the public key
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

**Upload this key to the OCI Console and associate.**
* Select **Identity >> Users**.  
* Navigate to the IAM user that will be making the API call.
* Click **API Keys** on the left side of the page
* Click **Add Public Key**
* Copy the entire contents of the public key `~/.oci/oci_api_key_public.pem' into the **Public Key** field
* Click **Add**
* Copy the generated **Fingerprint** and save it to a safe place

### Create a Configuration File with Collected Information

You now have collected all of the information required to make trusted API calls to OCI.  You will save this information to a config file on your compute.  Using a text editor (not Microsoft Word):
* Create a file `~/.oci/config`
* Add the following to that config file, replacing the highlighted fields with the infomration you collected:
```INI
[DEFAULT]
user=your-user-ocid
fingerprint=your-fingerprint
key_file=~/.oci/oci_api_key.pem
tenancy=your-tenancy
region=your-bds-region
```
Below is an example with all of the fields completed:
```INI
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaaqbbbbccccccddddeeeefffgggg
fingerprint=a1:2b:65:a1:31:1c:ae:4f:43:8a:1c:75:d3:gg:94:ea
key_file=~/.oci/oci_api_key.pem
tenancy=ocid1.tenancy.oc1..aaaabbbbbcccccddddddeeeeeefffff
region=us-ashburn-1
```
