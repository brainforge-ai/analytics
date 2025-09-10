select 

    order_id,
    customer_id,
    charge_id,

    order_created_at,
    order_processed_at,
    order_status,
    order_type,

    order_quantity,
    total_unit_price,
    grams,
    total_order_price,

    order_total,
    shipping_address_ADDRESS_1,
    shipping_address_ADDRESS_2,
    shipping_ADDRESS_city,
    shipping_ADDRESS_province,
    shipping_ADDRESS_country_code,
    shipping_ADDRESS_zip,

    billing_ADDRESS_address_1,
    billing_ADDRESS_address_2,
    billing_ADDRESS_city,
    billing_ADDRESS_province,
    billing_ADDRESS_country_code,
    billing_ADDRESS_zip,
    
from {{ ref('int_recharge__orders') }}
