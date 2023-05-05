/*
    Example on how to use embedded Jinja & Macros.
    - Contains variable re-use which can be given as argument in runtime
    - Contains example with for loop on variable
    For more information please check https://docs.getdbt.com/docs/building-a-dbt-project/jinja-macros
*/

{{
  config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='delete+insert'
  )
}}

{% set payment_methods = ["bank_transfer", "credit_card", "coupon", "gift_card"] %}

WITH casted_payements AS (
    SELECT
        TO_NUMBER(id) AS id,
        TO_NUMBER(order_id) AS order_id,
        payment_method,
        TO_NUMBER(amount) AS amount

    FROM {{ source('example_source', 'payments') }}

),
order_payments AS (

    SELECT
        order_id AS order_id,
        {% for payment_method in payment_methods -%}
        SUM(CASE WHEN payment_method = '{{payment_method}}' THEN amount ELSE 0 END) AS {{payment_method}}_amount,
        {% endfor -%}

        SUM(TO_NUMBER(amount)) AS TOTAL_AMOUNT

    FROM casted_payements

    GROUP BY order_id

)

    SELECT
        orders.id AS order_id,
        orders.user_id AS customer_id,
        orders.order_date,
        orders.status,

        {% for payment_method in payment_methods -%}

        order_payments.{{payment_method}}_amount,

        {% endfor -%}

        order_payments.total_amount AS AMOUNT,
        current_timestamp() AS updated_at

    FROM {{ source('example_source', 'orders') }} AS orders

    LEFT JOIN order_payments
        ON orders.id = order_payments.order_id

    {% if is_incremental() %}

    WHERE order_date >= (SELECT max(order_date) FROM {{ this }})

    {% endif %}