# Operate on Snowflake resources

## Guidelines
1. Create a new worksheet in Snowflake Portal.
2. Replace all the SAMPLE references with your email prefix identifier. (e.g. giannis@orfium.com -> GIANNIS)
3. _To replace multiple matches on Snowflake worksheet use the 
   1. CMD + SHIFT + H _ for Mac 
   2. CTRL + SHIFT + H _ for Windows or Linux
4. Set your respective R_SAMPLE_MASTER as the workspaces active role from the top right tab.
5. Set your respective WH_SAMPLE as the workspaces active warehouse from the top right tab.

## Actions
### Create a simple table transformation
```sql
-- USE YOUR MASTER ROLE
USE ROLE R_SAMPLE_MASTER;
USE WAREHOUSE WH_SAMPLE;

-- CREATE TRANSFORMATION TABLE
CREATE TABLE DB_DATA_PRODUCTS.SAMPLE.T_ORDERS AS (
    SELECT 
        O_ORDERKEY as ORDER_KEY,
        O_CUSTKEY as CUST_KEY,
        O_ORDERSTATUS as ORDER_STATUS,
        O_TOTALPRICE as TOTAL_PRICE,
        O_ORDERDATE as ORDER_DATE,
        CASE 
            WHEN O_ORDERPRIORITY = '1-URGENT' THEN 1
            WHEN O_ORDERPRIORITY = '2-HIGH' THEN 2
            WHEN O_ORDERPRIORITY = '3-MEDIUM' THEN 3
            WHEN O_ORDERPRIORITY = '4-NOT SPECIFIED' THEN 4
            WHEN O_ORDERPRIORITY = '5-LOW' THEN 5
        END ORDER_PRIORITY_NUM,
        CASE 
            WHEN O_ORDERPRIORITY = '1-URGENT' THEN 'URGENT'
            WHEN O_ORDERPRIORITY = '2-HIGH' THEN 'HIGH'
            WHEN O_ORDERPRIORITY = '3-MEDIUM' THEN 'MEDIUM'
            WHEN O_ORDERPRIORITY = '4-NOT SPECIFIED' THEN 'NOT SPECIFIED'
            WHEN O_ORDERPRIORITY = '5-LOW' THEN 'LOW'
        END ORDER_PRIORITY,
        O_CLERK as CLERK,
        O_SHIPPRIORITY as SHIP_PRIORITY,
        O_COMMENT as COMMENT
    FROM DB_DATA_PRODUCTS.SAMPLE.ORDERS

 );

-- MONITOR TABLE
SELECT * FROM DB_DATA_PRODUCTS.SAMPLE.T_ORDERS limit 10;

-- QUERY IN OUR RESULTS
SELECT ORDER_PRIORITY,ORDER_PRIORITY_NUM, COUNT(*) PRIORITY_CNT 
FROM DB_DATA_PRODUCTS.SAMPLE_1.T_ORDERS
GROUP BY ORDER_PRIORITY, ORDER_PRIORITY_NUM
ORDER BY ORDER_PRIORITY_NUM;
```

### Clone table using newly created transformated table
```sql
-- CLONE TABLE T_ORDERS
CREATE TABLE DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE CLONE DB_DATA_PRODUCTS.SAMPLE.T_ORDERS;
```

### Undrop mistakenly dropped table
```sql
-- DROP AND UNDROP TABLE
DROP TABLE DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE;
UNDROP TABLE DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE;
```

### Retrieve table state from time-travel
```sql
-- DELETE SOME ROWS FROM CLONED TABLE
SELECT count(*) FROM DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE;

DELETE FROM DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE
WHERE YEAR(ORDER_DATE) <= '1993';
-- VALIDATE THE DELETIONS OPERATION
SELECT count(*) FROM DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE;
```

Practically you need to add the proper amount of seconds
between the _creation_time_ and the _update_time_ of the T_ORDERS_CLONE table.
```sql
CREATE OR REPLACE TABLE DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_RSRV AS
(
    SELECT * FROM DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_CLONE AT(OFFSET => -60)
);

-- MONITOR THE RETRIEVAL PROCESS
SELECT COUNT(*) FROM DB_DATA_PRODUCTS.SAMPLE.T_ORDERS_RSRV;

```

### Read table from presenter's table
```sql
--- Grant R_GIANNIS_RO role to your MASTER role
GRANT ROLE R_GIANNIS_TEST_RO TO ROLE R_SAMPLE_MASTER;

--- Select a table form presenter schema.
SELECT * FROM DB_DATA_PRODUCTS.GIANNIS_TEST.T_ORDERS_RSRV
```
