USE ROLE SYSADMIN;
DROP SCHEMA IF EXISTS DB_DATA_PRODUCTS.SAMPLE;
DROP SCHEMA IF EXISTS DB_DATA_PRODUCTS.SAMPLE;
DROP WAREHOUSE IF EXISTS WH_SAMPLE;

USE ROLE SECURITYADMIN;
DROP ROLE R_SAMPLE_MASTER;
DROP ROLE R_SAMPLE_RO;