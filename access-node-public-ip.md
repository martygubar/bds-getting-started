# Access a BDS Node Using a Public IP
  ![](images/100/Title-100.png)

## Introduction

When Big Data Service deploys a cluster, the nodes are not accessible on the public internet.  They can only be accessed via hosts on the same subnet.  In this example, we will make the BDS Utility node running Hue available externally by a creating public IP that maps to the node's private IP address.

## Lab:  Access a BDS Node Using a Public IP

* Perform prerequisite tasks for creating the public IP
* Create a public IP address for Hue's utility node
* Assign the IP to the utility node
* Connect to Hue using the new, external IP address

## Steps

### **STEP 1:** Prerequisite Tasks 
You will need to perform the following tasks prior to setting up the public IP Address.  These steps will allow you to perform OCI API calls required by the IP address assignment:
1. Collect the required identifiers (user, tenancy, subnet) and Big Data Service region
1. Create a secret key
1. Generate an API Signing Key
1. Upload the API Signing Key
1. Create a Configuration File that uses all of this information

These steps are highlighted below.  For more details, please review the OCI documentation [Required Keys and OCIDs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).

**Collect Oracle Cloud Identifiers (OCIDs)**
Find the Oracle Cloud Identifiers (OCID) for your tenancy:
* Go to **Administration >> Tenancy Details**
* Copy the **OCID** in the **Tenancy Information** tab.  Save this information.
* Example:  `ocid1.tenancy.oc1..xxx`

Next, find the Oracle Cloud Identifiers (OCID) for the subnet specified when creating the BDS Cluster:
* Go to **Networking >> Virtual Cloud Networks**
* Click the VCN used by your BDS cluster
* Click the three dots for your cluster's subnet.  Click **Copy OCID**.  Save this information.
* Example:  `ocid1.publicip.oc1.iad.aaabbbbbcccccc`

Next, find the OCID for your User Identity:
* Select **Identity >> Users**
* Navigate to the IAM user that will be making the API call.  Copy the user OCID
* Example:  `ocid1.subnet.oc1.xxxxxx`

**Create a Secret Key**
The Secret Key is associated with the user making the API requests.  
* Select **Identity >> Users**.  
* Navigate to the IAM user that will be making the API call.
* Click **Customer Secret Keys** on the left side
* Click **Generate Secret Key**.  
    * Give the secret key a name and click **Generate Secret Key**
    * Save the generated secret key.  It will not be shown again.  Click **Close**
    * A new secret key is created.  Copy the **Access Key** associated with that secret key

**Generate an API Signing Key**
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

**Create a Configuration File with Collected Information**

You now have collected all of the information required to make trusted API calls to OCI.  You will save this information to a config file on your compute.  Using a text editor (not Microsoft Word):
* `Create a file ~/.oci/config`
* Add the following to that follow, replacing the highlighted fields with the infomration you collected:
```INI
[DEFAULT]
user=ocid1.user.oc1..xxxxx
fingerprint=myfingerprint
key_file=~/.oci/oci_api_key.pem
tenancy=ocid1.tenancy.oc1..xxx
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

### **STEP 2:** Locate the private IP address for Hue's utility node
You can find the private IP address in your Hadoop cluster's list of attached nodes.  In the Big Data Service console: 
* Select your cluster from the compartment's cluster list
* Find the second Utility node
* Copy the IP address associated with this BDS cluster node.


### **STEP 3:** Create public IP addresses
In the OCI Console, select the region where you Big Data Service is located and the Compartment within that region where your network has been defined.  Select **Networking >> Public IPs**.  Then,
* Click **Create Reserved Public IP**
* Provide a name.  For example; `pmteam-utility1`
* Click **Create Reserved Public IP** to create the IP address
* Copy the OCID for the Public IP address by clicking the three dots for that public IP and select **Copy OCID**.  Save this OCID for use later.


### **STEP 4:** Assign the Public IP Address to a Utility Node
You will use a downloadable application to assign the public IP address ([click here](https://confluence.oci.oraclecorp.com/pages/viewpage.action?spaceKey=BDSOCI&title=Public+IP+Assignment+and+Un-assignment+On+OCI&preview=/164693968/164871250/bdsPublicIpcli.jar))

Use the information that you collected and run the following command:

```bash
cd <location where you downloaded the jar file>
java -jar bdsPublicIpcli.jar -ociConfig your-config-file -ip "your-utility-node-private-ip" -subnetId "your-subnet-ocid" -operation attach -publicIpId "your-public-ip-ocid"
```

For example:
```bash
java -jar bdsPublicIpcli.jar -ociConfig ~/.oci/config -ip "10.200.18.30" -subnetId "ocid1.subnet.oc1.iad.aaaaaaaacb7rucoodgxp75b7srwgni2kkykutpugzwhdcesw76iwxcfruoya" -operation attach -publicIpId "ocid1.publicip.oc1.iad.aaaaaaaavgc4tmwohvca6me4uue4csi3vnbsr2hdvli5zavuaga5eath7i5q"
```
### **STEP 5:** Access Hue using the Public IP Address
You can now access Hue using the public IP address.  In your browser, enter
`http://your-public-ip:8888`

For example
`https://150.136.159.98:8888/`

You can now log in using your Hue credentials.

**This completes the Lab!**

**You are ready to proceed to [Lab 200](LabGuide200.md)**
