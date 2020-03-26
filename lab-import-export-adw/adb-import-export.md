# Importing and Exporting Data with Autonomous Database

## Before You Begin

Big Data Service is part of a larger Oracle data platform.  One of the most important parts of that platform is Oracle Autonous Database.  Autonomous Data Warehouse (ADW) is a fully managed
database tuned and optimized for data warehouse
workloads with the market-leading performance of
Oracle Database.  In this tutorial, you will learn how to move data between Big Data Service and ADW.  This is important as you will often use Big Data Service for data loading and transformations - as well as for data science activities.  You will want to push this data to ADW in order to make that information available to a wide breadth of users for reporting and further analysis.  Additionally, you may want to copy transactions from the database to Hadoop to enable analytics using open source data science tools.

In this tutorial, you will:
* Add a Kerberos user
* Create an admin Linux OS group
* Add a user to the Linux OS
* Add this new user to Hadoop admin groups

### Requirements

To complete this lab, you need to have the following:

* Created a Hadoop Cluster
* Set up access to the cluster using either a bastion (see [Create a Bastion to Access Your Cluster](?lab=create-bastion-access-cluster)) or a public IP address (see [Access a BDS Node Using a Public IP
](?lab=access-bds-utility-node-using-public-ip))



