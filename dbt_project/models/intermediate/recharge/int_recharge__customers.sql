WITH 
customer_details AS (
    SELECT 
        id AS customer_id,
        email,
        first_name,
        last_name,
        first_name || ' ' || last_name AS full_name,
        created_at,
        updated_at
    FROM {{ source('portable_recharge', 'customers') }}
),
customer_addresses AS (
    SELECT 
        customer:ID::INTEGER AS customer_id,
        shipping_address:ADDRESS1::STRING AS address_1,
        shipping_address:ADDRESS2::STRING AS address_2,
        shipping_address:CITY::STRING AS city,
        shipping_address:COUNTRY_CODE::STRING AS country_code,
        shipping_address:PROVINCE::STRING AS province,
        shipping_address:ZIP::STRING AS zip
    FROM {{ source('portable_recharge', 'orders') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at) = 1
)
SELECT
    customer_details.customer_id,
    customer_details.email,
    customer_details.first_name,
    customer_details.last_name,
    customer_details.full_name,
    customer_details.created_at,
    customer_details.updated_at,
    customer_addresses.address_1,
    customer_addresses.address_2,
    customer_addresses.city,
    customer_addresses.country_code,
    customer_addresses.province,
    customer_addresses.zip,
FROM customer_details
LEFT JOIN customer_addresses USING (customer_id)
