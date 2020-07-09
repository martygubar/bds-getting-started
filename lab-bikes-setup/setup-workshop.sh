#!/bin/bash

# Scripts to setup the Cloud SQL Workshop Lab

echo "This script sets up the environment for the Cloud SQL workshop lab."
echo "It must be run from OCI Cloud Shell (or an environment with the OCI CLI installed."
echo "If running from a Kerberized environment, make sure you have a Kerberos ticket prior to running this script."

. setup-workshop-env.sh

./download-weather.sh
./download-trips.sh
./download-stations.sh

