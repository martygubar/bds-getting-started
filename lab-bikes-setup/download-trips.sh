#!/bin/bash
# Download trips data and setup hive

. setup-workshop-env.sh

echo "Downloading TRIPS data from New York City’s Citi Bike bicycle sharing service"
echo "You can view the Citi Bike licensing information here:  https://www.citibikenyc.com/data-sharing-policy"
echo "... copying to $TARGET_DIR"  

echo "... directory listing prior to download:"
ls $TARGET_DIR

# download files from S3 and unzip

cd $TARGET_DIR
for file in $FILE_LIST 
do
   s3obj="https://s3.amazonaws.com/tripdata/$file"
   echo "... downloading $s3obj to $TARGET_DIR"
 #  wget --quiet --output-file setup-workshop-data.log -nc -c $s3obj -P $TARGET_DIR
   curl --remote-name --silent $s3obj 
   echo "... extracting $file to $TARGET_DIR"
   unzip -o $TARGET_DIR/$file -d $TARGET_DIR
done

echo "Directory listing AFTER download and extraction:"
ls $TARGET_DIR

echo "... Upload csv files to /data/biketrips"
hadoop fs -mkdir -p /data/biketrips
hadoop fs -chmod 777 /data/biketrips
hadoop fs -put -f $TARGET_DIR/JC-*.csv /data/biketrips/

echo "... create Hive tables in database BIKES"

hive -e "
create database if not exists bikes;
DROP TABLE IF EXISTS bikes.trips_ext;
DROP TABLE IF EXISTS bikes.trips;

CREATE EXTERNAL TABLE bikes.trips_ext (
  trip_duration int,
  start_time string,
  stop_time  string,
  start_station_id int,
  start_station_name string,
  start_station_latitude decimal(13,10),
  start_station_longitude decimal(13,10),
  end_station_id int,
  end_station_name string,
  end_station_latitude decimal(13,10),
  end_station_longitude decimal(13,10),
  bike_id int,
  user_type string,
  birth_year int,
  gender int	   
 ) 
  ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
  STORED AS TEXTFILE
  location '/data/biketrips/'
  tblproperties ('skip.header.line.count'='1');
  
create table bikes.trips ( 
  trip_duration int,
  start_time string,
  start_hour int,
  stop_time  string,
  start_station_id int,
  start_station_name string,
  start_station_latitude decimal(13,10),
  start_station_longitude decimal(13,10),
  end_station_id int,
  end_station_name string,
  end_station_latitude decimal(13,10),
  end_station_longitude decimal(13,10),
  bike_id int,
  user_type string,
  birth_year int,
  gender int	
)
PARTITIONED BY (start_month string)
STORED AS PARQUET  
;

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
FROM bikes.trips_ext t
INSERT OVERWRITE TABLE bikes.trips PARTITION(start_month) 
SELECT 
  trip_duration,
  start_time,
  substr(start_time, 12, 2),
  stop_time,
  start_station_id,
  start_station_name,
  start_station_latitude,
  start_station_longitude,
  end_station_id,
  end_station_name,
  end_station_latitude,
  end_station_longitude,
  bike_id,
  user_type,
  birth_year,
  gender,
  substr(start_time, 1, 7)
;"