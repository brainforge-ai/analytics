with shopify_orders as (
    select * from {{ ref('int_shopify_order_line') }}
),

cogs_metrics as (

    select
        app_source,
        order_id,
        sum(price) as total_line_items_price,
        sum(total_discount) as total_discounts,
        sum(CAST(REPLACE(product_cost, '$', '') AS NUMERIC)) as cogs_product_cost,
        sum(product_weight_pounds) as cogs_product_weight_pounds,
        sum(packout_units) as cogs_packout_units,
        round(sum(product_weight_pounds),0) as cogs_product_weight_pounds_rounded
    from shopify_orders
    group by all
),

final as (
    select
        cm.app_source,
        cm.order_id,
        cm.cogs_product_cost,
        cm.cogs_product_weight_pounds,
        cm.cogs_product_weight_pounds_rounded,
        cm.cogs_packout_units,
        cast(replace(sa.shipping_cost, '$', '') AS FLOAT) as order_shipping_cost,
        CAST(REPLACE(bd.box_cost, '$', '') AS FLOAT)   as order_box_cost,
        CAST(REPLACE(pf.cost, '$', '') AS FLOAT) as order_pick_cost,
        plf.fee as plf_fee
    from cogs_metrics cm

)

select * from final