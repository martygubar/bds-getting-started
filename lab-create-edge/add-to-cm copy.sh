#!/bin/bash

call_cm ()
{
    export http_proxy="";
    log=/tmp/call_cm_`echo $3| sed 's/[\/?=]/_/g'`_`date +%s`;
    /usr/bin/curl -k -L --post302 -X $1 -H "Content-Type:application/json" -u $CM_ADMIN:secureadmin9 -d @- "http://scaj31bda03.us.oracle.com:7180/api/v11/$3" > $log.out 2> $log.err  <<
EOF
$2
EOF

    if [ -e $log.out -a -s $log.out ]; then
        cat $log.out;
        echo;
    else
        cat $log.err;
    fi
}


# Wait for Cloudera Manager
wait_for_cm
if [ $? -ne 0 ]; then
  exit 1
fi

# Sleeping for Cloudera Manager to initialize after starting
sleep 30;

# Enable API debugging
call_cm json PUT '{ "items": [ { "name": "ENABLE_API_DEBUG", "value": "true" } ] }' cm/config
if [ $? -ne 0 ]; then exit 1; fi


# Add hosts to cluster
call_cm json POST \
'{ "items" : [
<% idx = 0 -%>
<% if !@addl_rack_install -%>
<% @all_nodes.each do |cur_node| -%>
<% if idx > 0 -%>,<% end -%>
 "<%= @all_nodes[idx]%>"
<% idx = idx + 1 -%>
<% end -%>
<% else -%>
<% @addl_rack_nodes.each do |cur_node| -%>
<% if idx > 0 -%>,<% end -%>
 "<%= @addl_rack_nodes[idx]%>"
<% idx = idx + 1 -%>
<% end -%>
<% end -%>
] }' \
clusters/<%=@cluster_name%>/hosts
if [ $? -ne 0 ]; then
  if [[ ! "$causes" =~ "org.hibernate.exception.ConstraintViolationException" ]] &&  [[ ! "$message" =~ "already belongs to" ]]; then
    exit 1
  fi
fi

# Obtain cdh parcel version
for i in $(seq 1 30)
do
  call_cm json GET {} clusters/<%=@cluster_name%>/parcels
  #if [ $? -ne 0 ]; then exit 1; fi
  cp $logdir/$logname.out $logdir/parcel_info.out
  #parcel_ver=`<%=@selectjs_cmd%> --jpx="items?s(product:\"CDH\")/version" $logdir/parcel_info.out`
  #parcel_ver=`<%=@selectjs_cmd%> --jpx="items?s(product:\"CDH\")?s(stage:^\"UNAVAILABLE\")/version/,[1]" --sort-els-desc $logdir/parcel_info.out`
  parcel_ver_list=`<%=@selectjs_cmd%> --jpx="items?s(product:\"CDH\")?s(stage:^\"UNAVAILABLE\")/version" $logdir/parcel_info.out `
  parcel_ver=`for ver in $parcel_ver_list ; do echo $ver ; done | awk -F"[.-]+" '{printf "%0.3d.%0.3d.%0.3d.%0.3d\t%s\n", $1, $2, $3, $4, $x}' | sort | tail -n 1 | awk '{print $2}' `

  if [ $i -eq 30 ]; then
    /bin/echo "Could not obtain CDH parcel version"
    exit 1
  elif [ "$parcel_ver" = "" ]; then
    /bin/sleep 10
  else
    break
  fi
done

# Download CDH parcel
call_cm json POST '' clusters/<%=@cluster_name%>/parcels/products/CDH/versions/$parcel_ver/commands/startDownload
if [ $? -ne 0 ]; then exit 1; fi
/bin/sleep 30
# Ensure download completed. (No cmdid to track)
for i in $(seq 1 90)
do
  call_cm json GET {} clusters/<%=@cluster_name%>/parcels/products/CDH/versions/$parcel_ver
  downloadstat=`<%=@selectjs_cmd%> --jpx="stage" $logdir/$logname.out`
  if [ "$downloadstat" = "DOWNLOADED" ]; then
    curdat=`date`
    /bin/echo -e "\nParcel download finished after $((10*$i)) seconds, Current date $curdat"
    break
  elif [ "$downloadstat" != "DOWNLOADING" ]; then
    if [ "$downloadstat" == "DISTRIBUTING" ] || [ "$downloadstat" == "DISTRIBUTED" ]; then
      curdat=`date`
      /bin/echo -e "\nParcel is $downloadstat after $((10*$i)) seconds. Skipping Download, Current date $curdat"
      break
    elif [ "$downloadstat" == "ACTIVATING" ] || [ "$downloadstat" == "ACTIVATED" ]; then
      curdat=`date`
      /bin/echo -e "\nParcel is $downloadstat after $((10*$i)) seconds. Skipping Download, Current date $curdat"
      break
    else
      /bin/echo -e "\nCould not perform parcel download properly after $((10*$i)) seconds."
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

