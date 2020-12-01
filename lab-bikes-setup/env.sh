#!/bin/bash
# Setup environment for data used for workshop

# Object Store:  ocid for the compartment.
export COMPARTMENT_OCID=""

# Object Store:  Bucket where data will be copied
export BUCKET_NAME="training"

# HDFS:  root directory in HDFS for the data
export HDFS_ROOT="/data"

# HDFS:  local target directory where files will be downloaded
export TARGET_DIR="$HOME/Downloads"

# Object store source prefix
export SOURCE_PREFIX="https://objectstorage.us-phoenix-1.oraclecloud.com/n/oraclebigdatadb/b/workshop-data/o/bds-livelabs"