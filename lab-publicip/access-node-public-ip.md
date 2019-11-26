# Access a BDS Node Using a Public IP

## Before You Begin

When Big Data Service deploys a cluster, the nodes are not accessible on the public internet.  They can only be accessed via hosts on the same subnet.  In this example, we will make the BDS Utility node running Cloudera Manager (first utility node) available externally by a creating public IP that maps to the node's private IP address.

To make a utility node available using a public IP address:
* Configure API Access to OCI (see [Preparing for Big Data Service]())
* Create a public IP address for Cloudera Manager's utility node ()
* Assign the IP to the utility node
* Connect to Hue using the new, external IP address

## Prerequisite Tasks 
You will need to perform the following tasks prior to setting up the public IP Address.  These steps will allow you to perform OCI API calls required by the IP address assignment.  These steps are the same for any client setup that will make requests using the OCI API (see [Tools Configuration](https://docs.cloud.oracle.com/iaas/Content/ToolsConfig.htm)):
1. Collect the required identifiers (user, tenancy, subnet) and Big Data Service region
1. Create a secret key
1. Generate an API Signing Key
1. Upload the API Signing Key
1. Create a Configuration File that uses all of this information

These steps are detailed in tutorial [Preparing for Big Data Service]().

## Locate the Private IP Address for Cloudera Manager's Utility Node
You can find the private IP address in your Hadoop cluster's list of attached nodes.  In the Big Data Service console: 
* Select your cluster from the compartment's cluster list
* Find the first Utility node
* Copy the IP address `your-utility-node-private-ip` associated with this BDS cluster node.


## Create public IP addresses
In the OCI Console, select the region where you Big Data Service is located and the Compartment within that region where your network has been defined.  Select **Networking >> Public IPs**.  Then,
* Click **Create Reserved Public IP**
* Provide a name.  For example; `your-utility-1`
* Click **Create Reserved Public IP** to create the IP address
* Copy the OCID for the Public IP address by clicking the three dots for that public IP and select **Copy OCID**.  Save `your-public-ip-ocid` for use later.


## Assign the Public IP Address to a Utility Node
You will use a downloadable application to assign the public IP address ([click here](https://confluence.oci.oraclecorp.com/pages/viewpage.action?spaceKey=BDSOCI&title=Public+IP+Assignment+and+Un-assignment+On+OCI&preview=/164693968/164871250/bdsPublicIpcli.jar))

Use the information that you collected and run the following command:

```bash
cd <location where you downloaded the jar file>
java -jar bdsPublicIpcli.jar -ociConfig your-config-file -ip "your-utility-node-private-ip" -subnetId "your-subnet-ocid" -operation attach -publicIpId "your-public-ip-ocid"
```

For example:
```bash
java -jar bdsPublicIpcli.jar -ociConfig ~/.oci/config -ip 10.200.25.5 -subnetId "ocid1.subnet.oc1.iad.aaaaaaaacbbbb" -operation attach -publicIpId "ocid1.publicip.oc1.iad.aaaaaaaavxxxxyyyyy"
```
## Access Cloudera Manager Using the Public IP Address
You can now access Cloudera Manager using the public IP address.  In your browser, enter
`https://your-public-ip:7183`

For example
`https://150.136.159.98:7183/`

You can now log in using your Cloudera Manager credentials.

**This completes the Lab!**