# Lab Copy to Object Store
  ![](images/100/Title-100.png)

## Introduction

In this lab you will back up data in Oracle Big Data Cloud Service to Oracle Object Store.

## Lab 100 Objectives

- Use Zeppelin to report on data captured in Oracle Database 18c
- Learn how to seamlessly access data in Oracle Object Store from Oracle Database using Big Data SQL-enabled external tables.

## Steps

### **STEP 1:** Create a bucket in Oracle Object Store

* From your browser, Oracle Cloud Infrastructure:
  [http://localhost:8090/#/](http://localhost:8090/#/)

* Select Object Storage

* Create a bucket called `BDCS-MIGRATION`.  Use an UPPERCASE name; this is required for the Hadoop S3 connector to work.

### **STEP 2:** Create a Customer Secret Key

* Select **Identity >> Users >> User Details >> Customer Secret Keys**
* Click **Generate Secret Key**
* Name the secret key `migration-key`
* Save the secret key to a safe place.  It will not be shown again..
    * Access Key: `4d2002329319070bc8ba3eb9c4a487093bee5c17`
    * Secret Key: `CI/S4C16AJYAei7nxviRI1cQwZO4sSN0lAoUwVN6C1Q=`


### **STEP 3:** Configure Hadoop cluster to access Oracle Object Store
Oracle Object Store supports the S3 protocol.  In **Cloudera Manager**, update the **HDFS Safety Valve** in the HDFS Configuration with the Oracle Object Store configuration information to allow for access to the Oracle Object Store:

```xml
    <property>
      <name>fs.s3a.endpoint</name>
      <value>https://<tenancy_name>.compat.objectstorage.<home_region>.oraclecloud.com</value>
    </property>
    <property>
      <name>fs.s3a.secret.key</name>
      <value><SECRET_KEY></value>
    </property>
    <property>
      <name>fs.s3a.access.key</name>
      <value><ACCESS_KEY></value>
    </property>
    <property>
      <name>fs.s3a.path.style.access</name>
      <value>true</value>
    </property>
    <property>
      <name>fs.s3a.paging.maximum</name>
      <value>1000</value>
    </property>
```

PM CLuster Details:
* Tenancy:  `oraclebigdatadb`
* Endpoint: https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com
* Bucket:  `BDCS-MIGRATION`
* Access Key: `4d2002329319070bc8ba3eb9c4a487093bee5c17`
* Secret Key: `CI/S4C16AJYAei7nxviRI1cQwZO4sSN0lAoUwVN6C1Q=`
```xml
    <property>
      <name>fs.s3a.endpoint</name>
      <value>https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com</value>
    </property>
    <property>
      <name>fs.s3a.secret.key</name>
      <value>CI/S4C16AJYAei7nxviRI1cQwZO4sSN0lAoUwVN6C1Q=</value>
    </property>
    <property>
      <name>fs.s3a.access.key</name>
      <value>4d2002329319070bc8ba3eb9c4a487093bee5c17</value>
    </property>
    <property>
      <name>fs.s3a.path.style.access</name>
      <value>true</value>
    </property>
    <property>
      <name>fs.s3a.paging.maximum</name>
      <value>1000</value>
    </property>
```

### **STEP 4:** Use distcp to Copy Data to Oracle Object Store
Now that connectivity is established, copy data to the Oracle Object Store

    hadoop distcp /data s3a://BDCS-MIGRATION/

```sql
CREATE TABLE weather
( WEATHER_STATION_ID      VARCHAR2(20),
    WEATHER_STATION_NAME    VARCHAR2(100),
    REPORT_DATE             VARCHAR2(20),
    AVG_WIND                NUMBER,
    PRECIPITATION           NUMBER,
    SNOWFALL                NUMBER,
    SNOW_DEPTH              NUMBER,
    TEMP_AVG                NUMBER,
    TEMP_MAX                NUMBER
    ....
    )
ORGANIZATION EXTERNAL
(TYPE ORACLE_BIGDATA
DEFAULT DIRECTORY DEFAULT_DIR
ACCESS PARAMETERS
(
    com.oracle.bigdata.fileformat = textfile 
    com.oracle.bigdata.csv.skip.header=1
    com.oracle.bigdata.csv.rowformat.fields.terminator = '|'
)
location ('https://swiftobjectstorage.us-phoenix-1.oraclecloud.com/v1/adwc4pm/weather/*.csv')
)  
REJECT LIMIT UNLIMITED;
```
* To execute SQL in SQL Developer, place your cursor anywhere inside the `CREATE TABLE` statement.  Click the **Run Statement** button or hit **F9** to create the table.
    ![run command](images/100/run-cmd.png)

* Review the weather data with the following query:
```sql
select * from weather;
```
* How are bikes used in different kinds of weather?  Combine ridership data stored in Oracle Database with the weather data in object store.  Notice that the weather table is treated like any other table in a query.  Applications do not need to be concerned about the data location:
```sql
with rides_by_weather as (
select case 
    when w.temp_avg < 32 then '32 and below'
    when w.temp_avg between 32 and 50 then '32 to 50'
    when w.temp_avg between 51 and 75 then '51 to 75'
    else '75 and higher'
    end temp_range,            
    case
    when w.precipitation = 0 then 'clear skies'
    else 'rain or snow'
    end weather,
    r.num_trips num_trips, 
    r.passes_24hr_sold,
    r.passes_3day_sold 
from ridership r , weather w
where r.day = w.report_date
)
select temp_range,
    weather,
    round(avg(num_trips)) num_trips,
    round(avg(passes_24hr_sold)) passes_24hr,
    round(avg(passes_3day_sold)) passes_3day
from rides_by_weather
group by temp_range, weather
order by temp_range, weather;
```
## Summary
You just created an Oracle Big Data SQL table over data stored in Oracle Object Store and queried it as you would any other Oracle table.  This allows you to easily blend data across data sources to gain new insights.

**This completes the Lab!**

**You are ready to proceed to [Lab 200](LabGuide200.md)**
