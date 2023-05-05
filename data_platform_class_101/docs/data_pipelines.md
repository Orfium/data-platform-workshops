# Snowflake Data Pipeline
Login to [Orfium’s Snowflake Testing Account](https://stb70715.us-east-1.snowflakecomputing.com/oauth/authorize?client_id=3kwdvnjpUzxU6sqlkOoknyZ30jLvtA%3D%3D&display=popup&redirect_uri=https%3A%2F%2Fapps-api.c1.us-east-1.aws.app.snowflake.com%2Fcomplete-oauth%2Fsnowflake&response_type=code&scope=refresh_token&state=%7B%22browserUrl%22%3A%22https%3A%2F%2Fapp.snowflake.com%2Fus-east-1%2Fstb70715%2Fworksheets%22%2C%22csrf%22%3A%22a1c86c30%22%2C%22isSecondaryUser%22%3Afalse%2C%22oauthNonce%22%3A%2246K8jpNtDWO%22%2C%22url%22%3A%22https%3A%2F%2Fstb70715.us-east-1.snowflakecomputing.com%22%7D)
and open a new worksheet and set it to use your `dev` role and your newly created warehouse.

## Create Stage 
```sql
-- CREATE A STAGE IN YOUR RAW SCHEMA FOR STAGING
SHOW INTEGRATIONS;
DESCRIBE INTEGRATION STG_DATA_PLATFORM_101_WORKSHOP;

CREATE OR REPLACE STAGE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/orders/';


```

## Raw Table Definition
```sql
CREATE or REPLACE TRANSIENT TABLE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS (
    ID NUMBER(38,0),
    USER_ID NUMBER(38,0),
    ORDER_DATE DATE,
    STATUS VARCHAR(25)
);

```

## Copy Into Table
```sql
COPY INTO DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS
FROM @DB_DATA_PRODUCTS.GIANNIS_DAAP_RAW.ORDERS_STAGE/initial_orders.csv.gz
FILE_FORMAT= (type='csv', skip_header=1);

SELECT * FROM DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.ORDERS limit 100;
```

## Create external Table
```sql
CREATE OR REPLACE STAGE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE  
STORAGE_INTEGRATION = STG_DATA_PLATFORM_101_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_data_platform_101/payments/';

CREATE OR REPLACE EXTERNAL TABLE DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS
LOCATION=@DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS_STAGE/
PATTERN = '.*payments.*'
FILE_FORMAT= (type='csv', skip_header=1)
AUTO_REFRESH = true;
```

### Monitor External Table
```sql
SHOW EXTERNAL TABLES;
SELECT value AS json_value from DB_ORFIUM_STAGING_TESTING.GIANNIS_DAAP_RAW.PAYMENTS limit 10;
```
