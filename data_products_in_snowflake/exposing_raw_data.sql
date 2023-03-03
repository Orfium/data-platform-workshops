-- Change all the SAMPLE_DAAP references with your resources.

USE ROLE r_sample_daap_master;

CREATE TRANSIENT TABLE DB_DATA_PRODUCTS.SAMPLE_DAAP.T_ORDERS AS (
    SELECT
      json_value:c1::NUMBER(38,0) AS O_ORDERKEY,
      json_value:c2::NUMBER(38,0)as O_CUSTKEY,
      json_value:c3::VARCHAR(1) as O_ORDERSTATUS,
      json_value:c4::NUMBER(12,2) as O_TOTALPRICE,
      json_value:c5::DATE as O_ORDERDATE,
      json_value:c6::VARCHAR(15) as O_ORDERPRIORITY,
      json_value:c7::VARCHAR(15) as O_CLERK,
      json_value:c8::NUMBER(38,0) as O_SHIPPRIORITY,
      json_value:c9::VARCHAR(79) as O_COMMENT
    FROM (select value as json_value from DB_DATA_PRODUCTS.SAMPLE_DAAP_RAW.ORDERS),
      LATERAL FLATTEN(INPUT => PARSE_JSON(json_value))
);

GRANT ROLE R_SAMPLE_DAAP_RO TO ROLE R_SAMPLE_DAAP_2_RO_DEV;



