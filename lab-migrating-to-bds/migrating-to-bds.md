# Migrating to Big Data Service on Oracle Cloud Infrastructure

## Before You Begin

Learn about the benefits of migrating your existing Big Data Cloud Service to Big Data Service on Oracle Cloud Infrastructure (OCI), as well as walking through the migration process.

Topics:
* Why Migrate to Oracle Cloud Infrastructure
* About Oracle Cloud Infrastructure
* Migration Scope
* Migrating to Big Data Service on Oracle Cloud Infrastructure

## Why Migrate to Oracle Cloud Infrastructure

Oracle encourages you to migrate your Big Data Cloud Service workload to Big Data Service on Oracle Cloud Infrastructure. You can gain several advantages by doing so.

In Oracle Cloud, you provision resources in specific regions, which are localized to geographic locations.  This gives you the flexibility to deploy in region(s) with proximity to you or your data sources.

Oracle Cloud Infrastructure is Oracle's more modern infrastructure platform that's based on the latest cloud technologies and standards. It allows for more flexible deployments than Big Data Cloud Service – ranging from small VM-based clusters to high-end bare metal deployments. Oracle Cloud Infrastructure also has more predictable pricing and lower costs in terms of Oracle Compute Units (OCPUs) per hour and storage capacity. Most importantly, Oracle continues to invest in Oracle Cloud Infrastructure, including the addition of new regions, services, and features. See [Data Regions for Platform and Infrastructure Services](https://cloud.oracle.com/data-regions)

You can benefit from these features when you migrate from Big Data Cloud Service to Big Data Service on Oracle Cloud Infrastructure:

* Deploy your managed cluster using a wide range of Oracle Cloud Infrastructure compute shapes
    * Allows for more dynamic control of cluster capacity and resources
    * Allows customization of your cluster hosts to meet your workload requirements, and suit your budget
    * Provides infinite scalability, for both compute and storage
    * Scale up or down cluster resources quickly
* Leverage Fast Connect and private subnets to allow completely private high-speed access to your cluster, treat OCI as an extension of your data center

## About Oracle Cloud Infrastructure
Get familiar with basic Oracle Cloud Infrastructure security, network, and storage concepts.

Cloud resources in Oracle Cloud Infrastructure are created in logical compartments. You also create fine-grained policies to control access to the resources within a compartment.

You create instances within an Oracle Cloud Infrastructure region. You also specify an availability domain (AD), if supported in the selected region.

A virtual cloud network (VCN) is comprised of one or more subnets, and an instance is assigned to a specific subnet. Oracle Cloud Infrastructure does not allow you to reserve specific IP addresses for platform services.

A subnet's security lists permit and block traffic to and from specific IP addresses and ports.

Instances can communicate with resources outside of Oracle Cloud by using Oracle Cloud Infrastructure FastConnect, which provides a fast, dedicated connection to your on-premises network. Alternatively, use an IPSec VPN.

A bucket in Oracle Cloud Infrastructure Object Storage can be used to store files and share them with multiple instances. A user's generated authentication token (auth token) is required to access the bucket.

To learn more, see [Key Concepts and Terminology](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/event-hub-cloud/ehcmg&id=oci_concepts) in the Oracle Cloud Infrastructure documentation

## Migration Overview
### Introduction
Migrating from BDCS to BDS on OCI is done in several steps:
* [Backup Your Hadoop Cluster to Oracle Object Storage](../?backup-hadoop-cluster-object-storage)
* [Create Big Data Service cluster on Oracle Cloud Infrastructure](../?create-bds-hadoop-cluster)
* [Restore Your Hadoop Cluster from Oracle Object Storage](../?restore-hadoop-cluster-object-store)


Customers are advised to retain their Big Data Cloud Service for minimum of 3 months (at least in stopped state) after migrating to OCI so that if any data/metadata/configuration is found missing, they can refer to the BDCS cluster to get the required information.

### Migration Caveats
The [OCI HDFS Connector](https://github.com/oracle/oci-hdfs-connector) is not whitelisted by Cloudera or included in current distributions.  This has been committed to the Apache Foundation, as such native OCI endpoints will be usable in the future.   In the short term, use of [S3 Compatibility](https://docs.cloud.oracle.com/iaas/Content/Object/Tasks/s3compatibleapi.htm) will provide access to Object Storage.

When accessing Object Storage directly from compute instances on OCI, clusters cache data to the /tmp filesystem at the OS level.   Ensure your workers have sufficient capacity in this location prior to performing any data migration.

## Backup Your BDCS Cluster to Oracle Object Storage
### Preparing for BDCS backup
* Make sure you have admin access to your Big Data Cloud Service cluster
    * You will need the administrator credentials for Cloudera Manager
    * If you are running a secure cluster, ensure you have a Hadoop admin user that has full access to the HDFS data and Hive metadata that will be backed up to Oracle Object Storage
* Setup OCI Object store to which HDFS data can be copied. See [Overview of Object Storage](https://docs.cloud.oracle.com/iaas/Content/Object/Concepts/objectstorageoverview.htm) for more details. 
* Setup your OCI Tenancy
    * Ensure an OCI User is created and added to required groups by the tenancy admin. 
        * User has permission and is able to access OCI Console
        * User has permission and is able to create a bucket. (See “Let Object Storage admins manage Buckets and Objects”).
        * User is able to inspect configuration for OCI Object Store 
    
    See [Authorization Requirements](../?authorization-requirements) for details.

### Perform the BDCS Backup
Now that you have the appropriate permissions to backup your cluster, you can run the steps found in the [Backup Your Hadoop Cluster to Oracle Object Storage](../?backup-hadoop-cluster-object-storage) tutorial.

## Create a Big Data Service cluster on Oracle Cloud Infrastructure
You are now ready to create a Big Data Service Hadoop Cluster.  
### Preparing for Creating a Big Data Service cluster
Creating a cluster requires a few simple steps.  However, you will need to plan your cluster deployment and take into account the following considerations:
* What sizing is required, from both a data storage and compute capcity perspective?
* What type of storage is required?  Do you want the flexibility of Oracle Block Storage?  The high performance of direct attached NVmE storage?
* How do you want to access the cluster?  Using a bastion?  FastConnect?  Public IP?
* Do you need advanced security and high availability?  Or, a simple cluster, insecure cluster?

Once you have this information, you are ready to create your Hadoop cluster

### Create a Big Data Service Cluster
Now that you have the details for your cluster, you can run the steps found in 
[Create Big Data Service cluster on Oracle Cloud Infrastructure](../?create-bds-hadoop-cluster).

## Restore Your Backup to Your Big Data Service Cluster
Go to the [Restore Your Hadoop Cluster from Oracle Object Storage](../?restore-hadoop-cluster-object-store) tutorial to replicate the source cluster to your Big Data Service cluster.

