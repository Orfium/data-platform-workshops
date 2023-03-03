-- Change all SAMPLE_DAAP with your resources.

USE ROLE SECURITYADMIN;
-- CREATE ROLES
CREATE ROLE R_SAMPLE_DAAP_MASTER;
CREATE ROLE R_SAMPLE_DAAP_DEV;
CREATE ROLE R_SAMPLE_DAAP_RO_DEV;
CREATE ROLE R_SAMPLE_DAAP_RO;


USE ROLE SYSADMIN;
-- CREATE WAREHOUSE
CREATE WAREHOUSE IF NOT EXISTS WH_SAMPLE_DAAP
WAREHOUSE_SIZE=XSMALL
INITIALLY_SUSPENDED=TRUE
AUTO_SUSPEND=10400;

-- CREATE SCHEMAS
CREATE SCHEMA IF NOT EXISTS DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW
WITH MANAGED ACCESS
MAX_DATA_EXTENSION_TIME_IN_DAYS = 1;

CREATE SCHEMA IF NOT EXISTS DB_DATA_PRODUCTS.SAMPLE_DAAP
WITH MANAGED ACCESS
MAX_DATA_EXTENSION_TIME_IN_DAYS = 1;