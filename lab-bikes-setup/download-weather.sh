# documentation https://www.ncei.noaa.gov/support/access-data-service-api-user-documentation
# Example API call for Central park
https://www.ncei.noaa.gov/access/services/data/v1?dataset=daily-summaries&dataTypes=PRCP,SNOW,SNWD,TMAX,TMIN&stations=USW00094728&startDate=2019-01-01&endDate=2019-12-31&format=csv&units=standard 

# Lookup of postal code based on lat/lon
http://maps.us.oracle.com/geocoder/xmlreq.html

. setup-env.sh
# List buckets
oci os bucket list --compartment-id $COMPARTMENT_OCID --name cloudsqlworkshop
# Create Bucket
oci os bucket create --compartment-id $COMPARTMENT_OCID --name $BUCKET_NAME
curl -sS -k -L --post302 -X GET "https://www.ncei.noaa.gov/access/services/data/v1?dataset=daily-summaries&dataTypes=PRCP,SNOW,SNWD,TMAX,TMIN&stations=USW00094728&startDate=2019-01-01&endDate=2019-12-31&format=csv&units=standard" | oci os object put --bucket-name $BUCKET_NAME --file -