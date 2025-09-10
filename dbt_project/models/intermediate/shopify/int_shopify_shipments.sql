with fulfillments as (
    select
        fulfillment.id as fulfillment_id,
        fulfillment.order_id,
        fulfillment.created_at as shipped_at,
        fulfillment.tracking_number,
        fulfillment.tracking_company as shipping_carrier,
        fulfillment.status as shipment_status,
    from {{ source('shopify_raw', 'fulfillment') }} fulfillment
),

orders as (
    select
        orders.order_id,
        orders.app_source,
        orders.order_quantity as shipped_quantity,
        orders.shipping_price,
        orders.shipping_discounted_price,
        orders.shipping_code,        
        orders.shipping_address_city,
        orders.shipping_address_country,
        orders.shipping_address_country_code,
        orders.shipping_address_province,
        orders.shipping_address_province_code,
        orders.shipping_address_latitude,
        orders.shipping_address_longitude,
    from {{ref('int_shopify_order')}} orders
)

select
    f.fulfillment_id,
    f.order_id,
    f.shipped_at,
    f.tracking_number,
    f.shipping_carrier,
    f.shipment_status,
    o.app_source,
    o.shipped_quantity,
    o.shipping_price,
    o.shipping_discounted_price,
    o.shipping_code,        
    o.shipping_address_city,
    o.shipping_address_country,
    o.shipping_address_country_code,
    o.shipping_address_province,
    o.shipping_address_province_code,
    o.shipping_address_latitude,
    o.shipping_address_longitude,
from fulfillments f
left join orders o
    on f.order_id = o.order_id