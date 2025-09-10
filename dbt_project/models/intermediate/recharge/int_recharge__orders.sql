SELECT 
    orders.id AS order_id,
    orders.customer:ID::INTEGER AS customer_id,
    orders.charge:ID AS charge_id,
    orders.created_at AS order_created_at,
    orders.processed_at AS order_processed_at,
    orders.status AS order_status,
    orders.type AS order_type,
    
    SUM(line_item.value:QUANTITY::INTEGER) AS order_quantity,
    SUM(line_item.value:UNIT_PRICE::FLOAT) AS total_unit_price,
    SUM(line_item.value:GRAMS::FLOAT) AS grams,
    SUM(line_item.value:TOTAL_PRICE::FLOAT) AS total_order_price,

    orders.TOTAL_PRICE AS order_total,
    orders.shipping_address:ADDRESS1::STRING AS shipping_address_ADDRESS_1,
    orders.shipping_address:ADDRESS2::STRING AS shipping_address_ADDRESS_2,
    orders.shipping_address:CITY::STRING AS shipping_ADDRESS_city,
    orders.shipping_address:COUNTRY_CODE::STRING AS shipping_ADDRESS_country_code,
    orders.shipping_address:PROVINCE::STRING AS shipping_ADDRESS_province,
    orders.shipping_address:ZIP::STRING AS shipping_ADDRESS_zip,

    orders.billing_address:ADDRESS1::STRING AS billing_address_ADDRESS_1,
    orders.billing_address:ADDRESS2::STRING AS billing_address_ADDRESS_2,
    orders.billing_address:CITY::STRING AS billing_ADDRESS_city,
    orders.billing_address:COUNTRY_CODE::STRING AS billing_ADDRESS_country_code,
    orders.billing_address:PROVINCE::STRING AS billing_ADDRESS_province,
    orders.billing_address:ZIP::STRING AS billing_ADDRESS_zip
    
FROM {{ source('portable_recharge', 'orders') }}, 
LATERAL flatten(input => line_items) AS line_item
GROUP BY all
