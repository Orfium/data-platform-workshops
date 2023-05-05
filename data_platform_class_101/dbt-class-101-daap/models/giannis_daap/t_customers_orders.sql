/*
- Example case with incremental model
    - https://docs.getdbt.com/docs/building-a-dbt-project/building-models/configuring-incremental-models
- Example on how to reference source tables.
*/
{{
  config(
    materialized='table',
  )
}}

-- Examples on how to use source tables in transformation commits.
WITH customer_orders AS (

    SELECT
        user_id AS CUSTOMER_ID,
        min(order_date) AS FIRST_ORDER,
        max(order_date) AS MOST_RECENT_ORDER,
        count(id) AS NUMBER_OF_ORDERS
    FROM {{ source('example_source', 'orders') }}

    GROUP BY customer_id

)

,customer_payments AS (

    SELECT
        orders.user_id AS CUSTOMER_ID,
        sum(amount) AS TOTAL_AMOUNT

    FROM {{ source('example_source', 'payments') }}

    LEFT JOIN {{ source('example_source', 'orders') }} as orders ON
         payments.order_id = orders.id

    GROUP BY orders.user_id

)

,final AS (

    SELECT
        customers.id AS CUSTOMER_ID,
        customers.first_name AS FIRST_NAME,
        customers.last_name AS LAST_NAME,
        customer_orders.first_order AS FIRST_ORDER,
        customer_orders.most_recent_order AS MOST_RECENT_ORDER,
        customer_orders.number_of_orders AS NUMBER_OF_ORDERS,
        customer_payments.total_amount AS CUSTOMER_LIFETIME_VALUE

    FROM {{ source('example_source', 'customers') }}

    LEFT JOIN customer_orders
        ON customers.id = customer_orders.customer_id

    LEFT JOIN customer_payments
        ON  customers.id = customer_payments.customer_id

)

SELECT
    *,
    CURRENT_TIMESTAMP() AS updated_at
FROM final
