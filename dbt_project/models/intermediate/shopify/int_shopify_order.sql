WITH discounts AS (

    SELECT
        ORDER_ID,
        LISTAGG(DISTINCT DISCOUNT_CODE,', ') AS DISCOUNT_CODE,
        SUM(DISCOUNT_AMOUNT) AS DISCOUNT_AMOUNT
    FROM {{ ref('raw_shopify_order_discount_codes')}}
    GROUP BY 1

),


shipping_codes AS (

    SELECT
        ORDER_ID,
        LISTAGG(DISTINCT SHIPPING_CODE,', ') AS SHIPPING_CODE,
        SUM(SHIPPING_PRICE) AS SHIPPING_PRICE,
        SUM(DISCOUNTED_PRICE) AS SHIPPING_DISCOUNTED_PRICE
    FROM {{ ref('raw_shopify_order_shipping_lines')}}
    GROUP BY 1

),

shopify_tags AS (

    SELECT DISTINCT
        ORDER_ID,
    MAX(CASE WHEN LOWER(TAG) = 'subscription recurring order'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_SUBSCRIPTION_RECURRING_ORDER,
    MAX(CASE WHEN LOWER(TAG) = 'subscription'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_SUBSCRIPTION_ORDER,
    MAX(CASE WHEN LOWER(TAG) = 'renewal'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_RENEWAL_ORDER,
    MAX(CASE WHEN LOWER(TAG) = 'reactivation'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_REACTIVATION_ORDER,
    MAX(CASE WHEN LOWER(TAG) = 'first time customer'
        THEN 1 ELSE 0 END)::BOOLEAN AS FIRST_TIME_CUSTOMER_ORDER,
    MAX(CASE WHEN LOWER(TAG) = 'subscription first order'
        THEN 1 ELSE 0 END)::BOOLEAN AS SUBSCRIPTION_FIRST_ORDER,
    MAX(CASE WHEN LOWER(TAG) = 'tiktok shop'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_TIKTOK_SHOP,
    MAX(CASE WHEN LOWER(TAG) = 'klaviyo'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_KLAVIYO,
    MAX(CASE WHEN LOWER(TAG) = 'snapchat'
        THEN 1 ELSE 0 END)::BOOLEAN AS IS_SNAPCHAT
    from {{ref('raw_shopify_order_tags')}}
    WHERE tag IN (
        'Subscription Recurring Order',
        'Subscription',
        'Renewal',
        'Reactivation',
        'First Time Customer',
        'Subscription First Order',
        'TikTok Shop',
        'tiktok',
        'klaviyo',
        'snapchat'
    )
    GROUP BY 1
),

tiktok_order_id AS (

    SELECT
        ORDER_ID,
        REPLACE(tag,'TikTokOrderID:','') AS TIKTOK_ORDER_ID
    FROM {{ref('raw_shopify_order_tags')}}
    where left(tag,14) IN ('TikTokOrderID:')

),

refunds AS (

    select * from {{ ref('int_shopify_order_refunds') }}

),


product_cost as ( 
    
    select
        order_id,
        COALESCE(SUM(PRODUCT_COST), 0) AS cogs_product_cost -- total_product_cost is not being used in downstream models or dashboards, so we changed it to cogs_product_cost
    from {{ ref('int_shopify_order_line') }}
    group by all
 
),

order_quantity as (
    
    select
        order_id,
        sum(ITEM_QUANTITY) as order_quantity,
        sum(ITEM_QUANTITY*pre_tax_price) as total_line_items_price
    from {{ ref('int_shopify_order_line') }}
    where lower(product_name) not like '%shipping%'
    group by all
    
),

offer as (
    select 
        order_id,
        ATTRIBUTE_VALUE as offer
    from {{ ref('raw_shopify_order_note_attributes')}}
    where lower(ATTRIBUTE_NAME) = 'offer'
),

offer_name as (
    select
        order_id,
        ATTRIBUTE_VALUE as offer_name
    from {{ ref('raw_shopify_order_note_attributes')}}
    where lower(ATTRIBUTE_NAME) = 'offername'
),

sale_name as (
    select
        order_id,
        ATTRIBUTE_VALUE as sale_name
    from {{ ref('raw_shopify_order_note_attributes')}}
    where lower(ATTRIBUTE_NAME) = 'salename'
),

product_names_agg as (
    SELECT
        order_id,
        lower(listagg(DISTINCT product_name, ', ')) as product_names_str,
        ARRAY_AGG(DISTINCT product_name) AS product_names
    FROM {{ ref('int_shopify_order_line') }}
    GROUP BY order_id
),

final as (

    SELECT
        distinct
        o.ORDER_ID,
        case when toi.TIKTOK_ORDER_ID is not null then 'TikTok' else 'Shopify' end as app_source,
        o.order_number::varchar as order_number,
        toi.TIKTOK_ORDER_ID::varchar as tiktok_order_id,
        oq.order_quantity,
        o.CUSTOMER_ID::varchar as customer_id,
        o.CREATED_AT,
        o.UPDATED_AT,
        o.PROCESSED_AT,
        o.CLOSED_AT,
        o.CANCELLED_AT,
        o.CANCEL_REASON,
        o.NAME AS ORDER_NAME,
        o.CURRENCY,
        o.FINANCIAL_STATUS,
        o.FULFILLMENT_STATUS,
        o.SUBTOTAL_PRICE::float as subtotal_price,
        o.TOTAL_TAX::float as total_tax,
        o.TOTAL_PRICE::float as total_price,
        oq.total_line_items_price as total_line_items_price,
        pc.cogs_product_cost::float as cogs_product_cost, -- total_product_cost is not being used in downstream models or dashboards, so we changed it to cogs_product_cost
        (o.TOTAL_PRICE::float * 0.029) + 0.3 as processing_fee,
        o.TOTAL_DISCOUNTS::float as total_discounts,
        d.DISCOUNT_CODE,
        o.CURRENT_TOTAL_PRICE::float as current_total_price,
        o.CURRENT_TOTAL_DISCOUNTS::float as current_total_discounts,
        o.CURRENT_SUBTOTAL_PRICE::float as current_subtotal_price,
        o.CURRENT_TOTAL_TAX::float as current_total_tax,
        f.fee_amount::float as fee_amount,
        re.refund_amount::float as refund_amount,
        re.refund_code,
        re.refund_reason,
        re.refund_created_at,
        re.refund_processed_at,
        re.is_returned,
        sc.shipping_price,
        sc.shipping_discounted_price,
        sc.shipping_price - sc.shipping_discounted_price as shipping_discount_amount,
        sc.shipping_code,

        -- shipping address
        o.SHIPPING_ADDRESS1::varchar as shipping_address1,
        o.SHIPPING_ADDRESS2::varchar as shipping_address2,
        o.SHIPPING_ADDRESS_CITY::varchar as shipping_address_city,
        o.SHIPPING_ADDRESS_COUNTRY::varchar as shipping_address_country,
        o.SHIPPING_ADDRESS_COUNTRY_CODE::varchar as shipping_address_country_code,
        o.SHIPPING_ADDRESS_PROVINCE::varchar as shipping_address_province,
        o.SHIPPING_ADDRESS_PROVINCE_CODE::varchar as shipping_address_province_code,
        o.SHIPPING_ADDRESS_LATITUDE::varchar as shipping_address_latitude,
        o.SHIPPING_ADDRESS_LONGITUDE::varchar as shipping_address_longitude,
        o.SHIPPING_ADDRESS_ZIP::varchar as shipping_address_zip,

        -- customer order number
        row_number() over (partition by customer_id order by CASE WHEN financial_status = 'paid' THEN created_at END asc) as customer_order_number,
        (CASE WHEN row_number() over (partition by customer_id order by CASE WHEN financial_status = 'paid' THEN created_at END asc) = 1
            THEN 'New' ELSE 'Returning' END) AS customer_type,
        o.TOTAL_WEIGHT,
        o.SOURCE_NAME,
        o.PAYMENT_GATEWAY_NAMES,

        -- shopify additional details
        REPLACE(TRIM(off.offer, '"'), '"', '') as offer,
        REPLACE(TRIM(onn.offer_name, '"'), '"', '') as offer_name,
        REPLACE(TRIM(sn.sale_name, '"'), '"', '') as sale_name,
        pn.product_names,

        case 
            when product_names_str like '%protein%' and product_names_str like '%concentrate%' then 'both'
            when product_names_str like '%protein%' then 'protein'
            when product_names_str like '%concentrate%' then 'concentrate'
        end as funnel_type,
        
        -- shopify order calculated fields
        (case when re.refund_amount is not null then 1 else 0 end)::boolean as is_refunded,

        st.IS_SUBSCRIPTION_RECURRING_ORDER,
        st.IS_SUBSCRIPTION_ORDER,
        st.IS_RENEWAL_ORDER,
        st.IS_REACTIVATION_ORDER,
        st.FIRST_TIME_CUSTOMER_ORDER,
        st.SUBSCRIPTION_FIRST_ORDER,
        st.IS_TIKTOK_SHOP,
        st.IS_KLAVIYO,
        st.IS_SNAPCHAT

    FROM {{ ref('raw_shopify_order') }} o
    LEFT JOIN discounts d
        ON d.order_id = o.ORDER_ID
    LEFT JOIN shipping_codes sc
        ON sc.order_id = o.ORDER_ID
    LEFT JOIN refunds re
        ON re.order_id = o.ORDER_ID
    LEFT JOIN tiktok_order_id toi
        ON toi.order_id = o.ORDER_ID
    LEFT JOIN shopify_tags st
        ON st.order_id = o.ORDER_ID
    left join offer off
        on off.order_id = o.ORDER_ID
    left join offer_name onn
        on onn.order_id = o.ORDER_ID
    left join sale_name sn
        on sn.order_id = o.ORDER_ID

    left join product_cost pc         -- total_product_cost is not being used in downstream models or dashboards
        on pc.order_id = o.ORDER_ID
    
    left join order_quantity oq
        on oq.order_id = o.ORDER_ID

     left join product_names_agg pn
        on pn.order_id = o.ORDER_ID

    -- WHERE o._FIVETRAN_DELETED = FALSE

)

select 
    final.*
from final 
