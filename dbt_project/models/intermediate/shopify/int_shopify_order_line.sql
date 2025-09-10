
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
    where left(tag,14) IN ('TikTokOrderID:')

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
        NVL(p.product_type,{{ get_product_category('o.ITEM_TITLE', 'o.ITEM_NAME') }}) as product_category,
        NVL({{ get_product_flavor('o.ITEM_TITLE') }}, {{ get_product_flavor('o.ITEM_NAME') }}) as product_flavor,
        case when p.PRODUCT_TYPE = '' then null else p.product_type end as product_type,
        o.SKU,
        o.FULFILLMENT_STATUS,
        o.ITEM_QUANTITY,
        o.GRAMS,
        o.FULFILLABLE_QUANTITY,
        o.ITEM_QUANTITY * o.PRE_TAX_PRICE as PRE_TAX_PRICE,
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
        case 
            when pc.product_cost = '' then dv.product_cost
            else coalesce(CAST(REPLACE(pc.product_cost, '$', '') AS DECIMAL(18,4)), dv.product_cost)
        end as product_cost,
        coalesce(case when pc.product_weight_pounds = '' then null else pc.product_weight_pounds end, dv.product_weight_pounds) as product_weight_pounds,
        coalesce(case when pc.packout_units = '' then null else pc.packout_units end, dv.packout_units) as packout_units,
    
        -- Unit level COGS calculations
        case 
            when pc.product_cost = '' then dv.product_cost
            else coalesce(CAST(REPLACE(pc.product_cost, '$', '') AS DECIMAL(18,4)), dv.product_cost)
        end as unit_product_cost,
        CAST(REPLACE(sa.shipping_cost, '$', '') AS DECIMAL(18,2)) as unit_shipping_cost,
        nvl(CAST(REPLACE(bd.box_cost, '$', '') AS DECIMAL(18,2)), 0) as unit_box_cost,
        nvl(CAST(REPLACE(pf.cost, '$', '') AS DECIMAL(18,2)), 0) as unit_pick_cost,
        ((o.PRICE - o.TOTAL_DISCOUNT) / NULLIF(o.ITEM_QUANTITY, 0)) * plf.fee / 100 as unit_platform_fees,
        
        -- Total COGS calculations (multiplied by quantity)
        o.ITEM_QUANTITY * case 
            when pc.product_cost = '' then dv.product_cost
            else coalesce(CAST(REPLACE(pc.product_cost, '$', '') AS DECIMAL(18,4)), dv.product_cost)
        end as cogs_product_cost,
        o.ITEM_QUANTITY * CAST(REPLACE(sa.shipping_cost, '$', '') AS DECIMAL(18,2)) as total_shipping_cost,
        o.ITEM_QUANTITY * nvl(CAST(REPLACE(bd.box_cost, '$', '') AS DECIMAL(18,2)), 0) as total_box_cost,
        o.ITEM_QUANTITY * nvl(CAST(REPLACE(pf.cost, '$', '') AS DECIMAL(18,2)), 0) as total_pick_cost,
        (o.PRICE - o.TOTAL_DISCOUNT) * plf.fee / 100 as total_platform_fees

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
