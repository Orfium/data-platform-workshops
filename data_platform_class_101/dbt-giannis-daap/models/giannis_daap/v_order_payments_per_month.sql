{{
  config(
    materialized='view'
  )
}}

WITH CTE_CUSTOMER_ORDERS_PER_MONTH AS (
    SELECT
        YEAR(ORDER_DATE) AS ORDER_YEAR,
        MONTH(ORDER_DATE) AS ORDER_MONTH,
        COUNT(ORDER_ID) AS TOTAL_ORDERS,
        SUM(AMOUNT) AS AGG_AMOUNT
    FROM {{ ref('t_orders_payments') }}
    GROUP BY
        ORDER_YEAR,
        ORDER_MONTH,
        ORDER_ID
)

SELECT * FROM CTE_CUSTOMER_ORDERS_PER_MONTH


