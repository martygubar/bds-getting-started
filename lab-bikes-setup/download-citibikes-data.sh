#!/bin/bash

targetdir=$PWD
# download 2019 data from S3 and unzip

for month in 01 02 03 04 05 06 07 08 09 10 11 12 
do
   file="JC-2019${month}-citibike-tripdata.csv.zip"
   s3obj="https://s3.amazonaws.com/tripdata/$file"
   echo "downloading $s3obj to $targetdir...."
   wget -nc -c $s3obj -P $targetdir
   echo "extracting $file to $targetdir/"
   unzip $targetdir/$file -d $targetdir/
done

echo "Upload csv files to /data/bikes"
hadoop fs -mkdir -p /data/bikes
hadoop fs -chmod 777 /data/bikes
hadoop fs -put $targetdir/*.csv /data/bikes/

echo "Create Hive table"

hive -e "
create database if not exists bikes;
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
  location '/data/bikes/'
  tblproperties ("skip.header.line.count"="1");
  
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
;
;'

