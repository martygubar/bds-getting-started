#!/bin/bash

. env.sh

echo "$(date +"%T") add host to Cloudera Manager and deploy parcels"

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

echo "....$(date +"%T") Running CDH Version:  $cdhVersion"

####################
# download parcel
####################

# Download CDH parcel
call-cm downloading POST clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion/commands/startDownload

if [ $? -ne 0 ]; then 
  echo "$(date +"%T") ERROR:  Unable to download parcel."
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
    echo -e "....$(date +"%T") Parcel download finished after $((10*$i)) seconds"
    break
  elif [ "$downloadstat" != "DOWNLOADING" ]; then
    if [ "$downloadstat" == "DISTRIBUTING" ] || [ "$downloadstat" == "DISTRIBUTED" ]; then
      curdat=`date`
      echo -e "....$(date +"%T") Parcel is $downloadstat after $((10*$i)) seconds. Skipping Download"
      break
    elif [ "$downloadstat" == "ACTIVATING" ] || [ "$downloadstat" == "ACTIVATED" ]; then
      curdat=`date`
      echo -e "$(date +"%T") Parcel is $downloadstat after $((10*$i)) seconds. Skipping Download"
      break
    else
      echo -e "$(date +"%T") Could not perform parcel download properly after $((10*$i)) seconds."
      exit 1
    fi
  fi
  echo -n .
  if [ $i -eq 90 ]; then
    /bin/echo "$(date +"%T") Parcel download timed out."
    exit 1
  fi
  /bin/sleep 10
done

#########################
# Distribute Parcel
#########################

# Distribute CDH parcel
echo "$(date +"%T") starting parcel deployment to edge"
echo "...$(date +"%T") distributing parcel"
call-cm distributing POST clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion/commands/startDistribution

if [ $? -ne 0 ]; then 
  echo "$(date +"%T") ERROR:  Unable to distribute parcel."
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
    echo -e ".....$(date +"%T") parcel distribution finished after $((10*$i)) seconds"
    break
  elif [ "$distributestat" != "DISTRIBUTING" ]; then
    if [ "$distributestat" == "ACTIVATING" ] || [ "$distributestat" == "ACTIVATED" ]; then
      curdat=`date`
      echo -e "...$(date +"%T") parcel is $distributestat after $((10*$i)) seconds. Skipping Distribution"
      break
    else
      echo -e "$(date +"%T") Could not perform parcel distribution properly after $((10*$i)) seconds."
      exit 1
    fi
  fi
  echo -n .
  if [ $i -eq 180 ]; then
    /bin/echo "$(date +"%T") Parcel distribution timed out."
    exit 1
  fi
  /bin/sleep 10
done

########################
# Activate Parcel
########################
echo "...$(date +"%T") activating parcel"
call-cm activating POST clusters/$CLUSTER/parcels/products/CDH/versions/$cdhVersion/commands/activate

if [ $? -ne 0 ]; then 
  echo "$(date +"%T") ERROR:  Unable to activate parcel."
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
    echo -e "...$(date +"%T") parcel activation finished after $((5*$i)) seconds"
    break
  elif [ "$activatestat" != "ACTIVATING" ]; then
    echo -e "$(date +"%T") Could not perform parcel activation properly after $((5*$i)) seconds."
    exit 1
  fi
  echo -n .
  if [ $i -eq 120 ]; then
    echo "$(date +"%T") Parcel activation timed out."
    exit 1
  fi
done
echo "$(date +"%T") end parcel deployment"

###############################
#  Add gateway roles to edge
###############################
echo "$(date +"%T") begin gateway role deployment"
# Get the hostId.  Needed for deploying gateway roles
call-cm allHosts GET clusters/$CLUSTER/hosts

host=`echo $allHosts | jq --arg EDGE_FQDN "$EDGE_FQDN" '.items[] | select(.hostname==$EDGE_FQDN)'`
hostId=`echo $host | jq -r '.hostId'` 

for role in hive spark_on_yarn yarn hdfs
do
    echo "...$(date +"%T") add $role gateway to edge node."
    call-cm gateway POST clusters/$CLUSTER/services/$role/roles \
    "{ \"items\": [
    { \"name\": null, \"type\": \"GATEWAY\", \"hostRef\": { \"hostId\": \"$hostId\" } }
    ] }" 

    if [ $? -ne 0 ]; then
        echo "$(date +"%T") Error assigning $role Gateway to edge node."
        echo $gateway
    fi

done
echo "$(date +"%T") end gateway role deployment"

#################################
# Deploy client configurations
#################################
echo "$(date +"%T") begin client configuration deployment"
call-cm deployConfig POST clusters/$CLUSTER/commands/deployClientConfig
echo $deployConfig
echo "$(date +"%T") end client configuration deployment"

exit 0