# Distribute CDH parcel
call_cm json POST '' clusters/<%=@cluster_name%>/parcels/products/CDH/versions/$parcel_ver/commands/startDistribution
if [ $? -ne 0 ]; then exit 1; fi
/bin/sleep 120
# Ensure distrubution completed. (No cmdid to track)
for i in $(seq 1 180)
do
  call_cm json GET {} clusters/<%=@cluster_name%>/parcels/products/CDH/versions/$parcel_ver
  distributestat=`<%=@selectjs_cmd%> --jpx="stage" $logdir/$logname.out`
  if [ "$distributestat" = "DISTRIBUTED" ]; then
    curdat=`date`
    /bin/echo -e "\nParcel distribution finished after $((10*$i)) seconds, Current date $curdat"
    break
  elif [ "$distributestat" != "DISTRIBUTING" ]; then
    if [ "$distributestat" == "ACTIVATING" ] || [ "$distributestat" == "ACTIVATED" ]; then
      curdat=`date`
      /bin/echo -e "\nParcel is $distributestat after $((10*$i)) seconds. Skipping Distribution, Current date $curdat"
      break
    else
      /bin/echo -e "\nCould not perform parcel distribution properly after $((10*$i)) seconds."
      cat $logdir/$logname.out
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

# Activate CDH parcel
call_cm json POST '' clusters/<%=@cluster_name%>/parcels/products/CDH/versions/$parcel_ver/commands/activate
if [ $? -ne 0 ]; then exit 1; fi
/bin/sleep 30
# Check activation status. (No cmdid to track)
for i in $(seq 1 120)
do
  call_cm json GET {} clusters/<%=@cluster_name%>/parcels/products/CDH/versions/$parcel_ver
  activatestat=`<%=@selectjs_cmd%> --jpx="stage" $logdir/$logname.out`
  if [ "$activatestat" = "ACTIVATED" ]; then
    curdat=`date`
    /bin/echo -e "\nParcel activation finished after $((5*$i)) seconds, Current date $curdat"
    break
  elif [ "$activatestat" != "ACTIVATING" ]; then
    /bin/echo -e "\nCould not perform parcel activation properly after $((5*$i)) seconds."
    cat $logdir/$logname.out
    exit 1
  fi
  echo -n .
  if [ $i -eq 120 ]; then
    /bin/echo "Parcel activation timed out."
    exit 1
  fi
  /bin/sleep 5
done

########################################################################################
#				SERVICES
########################################################################################


# Create Services
<% if !@addl_rack_install -%>
call_cm json POST \
'{ "items" : [
{ "name": "hdfs", "type": "HDFS" },
{ "name": "zookeeper", "type": "ZOOKEEPER" },
{ "name": "yarn", "type": "YARN" },
{ "name": "oozie", "type": "OOZIE" },
{ "name": "hive", "type": "HIVE" },
{ "name": "hue", "type": "HUE" }
] }' \
clusters/<%=@cluster_name%>/services
if [ $? -ne 0 ]; then
  if [[ ! "$causes" =~ "Duplicate entry" ]] && [[ ! "$message" =~ "Maximum instance" ]] ; then
    exit 1
  fi
fi

<% if !@isupgrade -%>
call_cm json PUT '{"name":"<%=@mgmt_service%>"}' cm/service
if [ $? -ne 0 ]; then
  if [[ ! "$message" =~ "CMS instance already exists" ]] ; then
    exit 1
  fi
fi
<% end -%>
<% end -%>

########################################################################################
#				ROLES
########################################################################################

# add hive gateway roles to all cluster nodes
<% @all_nodes.each do |cur_node| -%>
call_cm json POST \
'{ "items": [
{ "name": null, "type": "GATEWAY", "hostRef": { "hostId": "<%=cur_node%>" } }
] }' \
clusters/<%=@cluster_name%>/services/hive/roles
if [ $? -ne 0 ]; then
  if [[ ! "$message" =~ "The maximum number of instances" ]] &&  [[ ! "$message" =~ "Duplicate role name" ]]; then
    exit 1
  fi
fi
<% end -%>

# add yarn gateway roles to all cluster nodes
<% @all_nodes.each do |cur_node| -%>
call_cm json POST \
'{ "items": [
{ "name": null, "type": "GATEWAY", "hostRef": { "hostId": "<%=cur_node%>" } }
] }' \
clusters/<%=@cluster_name%>/services/yarn/roles
if [ $? -ne 0 ]; then
  if [[ ! "$message" =~ "The maximum number of instances" ]] &&  [[ ! "$message" =~ "Duplicate role name" ]]; then
    exit 1
  fi
fi
<% end -%>

# add HDFS gateway roles to all edge nodes
<% @edge_nodes.each do |cur_node| -%>
call_cm json POST \
'{ "items": [
{ "name": null, "type": "GATEWAY", "hostRef": { "hostId": "<%=cur_node%>" } }
] }' \
clusters/<%=@cluster_name%>/services/hdfs/roles
if [ $? -ne 0 ]; then
  if [[ ! "$message" =~ "The maximum number of instances" ]] &&  [[ ! "$message" =~ "Duplicate role name" ]]; then
    exit 1
  fi
fi
<% end -%>

exit 0

