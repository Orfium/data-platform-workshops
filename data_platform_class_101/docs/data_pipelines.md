# Snowflake Data Pipeline
## Enable your programmatic users.
### Enable Production Programmatic User
1. Go to [Orfium’s Snowflake Testing Account](https://stb70715.us-east-1.snowflakecomputing.com/oauth/authorize?client_id=3kwdvnjpUzxU6sqlkOoknyZ30jLvtA%3D%3D&display=popup&redirect_uri=https%3A%2F%2Fapps-api.c1.us-east-1.aws.app.snowflake.com%2Fcomplete-oauth%2Fsnowflake&response_type=code&scope=refresh_token&state=%7B%22browserUrl%22%3A%22https%3A%2F%2Fapp.snowflake.com%2Fus-east-1%2Fstb70715%2Fworksheets%22%2C%22csrf%22%3A%22a1c86c30%22%2C%22isSecondaryUser%22%3Afalse%2C%22oauthNonce%22%3A%2246K8jpNtDWO%22%2C%22url%22%3A%22https%3A%2F%2Fstb70715.us-east-1.snowflakecomputing.com%22%7D)
2. Fill the username, which match your Data Product in lowercase and underscores. (e.g giannis_daap)
3. Fill the default password `Snowfl@keT3mpPass12` 
4. Change password with the new one. 

 > Replace GIANNIS_DAAP references with your respective naming for your resources.

## Create Stage 
Create a Stage using an already existing storage integration called `STG_DATA_PLATFORM_101_WORKSHOP` with access on
the `s3://orfium-data-de-dev/`.

```sql
-- CREATE A STAGE IN YOUR RAW SCHEMA FOR STAGING
SHOW INTEGRATIONS;
DESCRIBE INTEGRATION STG_DATA_PLATFORM_101_WORKSHOP;

CREATE OR REPLACE STAGE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/orders/';
```

## Raw Table Definition
Define a simple table that will be populated later using `COPY INTO` command
```sql
CREATE or REPLACE TRANSIENT TABLE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_NO_TRANSFORM (
    ID NUMBER(38,0),
    USER_ID NUMBER(38,0),
    ORDER_DATE DATE,
    STATUS VARCHAR(25)
);

CREATE or REPLACE TRANSIENT TABLE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS (
    ID NUMBER(38,0),
    USER_ID NUMBER(38,0),
    ORDER_DATE DATE,
    STATUS VARCHAR(25),
    ORDER_YEAR VARCHAR(10),
    ORDER_MONTH VARCHAR(2)
);

```

## Copy Into Table
Use `COPY INTO` command to populate the previously created table, **without** any extra transformations
```sql
COPY INTO DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_NO_TRANSFORM
FROM @DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_STAGE/initial_orders.csv.gz
FILE_FORMAT= (type='csv', skip_header=1);

SELECT * FROM DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS limit 100;
```

Use `COPY INTO` command to populate the previously created table, **with** transformation
```sql
    
COPY INTO DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
FROM
    (
        SELECT
            t.$1 AS ID,
            t.$2 AS USER_ID,
            t.$3 AS ORDER_DATE,
            t.$4 AS STATUS,
            substr(split_part(metadata$filename, '/', 3), 6) AS ORDER_YEAR,
            substr(split_part(metadata$filename, '/', 4), 7) AS ORDER_MONTH
        FROM
            @DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_STAGE as t
    ) 
    PATTERN = 'year=2018/.*'
    FILE_FORMAT = (type = 'csv', skip_header = 1);

SELECT * FROM DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS limit 100;
```


## Create external Table
Create an external table by creating a new stage using the same Storage Integration
```sql
CREATE OR REPLACE STAGE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/payments/';

CREATE OR REPLACE EXTERNAL TABLE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_NO_MAPPING
LOCATION=@DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE/
PATTERN = '.*payments.*'
FILE_FORMAT= (type='csv', skip_header=1)
AUTO_REFRESH = true;
```

### Monitor External Table
Quering over the External Table to monitor the the returned values and their format.
```sql
SHOW EXTERNAL TABLES;
SELECT value AS json_value from DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS limit 10;
```
Transforming query to output a more structured format 
```sql
SELECT
      JSON_VALUE:c1::NUMBER(38,0) AS ID,
      JSON_VALUE:c2::NUMBER(38,0)AS ORDER_ID,
      JSON_VALUE:c3::VARCHAR(64) AS PAYMENT_METHOD,
      JSON_VALUE:c4::NUMBER(38,0) AS AMOUNT
FROM (SELECT VALUE AS JSON_VALUE FROM DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_NO_MAPPING),
  LATERAL FLATTEN(INPUT => PARSE_JSON(JSON_VALUE))
```
