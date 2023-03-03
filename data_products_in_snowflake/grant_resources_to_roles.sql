-- Change all SAMPLE_DAAP with your resources.

USE ROLE SECURITYADMIN;
-- ROLE HIERARCHY
GRANT ROLE R_SAMPLE_DAAP_MASTER TO ROLE SYSADMIN;
GRANT ROLE R_SAMPLE_DAAP_DEV TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT ROLE R_SAMPLE_DAAP_RO_DEV TO ROLE R_SAMPLE_DAAP_DEV;
GRANT ROLE R_SAMPLE_DAAP_RO TO ROLE R_SAMPLE_DAAP_RO_DEV;

-- GRANT ROLE TO YOURT USER
GRANT ROLE R_SAMPLE_DAAP_MASTER TO USER SAMPLE_USER;

-- GRANT ACCESS TO WAREHOUSE
GRANT OWNERSHIP ON WAREHOUSE WH_SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT OPERATE, USAGE ON WAREHOUSE WH_SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO_DEV;

-- GRANT ACCESS TO DATABASE
GRANT MONITOR, USAGE ON DATABASE DB_DATA_PRODUCTS TO ROLE R_SAMPLE_DAAP_RO;

-- GRANT ACCESS TO SCHEMAS
GRANT
	CREATE TABLE,
    CREATE EXTERNAL TABLE,
    CREATE VIEW,
    CREATE MATERIALIZED VIEW,
    CREATE MASKING POLICY,
    CREATE ROW ACCESS POLICY,
    CREATE SESSION POLICY,
    CREATE STAGE,
    CREATE FILE FORMAT,
    CREATE SEQUENCE,
    CREATE FUNCTION,
    CREATE PIPE,
    CREATE STREAM,
    CREATE TAG,
    CREATE TASK,
    CREATE PROCEDURE
ON SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT USAGE, MONITOR ON SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO R_SAMPLE_DAAP_RO_DEV;

GRANT
	CREATE TABLE,
    CREATE EXTERNAL TABLE,
    CREATE VIEW,
    CREATE MATERIALIZED VIEW,
    CREATE MASKING POLICY,
    CREATE ROW ACCESS POLICY,
    CREATE SESSION POLICY,
    CREATE STAGE,
    CREATE FILE FORMAT,
    CREATE SEQUENCE,
    CREATE FUNCTION,
    CREATE PIPE,
    CREATE STREAM,
    CREATE TAG,
    CREATE TASK,
    CREATE PROCEDURE
ON SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT USAGE, MONITOR ON SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO R_SAMPLE_DAAP_RO;

-- GRANT ACCESS TO TABLES
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON ALL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_RO_DEV;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON ALL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON FUTURE TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_RO_DEV;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON FUTURE TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO;

-- GRANT ACCESS TO VIEWS
GRANT SELECT, REFERENCES ON ALL VIEWS IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_RO_DEV;

GRANT SELECT, REFERENCES ON ALL VIEWS IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO;

GRANT SELECT, REFERENCES ON FUTURE VIEWS IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_RO_DEV;

GRANT SELECT, REFERENCES ON FUTURE VIEWS IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO;

-- GRANT ACCESS TO EXTERNAL TABLES
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON ALL EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_RO_DEV;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON ALL EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON FUTURE EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW TO ROLE R_SAMPLE_DAAP_RO_DEV;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_MASTER;
GRANT SELECT, REFERENCES ON FUTURE EXTERNAL TABLES IN SCHEMA DB_DATA_PRODUCTS.SAMPLE_DAAP TO ROLE R_SAMPLE_DAAP_RO;

-- GRANT ACCESS TO INTEGRATIONS
GRANT USAGE ON INTEGRATION "stg_generic-27b70f5" TO ROLE R_SAMPLE_DAAP_MASTER;
