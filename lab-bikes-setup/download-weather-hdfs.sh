# documentation https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation
# Example API call for Central park
#https://www.ncei.noaa.gov/access/services/data/v1?dataset=daily-summaries&dataTypes=PRCP,SNOW,SNWD,TMAX,TMIN&stations=USW00094728&startDate=2019-01-01&endDate=2019-12-31&format=csv&units=standard 

# Lookup of postal code based on lat/lon
#http://maps.us.oracle.com/geocoder/xmlreq.html

. setup-workshop-env.sh

# List buckets
# oci os bucket list --compartment-id $COMPARTMENT_OCID --name cloudsqlworkshop
# Create Bucket
cd $TARGET_DIR
echo "Adding weather data"
echo "... find more info about data set here:  https://www.ncdc.noaa.gov/cdo-web/search?datasetid=GHCND"
echo "... download weather data"
curl -o "weather-central-park.csv" "https://www.ncei.noaa.gov/access/services/data/v1?dataset=daily-summaries&dataTypes=PRCP,SNOW,SNWD,TMAX,TMIN&stations=USW00094728&startDate=2019-01-01&endDate=2019-12-31&format=csv&units=standard"
echo "... remove header row"
sed -i 1d weather-central-park.csv

echo "... creating HDFS directory"
hadoop fs -mkdir -p /data/weather
echo "... upload file"
hadoop fs -put -f weather-central-park.csv /data/weather/

echo "... create hive table"
hive -e "
create database if not exists weather;
DROP TABLE IF EXISTS weather.weather_ext;


CREATE EXTERNAL TABLE weather_ext (
  station string,
  reported_date  string,
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
;"

