with shopify_orders as (
    select * from {{ ref('int_shopify_order_line') }}
),

cogs_metrics as (

    select
        app_source,
        order_id,
        sum(cast(price as float)) as total_line_items_price,
        sum(cast(total_discount as float)) as total_discounts,
        sum(cast(product_cost as float)) as cogs_product_cost,
        sum(cast(product_weight_pounds as float)) as cogs_product_weight_pounds,
        sum(cast(packout_units as float)) as cogs_packout_units,
        round(sum(cast(product_weight_pounds as float)),0) as cogs_product_weight_pounds_rounded
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
        10 as order_shipping_cost,
        0 as order_box_cost,
        0 as order_pick_cost,
        0 as plf_fee
    from cogs_metrics cm

)

select * from final