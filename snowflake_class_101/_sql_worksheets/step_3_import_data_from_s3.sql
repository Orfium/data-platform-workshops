USE ROLE R_SAMPLE_MASTER;
USE WAREHOUSE WH_SAMPLE;

-- Monitor your Integration
SHOW INTEGRATIONS;
DESCRIBE INTEGRATION STG_GENERIC_WORKSHOP;

-- Create Stage with your bucket filepath definition.
CREATE OR REPLACE STAGE DB_DATA_PRODUCTS.SAMPLE.SAMPLE_STAGE
STORAGE_INTEGRATION = STG_GENERIC_WORKSHOP
url = 's3://orfium-data-de-dev/workshop_daap_in_snowflake/tpch_sf10/';

-- Create the table that will be ingested with your data from S3
CREATE or REPLACE TRANSIENT TABLE DB_DATA_PRODUCTS.SAMPLE.LINEITEM (
	L_ORDERKEY NUMBER(38,0),
	L_PARTKEY NUMBER(38,0),
	L_SUPPKEY NUMBER(38,0),
	L_LINENUMBER NUMBER(38,0),
	L_QUANTITY NUMBER(12,2),
	L_EXTENDEDPRICE NUMBER(12,2),
	L_DISCOUNT NUMBER(12,2),
	L_TAX NUMBER(12,2),
	L_RETURNFLAG VARCHAR(1),
	L_LINESTATUS VARCHAR(1),
	L_SHIPDATE DATE,
	L_COMMITDATE DATE,
	L_RECEIPTDATE DATE,
	L_SHIPINSTRUCT VARCHAR(25),
	L_SHIPMODE VARCHAR(10),
	L_COMMENT VARCHAR(44)
);

-- Use COPY INTO operation to load yhe data from a specific table
COPY INTO DB_DATA_PRODUCTS.SAMPLE.LINEITEM
FROM @DB_DATA_PRODUCTS.SAMPLE.SAMPLE_STAGE/lineitem_10000.csv.gz
FILE_FORMAT= (type='csv', skip_header=1);

-- Create Non-Standardized External Table
CREATE OR REPLACE EXTERNAL TABLE DB_DATA_PRODUCTS.SAMPLE.ORDERS_NO_STD
LOCATION=@DB_DATA_PRODUCTS.SAMPLE.SAMPLE_STAGE
PATTERN = '.*orders.*'
FILE_FORMAT = (type='csv', skip_header=1)
AUTO_REFRESH = true;

SELECT value AS json_value FROM DB_DATA_PRODUCTS.SAMPLE.ORDERS limit 100;

CREATE OR REPLACE EXTERNAL TABLE DB_DATA_PRODUCTS.SAMPLE.ORDERS
(
    O_ORDERKEY NUMBER(38,0) AS (value:c1::NUMBER(38,0)),
    O_CUSTKEY NUMBER(38,0) AS (value:c2::NUMBER(38,0)),
    O_ORDERSTATUS VARCHAR(1) AS (value:c3::VARCHAR(1)),
    O_TOTALPRICE NUMBER(12,2) AS (value:c4::NUMBER(12,2)),
    O_ORDERDATE DATE AS (value:c5::DATE),
    O_ORDERPRIORITY VARCHAR(15) AS (value:c6::VARCHAR(15)),
    O_CLERK VARCHAR(15) AS (value:c7::VARCHAR(15)),
    O_SHIPPRIORITY NUMBER(38,0) AS (value:c8::NUMBER(38,0)),
    O_COMMENT VARCHAR(2048) AS (value:c9::VARCHAR(2048))

)
LOCATION=@DB_DATA_PRODUCTS.SAMPLE.SAMPLE_STAGE
PATTERN = '.*orders.*'
FILE_FORMAT = (type='csv', skip_header=1)
AUTO_REFRESH = true;

SELECT * FROM DB_DATA_PRODUCTS.SAMPLE.ORDERS limit 100;