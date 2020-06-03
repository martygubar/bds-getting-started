#!/bin/bash

. env.sh


function call-cm() {
# echo -e $4
    local _resultvar=$1
    local myresult=`curl -sS -k -L --post302 -X $2 -H "Content-Type:application/json" -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD -d "$4" "https://$CM_IP:7183/api/v32/$3"`
    #retval=`curl -sS -k -L --post302 -X $2 -H "Content-Type:application/json" -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD -d @- "https://$CM_IP:7183/api/v32/$3"`
    eval $_resultvar="'$myresult'"
    #echo $retval
}
# get hosts
# call-cm GET clusters/$CLUSTER/hosts ""

# add host
#PRIVATE_KEY_STR=$(cat $PRIVATE_KEY | tr -d '\n')

# Get the CDH Parcel information for the currently activated CDH version
# This parcel will then be distributed to the edge node.
call-cm parcelInfo GET clusters/$CLUSTER/parcels
cdhParcel=`echo $parcelInfo | jq '.items[] | select(.product=="CDH" and .stage=="ACTIVATED")'`
cdhVersion=`echo $cdhParcel | jq -r '.version'` 

echo "Running CDH Version:  $cdhVersion"

####################
# download parcel
####################

# Download CDH parcel
call-cm downloading POST clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion/commands/startDownload

if [ $? -ne 0 ]; then 
  echo "ERROR:  Unable to download parcel."
  echo $downloading
  exit 1; 
fi

# Ensure download completed. (No cmdid to track)
for i in $(seq 1 90)
do
  call-cm downloadstat GET clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion
  downloadstat=`echo $downloadstat | jq -r '.stage'` 
  if [ "$downloadstat" = "DOWNLOADED" ]; then
    curdat=`date`
    echo -e "\nParcel download finished after $((10*$i)) seconds, Current date $curdat"
    break
  elif [ "$downloadstat" != "DOWNLOADING" ]; then
    if [ "$downloadstat" == "DISTRIBUTING" ] || [ "$downloadstat" == "DISTRIBUTED" ]; then
      curdat=`date`
      echo -e "\nParcel is $downloadstat after $((10*$i)) seconds. Skipping Download, Current date $curdat"
      break
    elif [ "$downloadstat" == "ACTIVATING" ] || [ "$downloadstat" == "ACTIVATED" ]; then
      curdat=`date`
      echo -e "\nParcel is $downloadstat after $((10*$i)) seconds. Skipping Download, Current date $curdat"
      break
    else
      echo -e "\nCould not perform parcel download properly after $((10*$i)) seconds."
      cat $logdir/$logname.out
      exit 1
    fi
  fi
  echo -n .
  if [ $i -eq 90 ]; then
    /bin/echo "Parcel download timed out."
    exit 1
  fi
  /bin/sleep 10
done

#########################
# Distribute Parcel
#########################

# Distribute CDH parcel
echo "starting parcel deployment to edge"
echo "...distributing parcel"
call-cm distributing POST clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion/commands/startDistribution

if [ $? -ne 0 ]; then 
  echo "ERROR:  Unable to distribute parcel."
  echo $distributing
  exit 1; 
fi

# Ensure distrubution completed. (No cmdid to track)
for i in $(seq 1 180)
do
  call-cm distributestat GET clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion
  
  distributestat=`echo $distributestat | jq -r '.stage'`
  
  if [ "$distributestat" = "DISTRIBUTED" ]; then
    curdat=`date`
    echo -e ".....parcel distribution finished after $((10*$i)) seconds, Current date $curdat"
    break
  elif [ "$distributestat" != "DISTRIBUTING" ]; then
    if [ "$distributestat" == "ACTIVATING" ] || [ "$distributestat" == "ACTIVATED" ]; then
      curdat=`date`
      echo -e "....parcel is $distributestat after $((10*$i)) seconds. Skipping Distribution, Current date $curdat"
      break
    else
      echo -e "\nCould not perform parcel distribution properly after $((10*$i)) seconds."
      exit 1
    fi
  fi
  echo -n .
  if [ $i -eq 180 ]; then
    /bin/echo "Parcel distribution timed out."
    exit 1
  fi
  /bin/sleep 10
done

########################
# Activate Parcel
########################
echo "...activating parcel"
call-cm activating POST clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion/commands/activate

if [ $? -ne 0 ]; then 
  echo "ERROR:  Unable to activate parcel."
  echo $activating
  exit 1; 
fi

# Check activation status. (No cmdid to track)
for i in $(seq 1 120)
do
  call-cm activatestat GET clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion
  activatestat=`echo $activatestat | jq -r '.stage'`
  
  if [ "$activatestat" = "ACTIVATED" ]; then
    curdat=`date`
    echo -e "...parcel activation finished after $((5*$i)) seconds, Current date $curdat"
    break
  elif [ "$activatestat" != "ACTIVATING" ]; then
    echo -e "\nCould not perform parcel activation properly after $((5*$i)) seconds."
    exit 1
  fi
  echo -n .
  if [ $i -eq 120 ]; then
    echo "Parcel activation timed out."
    exit 1
  fi
done
echo "end parcel deployment"

###############################
#  Add gateway roles to edge
###############################
echo "begin gateway role deployment"
# Get the hostId.  Needed for deploying gateway roles
call-cm allHosts GET clusters/$CLUSTER/hosts

host=`echo $allHosts | jq --arg EDGE_FQDN "$EDGE_FQDN" '.items[] | select(.hostname==$EDGE_FQDN)'`
hostId=`echo $host | jq -r '.hostId'` 

for role in hive spark_on_yarn yarn hdfs
do
    echo "...add $role gateway to edge node."
    call-cm gateway POST clusters/$CLUSTER/services/$role/roles \
    "{ \"items\": [
    { \"name\": null, \"type\": \"GATEWAY\", \"hostRef\": { \"hostId\": \"$hostId\" } }
    ] }" 

    if [ $? -ne 0 ]; then
        echo "Error assigning $role Gateway to edge node."
        echo $gateway
    fi

done
echo "end gateway role deployment"

#################################
# Deploy client configurations
#################################
echo "begin client configuration deployment"
call-cm deployConfig POST clusters/$CLUSTER/commands/deployClientConfig
echo $deployConfig
echo "end client configuration deployment"