
WITH is_refunded AS (

    SELECT
        LINE_ITEM_ID as order_line_id,
        sum(REFUND_QUANTITY) as quantity_refunded,
        sum(REFUND_SUBTOTAL) as refund_subtotal,
        sum(REFUND_TOTAL_TAX) as refund_tax
    FROM {{ ref('raw_shopify_order_refund_line_items')}}
    GROUP BY 1

),

taxes AS (

    SELECT
        LINE_ITEM_ID as ORDER_LINE_ID,
        SUM(TAX_PRICE) AS TAX_AMOUNT,
        AVG(TAX_RATE) AS TAX_RATE,
        LISTAGG(TAX_TITLE,', ') AS TAX_SKU
    FROM {{ ref('raw_shopify_order_line_tax_lines')}}
    GROUP BY 1

),

dates AS (

    SELECT
        ID,
        created_at as order_created_date
    FROM {{ source('shopify','orders') }} 

),

tiktok_order_id AS (

    SELECT
        ORDER_ID,
        REPLACE(tag,'TikTokOrderID:','') AS TIKTOK_ORDER_ID
    FROM {{ref('raw_shopify_order_tags')}}
    where tag like '%TikTokOrderID:%'

),

default_values as (
    with default_product_cost as (
        select 
            20 as product_cost,
            10 as product_weight_pounds,
            10 as packout_units
    )
    select * from default_product_cost
),

final as (

    SELECT
        case when toi.TIKTOK_ORDER_ID is not null then 'TikTok' else 'Shopify' end as app_source,
        order_created_date,
        o.LINE_ITEM_ID AS ORDER_LINE_ID,
        o.ORDER_ID,
        o.PRODUCT_ID,
        o.VARIANT_ID,
        o.ITEM_NAME AS ORDER_LINE_NAME,
        o.ITEM_TITLE as product_name,
        'product_category' as product_category,
        'product_flavor' as product_flavor,
        case when p.PRODUCT_TYPE = '' then null else p.product_type end as product_type,
        o.SKU,
        o.FULFILLMENT_STATUS,
        o.ITEM_QUANTITY,
        o.GRAMS,
        o.FULFILLABLE_QUANTITY,
        cast(o.ITEM_QUANTITY as INTEGER) * cast(o.PRE_TAX_PRICE as float) as PRE_TAX_PRICE,
        o.PRICE,
        o.TOTAL_DISCOUNT,
        t.TAX_AMOUNT,
        t.TAX_RATE,
        t.TAX_SKU,
        pvd.weight,
        pvd.weight_unit,
        (CASE WHEN r.order_line_id is not null THEN 1 ELSE 0 END) AS ORDER_REFUNDED,
        r.quantity_refunded,
        r.refund_subtotal,
        r.refund_tax,
        12 as product_cost,
        10 as product_weight_pounds,
        10 as packout_units,
        -- Unit level COGS calculations
        12 as unit_product_cost,
        10 as unit_shipping_cost,
        0 as unit_box_cost,
        0 as unit_pick_cost,
        0 as unit_platform_fees,
        
        -- Total COGS calculations (multiplied by quantity)
        cast(o.ITEM_QUANTITY as INTEGER) * 12 as cogs_product_cost,
        cast(o.ITEM_QUANTITY as INTEGER) * 10 as total_shipping_cost,
        cast(o.ITEM_QUANTITY as INTEGER) * 0 as total_box_cost,
        cast(o.ITEM_QUANTITY as INTEGER) * 0 as total_pick_cost,
        (cast(o.PRICE as float) - cast(o.TOTAL_DISCOUNT as float)) * 0.05 as total_platform_fees

    FROM {{ ref('raw_shopify_order_line')}} o
    LEFT JOIN is_refunded r
        ON o.LINE_ITEM_ID = r.order_line_id
    LEFT JOIN taxes t
        ON t.order_line_id = o.LINE_ITEM_ID
    LEFT JOIN {{ ref('int_shopify_product_variant') }} pvd
        ON pvd.variant_id = o.variant_id
    LEFT JOIN dates
        ON o.order_id = dates.id
    left join {{ ref('int_shopify_product') }} p
        on o.product_id = p.product_id
    LEFT JOIN tiktok_order_id toi
        ON toi.order_id = o.order_id
    

    cross join default_values dv
)

select * from final
