# Create Resources of a Data Product 

> For the purpose of this workshop you have been granted with 
> SYSADMIN and SECURITYAMDIN. This will grant you the ability to
> create resources and grant access to roles.

## Guidelines
1. Create a new worksheet in Snowflake Portal.
2. Replace all the_SAMPLE references with your email prefix identifier. (e.g. giannis@orfium.com -> GIANNIS)3. 
_To replace multiple matches on Snowflake worksheet use the 
   1. CMD + SHIFT + H _ for Mac 
   2. CNTR + SHIFT + H _ for Windows or Linux

## Actions
### Use the SECURTYADMIN to create the roles of your Data Product.
```sql
USE ROLE SECURITYADMIN;
-- CREATE ROLES
CREATE ROLE R_SAMPLE_MASTER;
CREATE ROLE R_SAMPLE_RO;

-- ROLE HIERARCHY
GRANT ROLE R_SAMPLE_MASTER TO ROLE SYSADMIN;
GRANT ROLE R_SAMPLE_RO TO ROLE R_SAMPLE_MASTER;

-- GRANT ROLE TO YOURT USER
GRANT ROLE R_SAMPLE_MASTER TO USER SAMPLE_USER;
```

### Use SYSADMIN to create the Data Products Schemas and Warehouse
```sql
USE ROLE SYSADMIN;
-- CREATE WAREHOUSE
CREATE WAREHOUSE IF NOT EXISTS WH_SAMPLE
WAREHOUSE_SIZE=XSMALL
INITIALLY_SUSPENDED=TRUE
AUTO_SUSPEND=10400;

-- CREATE SCHEMAS

CREATE SCHEMA IF NOT EXISTS DB_DATA_PRODUCTS.SAMPLE
WITH MANAGED ACCESS
MAX_DATA_EXTENSION_TIME_IN_DAYS = 1;
```