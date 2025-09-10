with amazon_orders as (
    select * from {{ ref('int_amazon_order_line') }}
),

cogs_metrics as (

    select
        'Amazon' AS app_source,
        amazon_order_id as order_id,
        sum(product_cost) as cogs_product_cost,
        sum(product_weight_pounds) as cogs_product_weight_pounds,
        sum(packout_units) as cogs_packout_units,
        round(sum(product_weight_pounds),0) as cogs_product_weight_pounds_rounded
    from amazon_orders
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
        sa.shipping_cost as order_shipping_cost,
        nvl(CAST(REPLACE(bd.box_cost, '$', '') AS NUMERIC), 0) as order_box_cost,
        nvl(CAST(REPLACE(pf.cost, '$', '') AS NUMERIC), 0) as order_pick_cost,
        nvl(CAST(REPLACE(plf.fee, '$', '') AS NUMERIC), 0) as fbamzn_fees_cogs
    from cogs_metrics cm
    left join {{ source('PORTABLE_GOOGLE_SHEETS_SHIPPING_ASSUMPTIONS','SPREADSHEET_VALUES')}} sa
        on cm.cogs_product_weight_pounds_rounded = sa.weight_pounds
    left join {{ source('PORTABLE_GOOGLE_SHEETS_BOX_COST_DUNNAGE_ASSUMPTIONS','SPREADSHEET_VALUES')}}  bd
        on cm.cogs_packout_units = bd.units
    left join {{ source('PORTABLE_GOOGLE_SHEETS_PICK_FEES_ASSUMPTIONS','SPREADSHEET_VALUES')}}  pf
        on cm.cogs_packout_units = pf.units
    left join {{ source('PORTABLE_GOOGLE_SHEETS_PLATFORM_FEES_ASSUMPTIONS','SPREADSHEET_VALUES')}}  plf
        on plf.app_source = cm.app_source
        
)

select * from final
