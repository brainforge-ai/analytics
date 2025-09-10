with shipment_events as (
    select
        FINANCIAL_EVENT_GROUP_ID as fulfillment_id,
        amazon_order_id as order_id,
        posted_date as shipped_at,
        null as shipping_carrier,
        null as tracking_number
    from {{ source('amazon_raw', 'financial_shipment_event') }}
),

fulfillment_orders as ( 
    select 
        SELLER_FULFILLMENT_ORDER_ID as order_id,
        fulfillment_order_status as shipment_status
    from {{ source('amazon_raw', 'fulfillment_order') }}
),

orders as (
    select
        app_source,
        AMAZON_ORDER_ID,      
        quantity,  
        SHIPPING_PRICE_AMOUNT,
        shipping_discounted_price,
        SHIPPING_TAX_AMOUNT,
        SHIPPING_DISCOUNT_AMOUNT,
        SHIPPING_DISCOUNT_TAX_AMOUNT,
        SHIPPING_ADDRESS_CITY,
        SHIPPING_ADDRESS_STATE_OR_REGION,
        SHIPPING_ADDRESS_POSTAL_CODE,
        SHIPPING_ADDRESS_COUNTRY_CODE
    from {{ref('int_amazon_order')}} orders
)

select
    se.fulfillment_id,
    se.order_id,
    se.shipped_at,
    se.tracking_number,
    se.shipping_carrier,
    fo.shipment_status, 
    o.app_source,
    o.QUANTITY as shipped_quantity,
    o.SHIPPING_PRICE_AMOUNT,
    o.shipping_discounted_price,
    o.SHIPPING_TAX_AMOUNT,
    o.SHIPPING_DISCOUNT_AMOUNT,
    o.SHIPPING_DISCOUNT_TAX_AMOUNT,
    o.SHIPPING_ADDRESS_CITY,
    o.SHIPPING_ADDRESS_STATE_OR_REGION,
    o.SHIPPING_ADDRESS_POSTAL_CODE,
    o.SHIPPING_ADDRESS_COUNTRY_CODE
from shipment_events se
left join orders o
    on se.order_id = o.amazon_order_id
left join fulfillment_orders fo
    on se.order_id = fo.order_id
