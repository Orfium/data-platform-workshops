# Operate on

## Guidelines
1. Create a new worksheet in Snowflake Portal.
2. Replace all the SAMPLE references with your email prefix identifier. (e.g. giannis@orfium.com -> GIANNIS)
3. To replace multiple matches on Snowflake worksheet use the 
   1. CMD + SHIFT + H _ for Mac 
   2. CTRL + SHIFT + H _ for Windows or Linux

## Actions
### Drop resources
```sql
USE ROLE SYSADMIN;
DROP SCHEMA IF EXISTS DB_DATA_PRODUCTS.SAMPLE;
DROP WAREHOUSE IF EXISTS WH_SAMPLE;

USE ROLE SECURITYADMIN;
DROP ROLE R_SAMPLE_MASTER;
DROP ROLE R_SAMPLE_RO;
```