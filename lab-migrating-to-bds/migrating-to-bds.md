# Migrating from Big Data Cloud Service to Big Data Service on Oracle Cloud Infrastructure

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

## Migration Scope
Migrating from BDCS to BDS on OCI is done in several steps:
* [Backup Your Hadoop Cluster to Oracle Object Storage](../bdr-to-objstore)
* [Create Big Data Service cluster on Oracle Cloud Infrastructure](../create-cluster)
* [Restore Your Hadoop Cluster from Oracle Object Storage](../bdr-to-hadoop)
