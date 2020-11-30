# Weather data is a randomized data set for Newark Liberty Airport in New Jersey

. env.sh

# List buckets
# oci os bucket list --compartment-id $COMPARTMENT_OCID --name cloudsqlworkshop
# Create Bucket
cd $TARGET_DIR
echo "Adding weather data for Newark Airport"
echo "... download weather data"
curl -o "weather-newark-airport.csv" "https://objectstorage.us-ashburn-1.oraclecloud.com/p/w2Hu5LewkIuEhbl0-G9xK61WOMg0rVmm0H3pwn7NR6Arr8T_O1zapUgd1nI_8Rt6/n/c4u03/b/data-management-library-files/o/Getting%20Started%20with%20Oracle%20Big%20Data%20Service%20(non-HA)/weather-newark-airport.csv"

echo "... remove header row"
sed -i 1d weather-newark-airport.csv

echo "... creating HDFS directory"
hadoop fs -mkdir -p $HDFS_ROOT/weather
echo "... upload file"
hadoop fs -put -f weather-newark-airport.csv $HDFS_ROOT/weather/

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

echo "Weather data loaded."