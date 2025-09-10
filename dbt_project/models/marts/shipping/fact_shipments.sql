with shopify_shipments as (
    select
        cast(fulfillment_id as string) as fulfillment_id,
        cast(order_id as string) as order_id,
        shipped_at,
        tracking_number,
        shipping_carrier,
        shipment_status,
        app_source,
        shipped_quantity,
        shipping_price,
        shipping_discounted_price,
        shipping_address_city,
        shipping_address_country_code,
        shipping_address_province_code,
    from {{ ref('int_shopify_shipments') }}
),

amazon_shipments as (
    select 
        cast(fulfillment_id as string) as fulfillment_id,
        cast(order_id as string) as order_id,
        shipped_at,
        tracking_number,
        shipping_carrier,
        shipment_status, 
        app_source,
        shipped_quantity,
        SHIPPING_PRICE_AMOUNT,
        shipping_discounted_price,        
        SHIPPING_ADDRESS_CITY,
        SHIPPING_ADDRESS_COUNTRY_CODE,
        SHIPPING_ADDRESS_POSTAL_CODE        
    from {{ ref('int_amazon_shipments') }}
),

unioned_shipments as (
    select * from shopify_shipments
    union all
    select * from amazon_shipments
)

select
    *    
from unioned_shipments