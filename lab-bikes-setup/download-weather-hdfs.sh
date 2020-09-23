# Weather data is a randomized data set for Newark Liberty Airport in New Jersey

. env.sh

# List buckets
# oci os bucket list --compartment-id $COMPARTMENT_OCID --name cloudsqlworkshop
# Create Bucket
cd $TARGET_DIR
echo "Adding weather data"
echo "... download weather data"
curl -o "weather-newark-airport.csv" "https://raw.githubusercontent.com/martygubar/bds-getting-started/master/lab-bikes-setup/weather-newark-airport.csv"
echo "... remove header row"
sed -i 1d weather-newark-airport.csv

echo "... creating HDFS directory"
hadoop fs -mkdir -p $HDFS_ROOT/weather
echo "... upload file"
hadoop fs -put -f weather-newark-airport.csv /data/weather/

echo "... create hive table"
hive -e "
create database if not exists weather;
DROP TABLE IF EXISTS weather.weather_ext;


CREATE EXTERNAL TABLE weather.weather_ext (
  location string,
  reported_date  string,
  wind_avg float,
  precipitation float,
  snow float,
  snowdepth float,
  temp_max smallint,
  temp_min smallint    
 ) 
  ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ','
  STORED AS TEXTFILE
  location '/data/weather/';
;"

